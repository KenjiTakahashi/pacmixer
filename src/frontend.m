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
    int my = getmaxy(stdscr);
    win = newpad(my - 4, 1);
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
    delwin(win);
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
    wclear(win);
    NSString *message = @"Waiting for connection...";
    notice = [[Notice alloc] initWithMessage: message
                                   andParent: win];
    [self refresh];
}

-(void) removeWaiter: (NSNotification*) _ {
    [notice release];
    notice = nil;
    wclear(win);
    [self refresh];
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
    wresize(win, my - 4, mx);
    [bottom reprint];
    [self refresh];
}

-(void) refresh {
    int my;
    int mx;
    getmaxyx(stdscr, my, mx);
    prefresh(win, ypadding, xpadding, 2, 1, my - 2, mx - 1);
}

-(void) clear {
    if([widgets count]) {
        id widget = [widgets objectAtIndex: highlight];
        [widget setHighlighted: NO];
    }
    wclear(win);
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
    int x = [[widgets lastObject] endPosition] + 1;
    Widget *widget = [[Widget alloc] initWithPosition: x
                                              andName: name
                                              andType: type
                                                andId: id_
                                            andParent: win];
    [allWidgets addObject: widget];
    BOOL cond = [top view] == ALL || type == [top view];
    cond = cond && [self applySettings: [widget name]];
    if(cond) {
        [widgets addObject: widget];
        if(x == 1) {
            [widget setHighlighted: YES];
        }
        [widget show];
    }
    [widget release];
    return widget;
}

-(void) removeWidget: (NSNumber*) id_ {
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    wclear(win);
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
    [self refresh];
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
                                              andParent: win];
    [widget setCurrentByName: active];
    SEL sel = @selector(setCurrentByNotification:);
    NSString *nname = [NSString stringWithFormat:
        @"%@%@", @"cardProfileChanged", id_];
#ifdef DEBUG
debug_fprintf(__func__, "%s", [nname UTF8String]);
#endif
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
    [[widgets objectAtIndex: highlight] setHighlighted: NO];
    highlight = i;
    [[widgets objectAtIndex: highlight] setHighlighted: YES];
}

-(void) setFirst {
    highlight = 0;
    if([widgets count]) {
        [[widgets objectAtIndex: highlight] setHighlighted: YES];
    }
    [self refresh];
}

-(void) setFilter: (View) type {
    [top setView: type];
    [bottom setView: ALL];
    [self clear];
    int x = 1;
    if(notice != nil) {
        [notice print];
        [self refresh];
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
                                                 andParent: win];
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
    if([widget respondsToSelector: @selector(switchValue)]) {
        [widget switchValue];
    }
    [self refresh];
}

-(void) previous {
    if(inside) {
        [(id<Controlling>)[widgets objectAtIndex: highlight] previous];
    } else if(highlight > 0) {
        [self setCurrent: highlight - 1];
        id w = [widgets objectAtIndex: highlight];
        if(
            [w respondsToSelector: @selector(width)] &&
            [w endPosition] - [w width] <= xpadding
        ) {
            int count = [xpaddingStates count] - 1;
            int delta = [[xpaddingStates objectAtIndex: count] intValue];
            [xpaddingStates removeObjectAtIndex: count];
            xpadding -= delta;
        }
        if(
            [w respondsToSelector: @selector(height)] &&
            [w endPosition] - [w height] < ypadding
        ) {
            int count = [ypaddingStates count] - 1;
            int delta = [[ypaddingStates objectAtIndex: count] intValue];
            [ypaddingStates removeObjectAtIndex: count];
            ypadding -= delta;
        }
    }
    [self refresh];
}

-(void) next {
    if(inside) {
        [(id<Controlling>)[widgets objectAtIndex: highlight] next];
    } else if(highlight < (int)[widgets count] - 1) {
        int start = [[widgets objectAtIndex: highlight] endPosition];
        [self setCurrent: highlight + 1];
        id w = [widgets objectAtIndex: highlight];
        int my;
        int mx;
        getmaxyx(stdscr, my, mx);
        if(
            [w respondsToSelector: @selector(width)] &&
            [w endPosition] - xpadding >= mx
        ) {
            int delta = [w width] - (mx - start - 3 + xpadding);
            xpadding += delta;
            [xpaddingStates addObject: [NSNumber numberWithInt: delta]];
        }
        if(
            [w respondsToSelector: @selector(height)] &&
            [w endPosition] - ypadding >= my - 1
        ) {
            int delta = [w height] - (my - start - 3 + ypadding);
            ypadding += delta;
            [ypaddingStates addObject: [NSNumber numberWithInt: delta]];
        }
    }
    [self refresh];
}

-(void) up {
    if([widgets count]) {
        [[widgets objectAtIndex: highlight] up];
        [self refresh];
    }
}

-(void) down {
    if([widgets count]) {
        [[widgets objectAtIndex: highlight] down];
        [self refresh];
    }
}

-(void) mute {
    if([widgets count]) {
        [(id<Controlling>)[widgets objectAtIndex: highlight] mute];
        [self refresh];
    }
}

-(void) inside {
    if([widgets count]) {
        Widget *widget = [widgets objectAtIndex: highlight];
        if([widget canGoInside]) {
            inside = YES;
            [bottom inside];
            [[widgets objectAtIndex: highlight] inside];
        }
        [self refresh];
    }
}

-(BOOL) outside {
    BOOL outside = [bottom outside];
    if(!outside) {
        inside = NO;
        Widget *widget = [widgets objectAtIndex: highlight];
        [widget outside];
        [self refresh];
    }
    return outside;
}
@end
