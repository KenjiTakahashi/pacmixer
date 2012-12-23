// This is a part of pacmixer @ http://github.com/KenjiTakahashi/pacmixer
// Karol "Kenji Takahashi" Woźniak © 2012
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
    padding = 0;
    paddingStates = [[NSMutableArray alloc] init];
    bottom = [[Bottom alloc] init];
    top = [[Top alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(refresh:)
                                                 name: nil
                                               object: nil];
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
    [paddingStates release];
    [super dealloc];
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
    [self refresh: nil];
}

-(void) refresh: (NSNotification*) notification {
    int my;
    int mx;
    getmaxyx(stdscr, my, mx);
    prefresh(win, 0, padding, 2, 1, my - 2, mx - 1);
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
    if(x == 1) {
        [widget setHighlighted: YES];
    }
    [allWidgets addObject: widget];
    if([top view] == ALL || type == [top view]) {
        [widgets addObject: widget];
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
            [allWidgets removeObject: widget];
#ifdef DEBUG
debug_fprintf(__func__, "f:%d removed at index %d", [id_ intValue], i);
#endif
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
    int x = 1;
    for(int i = 0; i < [widgets count]; ++i) {
        Widget *w = [widgets objectAtIndex: i];
        [w setPosition: x];
        [w show];
        x = [w endPosition] + 1;
    }
    if([widgets count]) {
        [[widgets objectAtIndex: highlight] setHighlighted: YES];
    }
    [self refresh: nil];
}

-(void) setCurrent: (int) i {
    [[widgets objectAtIndex: highlight] setHighlighted: NO];
    highlight = i;
    [[widgets objectAtIndex: highlight] setHighlighted: YES];
}

-(void) setFilter: (View) type {
    [top setView: type];
    if([widgets count]) {
        id widget = [widgets objectAtIndex: highlight];
        if([widget respondsToSelector: @selector(setHighlighted:)]) {
            [widget setHighlighted: NO];
        }
    }
    wclear(win);
    [widgets removeAllObjects];
    int x = 1;
    for(int i = 0; i < [allWidgets count]; ++i) {
        Widget *w = [allWidgets objectAtIndex: i];
        if([top view] == ALL || [w type] == [top view]) {
            [widgets addObject: w];
            [w setPosition: x];
            [w show];
            x = [w endPosition] + 1;
        } else {
            [w hide];
        }
    }
    highlight = 0;
    if([widgets count]) {
        [[widgets objectAtIndex: highlight] setHighlighted: YES];
    }
    [self refresh: nil];
}

-(void) showSettings {
    [top setView: SETTINGS];
    wclear(win);
    [widgets removeAllObjects];
    SettingsWidget *sw = [[SettingsWidget alloc] initWithSettings: settings
                                                        andParent: win];
    [widgets addObject: sw];
    [sw release];
    [self refresh: nil];
}

-(void) previous {
    if(inside) {
        [(id<Controlling>)[widgets objectAtIndex: highlight] previous];
    } else if(highlight > 0) {
        [self setCurrent: highlight - 1];
        Widget *w = [widgets objectAtIndex: highlight];
        if([w endPosition] - [w width] <= padding) {
            int count = [paddingStates count] - 1;
            int delta = [[paddingStates objectAtIndex: count] intValue];
            [paddingStates removeObjectAtIndex: count];
            padding -= delta;
        }
    }
    [self refresh: nil];
}

-(void) next {
    if(inside) {
        [(id<Controlling>)[widgets objectAtIndex: highlight] next];
    } else if(highlight < (int)[widgets count] - 1) {
        int start = [[widgets objectAtIndex: highlight] endPosition];
        [self setCurrent: highlight + 1];
        Widget *w = [widgets objectAtIndex: highlight];
        int mx = getmaxx(stdscr);
        if([w endPosition] - padding >= mx) {
            int delta = [w width] - (mx - start - 3 + padding);
            padding += delta;
            [paddingStates addObject: [NSNumber numberWithInt: delta]];
        }
    }
    [self refresh: nil];
}

-(void) up {
    [[widgets objectAtIndex: highlight] up];
}

-(void) down {
    [[widgets objectAtIndex: highlight] down];
}

-(void) mute {
    [(id<Controlling>)[widgets objectAtIndex: highlight] mute];
}

-(void) inside {
    if([widgets count]) {
        Widget *widget = [widgets objectAtIndex: highlight];
        if([widget canGoInside]) {
            inside = YES;
            [bottom inside];
            [[widgets objectAtIndex: highlight] inside];
        }
        [self refresh: nil];
    }
}

-(BOOL) outside {
    BOOL outside = [bottom outside];
    if(!outside) {
        inside = NO;
        Widget *widget = [widgets objectAtIndex: highlight];
        [widget outside];
        [self refresh: nil];
    }
    return outside;
}
@end
