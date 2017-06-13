// This is a part of pacmixer @ http://github.com/KenjiTakahashi/pacmixer
// Karol "Kenji Takahashi" Woźniak © 2012 - 2015
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
static NSMutableArray *allWidgets;

static BOOL showOptions = true;

@implementation TUI
-(TUI*) init {
    self = [super init];
    showOptions = pacmixer::setting<bool>("Filter.Options");
    allWidgets = [[NSMutableArray alloc] init];
    widgets = [[NSMutableArray alloc] init];
    initscr();
    cbreak();
    noecho();
    curs_set(0);
    keypad(stdscr, TRUE);
    start_color();
    use_default_colors();
    assume_default_colors(COLOR_WHITE, COLOR_BLACK);
    init_pair(1, -1, -1);
    init_pair(2, -1, COLOR_GREEN); // low level volume/not muted
    init_pair(3, -1, COLOR_YELLOW); // medium level volume
    init_pair(4, -1, COLOR_RED); // high level volume/muted
    init_pair(5, COLOR_WHITE, COLOR_MAGENTA); // extreme (>100%) level volume
    init_pair(6, COLOR_WHITE, COLOR_BLUE); // outside mode
    init_pair(7, COLOR_BLACK, COLOR_WHITE); // inside mode
    init_pair(8, COLOR_GREEN, -1); // Default Channel
    init_pair(9, COLOR_RED, -1); // Non-default Channel
    init_pair(10, COLOR_YELLOW, -1); // Numeric channel labels
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
    top = [[Top alloc] initWithView: pacmixer::setting<View>("Display.StartView")];
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
    [allWidgets release];
    [ypaddingStates release];
    [xpaddingStates release];
    [super dealloc];
}

