// This is a part of pacmixer @ http://github.com/KenjiTakahashi/pacmixer
// Karol "Kenji Takahashi" Woźniak © 2012 - 2013
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.


#import "frontend.h"


static WINDOW *pad;
static WINDOW *win;
static PANEL *pan;
static int xpadding;
static int ypadding;


@implementation TUI
-(TUI*) init {
    self = [super init];
    allWidgets = [[NSMutableArray alloc] init];
    widgets = [[NSMutableArray alloc] init];
    settings = [[Settings alloc] init];
    initscr();
    cbreak();
    noecho();
    curs_set(0);
    keypad(stdscr, TRUE);
    start_color();
    use_default_colors();
    // default background/foreground (COLOR_PAIR(0) doesn't seem to work)
    init_pair(1, -1, -1);
    init_pair(2, -1, COLOR_GREEN); // low level volume/not muted
    init_pair(3, -1, COLOR_YELLOW); // medium level volume
    init_pair(4, -1, COLOR_RED); // high level volume/muted
    init_pair(5, COLOR_BLACK, COLOR_MAGENTA); // extreme (>100%) level volume
    init_pair(6, COLOR_BLACK, COLOR_BLUE); // outside mode
    init_pair(7, COLOR_BLACK, COLOR_WHITE); // inside mode
    refresh();
    int my;
    int mx;
    getmaxyx(stdscr, my, mx);
    pad = newpad(my - 4, 1);
    win = newwin(my - 4, mx - 2, 2, 1);
    pan = new_panel(win);
    xpadding = 0;
    ypadding = 0;
    xpaddingStates = [[NSMutableArray alloc] init];
    ypaddingStates = [[NSMutableArray alloc] init];
    bottom = [[Bottom alloc] init];
    top = [[Top alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(removeWaiter:)
                                                 name: @"backendAppeared"
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(addWaiter:)
                                                 name: @"backendGone"
                                               object: nil];
    [self addWaiter: nil];
    return self;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    del_panel(pan);
    delwin(win);
    delwin(pad);
    endwin();
    [bottom release];
    [top release];
    [widgets release];
    [settings release];
    [allWidgets release];
    [ypaddingStates release];
    [xpaddingStates release];
    [super dealloc];
}

-(void) addWaiter: (NSNotification*) _ {
    wclear(pad);
    NSString *message = @"Waiting for connection...";
    notice = [[Notice alloc] initWithMessage: message
                                   andParent: pad];
    [[self class] refresh];
}

-(void) removeWaiter: (NSNotification*) _ {
    [notice release];
    notice = nil;
    wclear(pad);
    [[self class] refresh];
}

-(void) reprint {
    int my;
    int mx;
    getmaxyx(stdscr, my, mx);
#ifdef DEBUG
debug_fprintf(__func__, "f:reprinting TUI at %dx%d", mx, my);
#endif
    [top reprint];
    for(int i = 0; i < [widgets count]; ++i) {
        Widget *w = [widgets objectAtIndex: i];
        [w reprint: my - 4];
    }
    wresize(pad, my - 4, mx);
    [bottom reprint];
    [[self class] refresh];
}

+(void) refresh {
    int my;
    int mx;
    getmaxyx(stdscr, my, mx);
    int py;
    int px;
    getmaxyx(pad, py, px);
    if(py > my - 4) {
        py = my - 4;
    }
    if(px > mx - 2) {
        px = mx - 2;
    }
    int r = copywin(pad, win, ypadding, xpadding, 0, 0, py - 1, px - 1, 0);
    if(r == ERR) {
        int y;
        int x;
        getmaxyx(win, y, x);
        printw("%d:%d:%d:%d\t", my - 5, mx - 3, y, x);
    }
    bottom_panel(pan);
    update_panels();
    doupdate();
}

-(void) clear {
    if([widgets count]) {
        id widget = [widgets objectAtIndex: highlight];
        [widget setHighlighted: NO];
    }
    wclear(pad);
    [widgets removeAllObjects];
}

-(BOOL) applySettings: (NSString*) name {
    NSString *key = @"Filter/PulseAudio internals";
    BOOL filter1 = [[settings getValue: key] boolValue];
    key = @"Filter/Monitors";
    BOOL filter2 = [[settings getValue: key] boolValue];
    filter1 = filter1 && [name hasPrefix: @"PulseAudio"];
    filter2 = filter2 && [name hasPrefix: @"Monitor of"];
    return !filter1 && !filter2;
}

-(Widget*) addWidgetWithName: (NSString*) name
                     andType: (View) type
                       andId: (NSString*) id_ {
    int x = [[widgets lastObject] endPosition];
    Widget *widget = [[Widget alloc] initWithPosition: x
                                              andName: name
                                              andType: type
                                                andId: id_
                                            andParent: pad];
    SEL sel = @selector(setValuesByNotification:);
    NSString *nname = [NSString stringWithFormat:
        @"%@%@", @"controlChanged", id_];
    [[NSNotificationCenter defaultCenter] addObserver: widget
                                             selector: sel
                                                 name: nname
                                               object: nil];
    [allWidgets addObject: widget];
    BOOL cond = [top view] == ALL || type == [top view];
    cond = cond && [self applySettings: [widget name]];
    if(cond) {
        [widgets addObject: widget];
        if(x == 0) {
            [widget setHighlighted: YES];
        }
        [widget show];
    }
    [widget release];
    return widget;
}

-(void) removeWidget: (NSNumber*) id_ {
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    wclear(pad);
    for(int i = 0; i < [widgets count]; ++i) {
        Widget *widget = [widgets objectAtIndex: i];
        if([[widget internalId] isEqualToNumber: id_]) {
            [indexes addIndex: i];
            if(highlight >= i) {
                if(highlight > 0) {
                    highlight -= 1;
                } else if(highlight == 0 && (int)[widgets count] - 1 > 1) {
                    highlight += 1;
                }
            }
        }
    }
    [widgets removeObjectsAtIndexes: indexes];
    [indexes removeAllIndexes];
    for(int i = 0; i < [allWidgets count]; ++i) {
        Widget *widget = [allWidgets objectAtIndex: i];
        if([[widget internalId] isEqualToNumber: id_]) {
            [indexes addIndex: i];
#ifdef DEBUG
debug_fprintf(__func__, "f:%d removed at index %d", [id_ intValue], i);
#endif
        }
    }
    [allWidgets removeObjectsAtIndexes: indexes];
    int x = 0;
    for(int i = 0; i < [widgets count]; ++i) {
        Widget *w = [widgets objectAtIndex: i];
        [w setPosition: x];
        [w show];
        x = [w endPosition];
    }
    if([widgets count]) {
        [[widgets objectAtIndex: highlight] setHighlighted: YES];
    }
    [[self class] refresh];
}

-(void) addProfiles: (NSArray*) profiles
         withActive: (NSString*) active
            andName: (NSString*) name
              andId: (NSString*) id_ {
    int ypos = 0;
    if([top view] == SETTINGS) {
        ypos = [[widgets lastObject] endPosition];
    }
    Options *widget = [[Options alloc] initWithPosition: ypos
                                                andName: name
                                              andValues: profiles
                                                  andId: id_
                                              andParent: pad];
    [widget setCurrentByName: active];
    SEL sel = @selector(setCurrentByNotification:);
    NSString *nname = [NSString stringWithFormat:
        @"%@%@", @"cardProfileChanged", id_];
    [[NSNotificationCenter defaultCenter] addObserver: widget
                                             selector: sel
                                                 name: nname
                                               object: nil];
    [allWidgets addObject: widget];
    if([top view] == SETTINGS) {
        [widgets addObject: widget];
    }
    [widget release];
}

-(void) setCurrent: (int) i {
    Widget *owidget = [widgets objectAtIndex: highlight];
    highlight = i;
    Widget *nwidget = [widgets objectAtIndex: highlight];
    [owidget setHighlighted: NO];
    [nwidget setHighlighted: YES];
    if([bottom mode] == MODE_SETTINGS) {
        [owidget outside];
        [nwidget settings];
    }
}

-(void) setFirst {
    highlight = 0;
    if([widgets count]) {
        [[widgets objectAtIndex: highlight] setHighlighted: YES];
    }
    [[self class] refresh];
}

-(void) setFilter: (View) type {
    if([bottom mode] == MODE_SETTINGS) {
        [(Widget*)[widgets objectAtIndex: highlight] outside];
        [bottom outside];
    }
    [top setView: type];
    [bottom setView: ALL];
    [self clear];
    int x = 1;
    if(notice != nil) {
        [notice print];
        [[self class] refresh];
    } else {
        for(int i = 0; i < [allWidgets count]; ++i) {
            Widget *w = [allWidgets objectAtIndex: i];
            BOOL cond = [top view] == ALL && [w type] != SETTINGS;
            cond = cond || [w type] == [top view];
            cond = cond && [self applySettings: [w name]];
            if(cond) {
                [w setPosition: x];
                [w show];
                [widgets addObject: w];
                x = [w endPosition] + 1;
            } else {
                [w hide];
            }
        }
        [self setFirst];
    }
}

-(void) showSettings {
    if([bottom mode] == MODE_SETTINGS) {
        [(Widget*)[widgets objectAtIndex: highlight] outside];
        [bottom outside];
    }
    [top setView: SETTINGS];
    [bottom setView: SETTINGS];
    [self clear];
    int y = 0;
    NSArray *keys = [settings allKeys];
    for(int i = 0; i < [keys count]; ++i) {
        NSString *key = [keys objectAtIndex: i];
        Values *value = [settings objectForKey: key];
        id widget = [[[value type] alloc] initWithPosition: y
                                                   andName: key
                                                 andValues: [value values]
                                                     andId: nil
                                                 andParent: pad];
        [widget show];
        for(int i = 0; i < [value count]; ++i) {
            NSString *fullkey = [NSString stringWithFormat:
                @"%@/%@", key, [value objectAtIndex: i]];
            [widget setValue: [[settings getValue: fullkey] boolValue]
                     atIndex: i];
        }
        [widgets addObject: widget];
        y = [widget endPosition];
        [widget release];
    }
    for(int i = 0; i < [allWidgets count]; ++i) {
        Widget *w = [allWidgets objectAtIndex: i];
        if([w type] == SETTINGS) {
            [w setPosition: y];
            [w show];
            [widgets addObject: w];
            y = [w endPosition];
        } else {
            [w hide];
        }
    }
    [self setFirst];
}

-(void) switchSetting {
    id widget = [widgets objectAtIndex: highlight];
    if([top view] == SETTINGS || [bottom mode] == MODE_SETTINGS) {
        [widget switchValue];
    }
    [[self class] refresh];
}

-(void) previous {
    if([bottom mode] == MODE_INSIDE) {
        [(id<Controlling>)[widgets objectAtIndex: highlight] previous];
    } else if(highlight > 0) {
        if([bottom mode] == MODE_SETTINGS) {
            BOOL flag = NO;
            for(int i = highlight - 1; i >= 0; --i) {
                Widget *widget = [widgets objectAtIndex: i];
                if([widget canGoSettings]) {
                    [self setCurrent: i];
                    flag = YES;
                    break;
                }
            }
            if(!flag) {
                return;
            }
        } else {
            [self setCurrent: highlight - 1];
        }
        id w = [widgets objectAtIndex: highlight];
        BOOL cond = [w respondsToSelector: @selector(width)];
        cond = cond && [w endPosition] - [w width] <= xpadding;
        if(cond) {
            int count = [xpaddingStates count] - 1;
            int delta = [[xpaddingStates objectAtIndex: count] intValue];
            [xpaddingStates removeObjectAtIndex: count];
            xpadding -= delta;
        }
        cond = [w respondsToSelector: @selector(height)];
        cond = cond && [w endPosition] - [w height] < ypadding;
        if(cond) {
            int count = [ypaddingStates count] - 1;
            int delta = [[ypaddingStates objectAtIndex: count] intValue];
            [ypaddingStates removeObjectAtIndex: count];
            ypadding -= delta;
        }
    }
    [[self class] refresh];
}

-(void) next {
    if([bottom mode] == MODE_INSIDE) {
        [(id<Controlling>)[widgets objectAtIndex: highlight] next];
    } else if(highlight < (int)[widgets count] - 1) {
        int start = [[widgets objectAtIndex: highlight] endPosition];
        if([bottom mode] == MODE_SETTINGS) {
            BOOL flag = NO;
            for(int i = highlight + 1; i < (int)[widgets count] - 1; ++i) {
                Widget *widget = [widgets objectAtIndex: i];
                if([widget canGoSettings]) {
                    [self setCurrent: i];
                    flag = YES;
                    break;
                }
            }
            if(!flag) {
                return;
            }
            start = [[widgets objectAtIndex: highlight - 1] endPosition];
        } else {
            [self setCurrent: highlight + 1];
        }
        id w = [widgets objectAtIndex: highlight];
        int my;
        int mx;
        getmaxyx(stdscr, my, mx);
        BOOL cond = [w respondsToSelector: @selector(width)];
        cond = cond && [w endPosition] - xpadding >= mx;
        if(cond) {
            int delta = [w width] - (mx - start - 3 + xpadding);
            xpadding += delta;
            [xpaddingStates addObject: [NSNumber numberWithInt: delta]];
        }
        cond = [w respondsToSelector: @selector(height)];
        cond = cond && [w endPosition] - ypadding >= my - 1;
        if(cond) {
            int delta = [w height] - (my - start - 3 + ypadding);
            ypadding += delta;
            [ypaddingStates addObject: [NSNumber numberWithInt: delta]];
        }
    }
    [[self class] refresh];
}

-(void) up {
    if([widgets count]) {
        [[widgets objectAtIndex: highlight] up];
        [[self class] refresh];
    }
}

-(void) down {
    if([widgets count]) {
        [[widgets objectAtIndex: highlight] down];
        [[self class] refresh];
    }
}

-(void) mute {
    if([widgets count]) {
        [(id<Controlling>)[widgets objectAtIndex: highlight] mute];
        [[self class] refresh];
    }
}

-(void) inside {
    if([top view] != SETTINGS && [widgets count]) {
        Widget *widget = [widgets objectAtIndex: highlight];
        if([widget canGoInside]) {
            [bottom inside];
            [widget inside];
        }
        [[self class] refresh];
    }
}

-(void) settings {
    if([top view] != SETTINGS && [widgets count]) {
        Widget *widget = [widgets objectAtIndex: highlight];
        if([widget canGoSettings]) {
            [bottom settings];
            [widget settings];
        }
        [[self class] refresh];
    }
}

-(BOOL) outside {
    BOOL outside = [bottom outside];
    if(!outside) {
        Widget *widget = [widgets objectAtIndex: highlight];
        [widget outside];
        [[self class] refresh];
    }
    return outside;
}
@end