-(void) addWaiter: (NSNotification*) _ {
    [allWidgets removeAllObjects];
    [widgets removeAllObjects];
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
    werase(stdscr);
    int my;
    int mx;
    getmaxyx(stdscr, my, mx);
    int pmx = getmaxx(pad);
    PACMIXER_LOG("F:reprinting TUI at %dx%d", mx, my);
    wresize(win, my - 4, mx - 2);
    wresize(pad, my - 4, pmx);
    for(unsigned int i = 0; i < [widgets count]; ++i) {
        [(Widget*)[widgets objectAtIndex: i] reprint: my - 4];
    }
    [top reprint];
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
    copywin(pad, win, ypadding, xpadding, 0, 0, py - 1, px - 1, 0);
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
    bool filter1 = pacmixer::setting<bool>("Filter.Internals");
    bool filter2 = pacmixer::setting<bool>("Filter.Monitors");
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

-(void) removeWidget: (NSString*) id_ {
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    wclear(pad);
    for(unsigned int i = 0; i < [widgets count]; ++i) {
        id widget = [widgets objectAtIndex: i];
        if([[widget internalId] isEqualToString: id_]) {
            PACMIXER_LOG("F:%s removed at index %d", [id_ UTF8String], i);
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
    for(unsigned int i = 0; i < [allWidgets count]; ++i) {
        Widget *widget = [allWidgets objectAtIndex: i];
        if([[widget internalId] isEqualToString: id_]) {
            [indexes addIndex: i];
            PACMIXER_LOG("F:%s removed at index %d", [id_ UTF8String], i);
        }
    }
    [allWidgets removeObjectsAtIndexes: indexes];
    int x = 0;
    for(unsigned int i = 0; i < [widgets count]; ++i) {
        Widget *w = [widgets objectAtIndex: i];
        [w setPosition: x];
        [w show];
        x = [w endPosition];
    }
    if([widgets count]) {
        [[widgets objectAtIndex: highlight] setHighlighted: YES];
    }
}

-(id) addProfiles: (NSArray*) profiles
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
        [widget show];
    }
    [widget release];

    return widget;
}

-(void) adjustOptions {
    for(unsigned int i = 0; i < [allWidgets count]; ++i) {
        Widget *widget = [allWidgets objectAtIndex: i];
        View wtype = [widget type];
        if(wtype == OUTPUTS || wtype == INPUTS) {
            View option_type = wtype == OUTPUTS ? PLAYBACK : RECORDING;
            NSArray *tc_widgets = [self getWidgetsWithType: option_type];
            NSArray *values = [self getWidgetsAttr: @selector(name)
                                          withType: wtype];
            NSArray *mapvalues = [self getWidgetsAttr: @selector(internalName)
                                             withType: wtype];
            for(unsigned int j = 0; j < [tc_widgets count]; ++j) {
                Widget *tc_widget = [tc_widgets objectAtIndex: j];
                [tc_widget replaceOptions: values];
                [[tc_widget options] replaceMapping: mapvalues];
            }
        }
    }
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
    int x = 0;
    if(notice != nil) {
        [notice print];
        [[self class] refresh];
    } else {
        for(unsigned int i = 0; i < [allWidgets count]; ++i) {
            Widget *w = [allWidgets objectAtIndex: i];
            BOOL cond = [top view] == ALL && [w type] != SETTINGS;
            cond = cond || [w type] == [top view];
            cond = cond && [self applySettings: [w name]];
            if(cond) {
                [w setPosition: x];
                [w show];
                [widgets addObject: w];
                x = [w endPosition];
            } else {
                [w hide];
            }
        }
        [self setFirst];
    }
}

-(void) setDefaults: (NSNotification*) notification {
    NSDictionary *userInfo = [notification userInfo];
    NSDictionary *defaults = [userInfo objectForKey: @"defaults"];
    NSString *default_sink = [defaults objectForKey: @"sink"];
    NSString *default_source = [defaults objectForKey: @"source"];

    for(unsigned int i = 0; i < [allWidgets count]; ++i) {
        Widget *w = [allWidgets objectAtIndex: i];
        if([w type] == INPUTS) {
            [w setDefault: [default_source isEqualToString: w.internalName]];
        } else if([w type] == OUTPUTS) {
            [w setDefault: [default_sink isEqualToString: w.internalName]];
        }
    }
}

-(NSArray*) getWidgetsWithType: (View) type {
    NSMutableArray *results = [NSMutableArray arrayWithCapacity: 0];
    for(unsigned int i = 0; i < [allWidgets count]; ++i) {
        Widget *widget = [allWidgets objectAtIndex: i];
        if([widget type] == type) {
            [results addObject: widget];
        }
    }
    return results;
}

-(NSArray*) getWidgetsAttr: (SEL) selector
                  withType: (View) type {
    NSMutableArray *results = [NSMutableArray arrayWithCapacity: 0];
    for(unsigned int i = 0; i < [allWidgets count]; ++i) {
        Widget *widget = [allWidgets objectAtIndex: i];
        if([widget type] == type) {
            [results addObject: [widget performSelector: selector]];
        }
    }
    return results;
}

+(Widget*) getWidgetWithId: (NSString*) id_ {
    for(unsigned int i = 0; i < [allWidgets count]; ++i) {
        Widget *widget = [allWidgets objectAtIndex: i];
        if([[widget internalId] isEqualToString: id_]) {
            return widget;
        }
    }
    return nil;
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
    for(unsigned int i = 0; i < [allWidgets count]; ++i) {
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
        BOOL cond = [w respondsToSelector: @selector(endHPosition)];
        cond = cond && [w endHPosition] - [w width] <= xpadding;
        if(cond) {
            int count = [xpaddingStates count] - 1;
            int delta = [[xpaddingStates objectAtIndex: count] intValue];
            [xpaddingStates removeObjectAtIndex: count];
            xpadding -= delta;
        }
        cond = [w respondsToSelector: @selector(endVPosition)];
        cond = cond && [w endVPosition] - [w height] < ypadding;
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
    } else if(highlight < [widgets count] - 1) {
        int start = [[widgets objectAtIndex: highlight] endPosition];
        if([bottom mode] == MODE_SETTINGS) {
            BOOL flag = NO;
            for(int i = highlight + 1; i < (int)[widgets count]; ++i) {
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
        BOOL cond = [w respondsToSelector: @selector(endHPosition)];
        cond = cond && [w endHPosition] - xpadding >= mx;
        if(cond) {
            int delta = [w width] - (mx - start - 3 + xpadding);
            xpadding += delta;
            [xpaddingStates addObject: [NSNumber numberWithInt: delta]];
        }
        cond = [w respondsToSelector: @selector(endVPosition)];
        cond = cond && [w endVPosition] - ypadding >= my - 1;
        if(cond) {
            int delta = [w height] - (my - start - 3 + ypadding);
            ypadding += delta;
            [ypaddingStates addObject: [NSNumber numberWithInt: delta]];
        }
    }
    [[self class] refresh];
}

-(void) up: (int64_t) speed {
    if([widgets count]) {
        id widget = [widgets objectAtIndex: highlight];
        if([widget respondsToSelector: @selector(up:)]) {
            [widget up: speed];
        } else {
            [widget up];
        }
        [[self class] refresh];
    }
}

-(void) down: (int64_t) speed {
    if([widgets count]) {
        id widget = [widgets objectAtIndex: highlight];
        if([widget respondsToSelector: @selector(down:)]) {
            [widget down: speed];
        } else {
            [widget down];
        }
        [[self class] refresh];
    }
}

+(void) toggleOptions {
    showOptions = !showOptions;
}

+(BOOL) showOptions {
    return showOptions;
}

-(void) mute {
    if([widgets count]) {
        [(id<Controlling>)[widgets objectAtIndex: highlight] mute];
        [[self class] refresh];
    }
}

-(void) setAsDefault {
    if([widgets count]) {
        [[widgets objectAtIndex: highlight] switchDefault];
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
