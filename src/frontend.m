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


@implementation Channel
-(Channel*) initWithIndex: (int) i
              andMaxLevel: (NSNumber*) mlevel_
             andNormLevel: (NSNumber*) nlevel_
                  andMute: (NSNumber*) mute_
                andSignal: (NSString*) signal_
                andParent: (WINDOW*) parent {
    self = [super init];
    signal = [signal_ copy];
    propagate = YES;
    int mx;
    getmaxyx(parent, my, mx);
    my -= 1;
    win = derwin(parent, my, 1, 0, i + 1);
    if(mute_ != nil) {
        mutable = YES;
    } else {
        mutable = NO;
    }
    if(mlevel_ != nil) {
        maxLevel = [mlevel_ intValue];
        normLevel = [nlevel_ intValue];
        delta = maxLevel / 100;
    }
    [self print];
    return self;
}

-(void) dealloc {
    delwin(win);
    [signal release];
    [super dealloc];
}

-(void) print {
    if(mute) {
        mvwaddch(win, my - 1, 0, ' ' | COLOR_PAIR(4));
    } else {
        mvwaddch(win, my - 1, 0, ' ' | COLOR_PAIR(2));
    }
    int currentPos = my - 1;
    if(mutable) {
        currentPos -= 2;
    }
    float dy = (float)currentPos / (float)maxLevel;
    int limit = dy * currentLevel;
    int high = dy * normLevel;
    int medium = high * (4. / 5.);
    int low = high * (2. / 5.);
    for(int i = 0; i < my - 3; ++i) {
        int color = COLOR_PAIR(2);
        if(i < limit) {
            if(i >= high) {
                color = COLOR_PAIR(5);
            } else if(i >= medium) {
                color = COLOR_PAIR(4);
            } else if(i >= low) {
                color = COLOR_PAIR(3);
            }
        } else {
            color = COLOR_PAIR(1);
        }
        mvwaddch(win, currentPos - i, 0, ' ' | color);
    }
}

-(void) reprint: (int) height {
    my = height - 1;
    wresize(win, my, 1);
    [self print];
}

-(void) adjust: (int) i {
    mvderwin(win, 0, i + 1);
}

-(void) setMute: (BOOL) mute_ {
    if(mutable) {
        mute = mute_;
    }
    [self print];
}

-(void) setLevel: (int) level_ {
    currentLevel = level_;
    [self print];
    if(propagate) {
        NSDictionary *s = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt: currentLevel], @"volume", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName: signal
                                                            object: self
                                                          userInfo: s];
    }
}

-(int) level {
    return currentLevel;
}

-(void) setLevelAndMuteN: (NSNotification*) notification {
    volume_t *info = [[notification userInfo] objectForKey: @"volumes"];
    [self setLevel: [[info level] intValue]
           andMute: [info mute]];
}

-(void) setLevel: (int) level_
         andMute: (BOOL) mute_ {
    currentLevel = level_;
    mute = mute_;
    [self print];
}

-(void) setPropagation: (BOOL) p {
    propagate = p;
}

-(void) inside {
    wattron(win, A_BLINK);
    [self print];
}

-(void) outside {
    wattroff(win, A_BLINK);
    [self print];
}

-(void) up {
    if(currentLevel < maxLevel + delta) {
        [self setLevel: currentLevel + delta];
    } else if(currentLevel < maxLevel) {
        [self setLevel: maxLevel];
    }
}

-(void) down {
    if(currentLevel > delta) {
        [self setLevel: currentLevel - delta];
    } else if(currentLevel > 0) {
        [self setLevel: 0];
    }
}

-(void) moveLeftBy: (int) p {
    int by;
    int bx;
    getbegyx(win, by, bx);
    mvwin(win, by, bx - p);
}

-(void) mute {
    if(mutable) {
        if(mute) {
            [self setMute: NO];
        } else {
            [self setMute: YES];
        }
    }
}

-(BOOL) isMuted {
    return mute;
}
@end


@implementation Channels
-(Channels*) initWithChannels: (NSArray*) channels_
                  andPosition: (int) position_
                        andId: (NSNumber*) id_
                    andParent: (WINDOW*) parent {
    self = [super init];
    highlight = 0;
    position = position_;
    getmaxyx(parent, my, mx);
    my -= 1;
    mx = [channels_ count] + 2;
    hasPeak = NO;
    hasMute = NO;
    for(int i = 0; i < [channels_ count]; ++i) {
        channel_t *obj = [channels_ objectAtIndex: i];
        if([obj maxLevel] != nil) {
            hasPeak = YES;
        }
        if([obj mutable]) {
            hasMute = YES;
        }
        if(hasPeak && hasMute) {
            break;
        }
    }
    if(!hasMute) {
        my -= 2;
    }
    y = 0;
    if(!hasPeak) {
        y = my - 3;
        my = 3;
    }
    win = derwin(parent, my, mx, y, position);
    [self print];
    internalId = [id_ copy];
    channels = [[NSMutableArray alloc] init];
    for(int i = 0; i < [channels_ count]; ++i) {
        channel_t *obj = [channels_ objectAtIndex: i];
        NSNumber *mute;
        if([obj mutable]) {
            mute = [NSNumber numberWithBool: YES];
        } else {
            mute = nil;
        }
        NSString *bname = [NSString stringWithFormat:
            @"%@_%d", id_, i];
        NSString *csignal = [NSString stringWithFormat:
            @"%@%@", @"volumeChanged", bname];
        Channel *channel = [[Channel alloc] initWithIndex: i
                                              andMaxLevel: [obj maxLevel]
                                             andNormLevel: [obj normLevel]
                                                  andMute: mute
                                                andSignal: csignal
                                                andParent: win];
        SEL selector = @selector(setLevelAndMuteN:);
        NSString *nname = [NSString stringWithFormat:
            @"%@%@", @"controlChanged", bname];
        [[NSNotificationCenter defaultCenter] addObserver: channel
                                                 selector: selector
                                                     name: nname
                                                   object: nil];
        [channels addObject: channel];
    }
    return self;
}

-(void) dealloc {
    delwin(win);
    [channels release];
    [internalId release];
    [super dealloc];
}

-(void) print {
    box(win, 0, 0);
    if(hasPeak && hasMute) {
        mvwaddch(win, my - 3, 0, ACS_LTEE);
        mvwhline(win, my - 3, 1, 0, mx - 2);
        mvwaddch(win, my - 3, mx - 1, ACS_RTEE);
    }
}

-(void) reprint: (int) height {
    height -= 1;
    if(!hasMute) {
        height -= 2;
    }
    my = height;
    for(int i = 0; i < [channels count]; ++i) {
        [(Channel*)[channels objectAtIndex: i] reprint: height];
    }
    if(hasPeak) {
        wresize(win, height, mx);
    } else {
        mvderwin(win, height - 4, position);
    }
    [self print];
}

-(void) show {
    [self print];
    for(int i = 0; i < [channels count]; ++i) {
        [(Channel*)[channels objectAtIndex: i] print];
    }
}

-(void) setMute: (BOOL) mute forChannel: (int) channel {
    [(Channel*)[channels objectAtIndex: channel] setMute: mute];
}

-(void) setLevel: (int) level forChannel: (int) channel {
    [(Channel*)[channels objectAtIndex: channel] setLevel: level];
}

-(void) adjust {
    int width = [channels count] + 2;
    mvderwin(win, y, width / 2);
    for(int i = 0; i < [channels count]; ++i) {
        [[channels objectAtIndex: i] adjust: i];
    }
}

-(void) notify: (NSArray*) values {
    NSString *nname = [NSString stringWithFormat:
        @"%@%@", @"volumeChanged", internalId];
    NSDictionary *s = [NSDictionary dictionaryWithObjectsAndKeys:
        values, @"volume", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName: nname
                                                        object: self
                                                      userInfo: s];
}

-(BOOL) previous {
    if(inside && highlight > 0) {
        [(Channel*)[channels objectAtIndex: highlight] outside];
        highlight -= 1;
        [(Channel*)[channels objectAtIndex: highlight] inside];
        return NO;
    }
    return YES;
}

-(BOOL) next {
    if(inside && highlight < [channels count] - 1) {
        [(Channel*)[channels objectAtIndex: highlight] outside];
        highlight += 1;
        [(Channel*)[channels objectAtIndex: highlight] inside];
        return NO;
    }
    return YES;
}

-(void) up {
    if(inside) {
        [(Channel*)[channels objectAtIndex: highlight] up];
    } else {
        int count = [channels count];
        NSMutableArray *values = [NSMutableArray arrayWithCapacity: count];
        for(int i = 0; i < count; ++i) {
            Channel *channel = [channels objectAtIndex: i];
            [channel setPropagation: NO];
            [channel up];
            [values addObject: [NSNumber numberWithInt: [channel level]]];
            [channel setPropagation: YES];
        }
        [self notify: values];
    }
}

-(void) down {
    if(inside) {
        [(Channel*)[channels objectAtIndex: highlight] down];
    } else {
        int count = [channels count];
        NSMutableArray *values = [NSMutableArray arrayWithCapacity: count];
        for(int i = 0; i < count; ++i) {
            Channel *channel = [channels objectAtIndex: i];
            [channel setPropagation: NO];
            [channel down];
            [values addObject: [NSNumber numberWithInt: [channel level]]];
            [channel setPropagation: YES];
        }
        [self notify: values];
    }
}

-(void) inside {
    if(!inside) {
        inside = YES;
        [(Channel*)[channels objectAtIndex: highlight] inside];
    }
}

-(void) outside {
    if(inside) {
        inside = NO;
        [(Channel*)[channels objectAtIndex: highlight] outside];
    }
}

-(void) moveLeftBy: (int) p {
    for(int i = 0; i < [channels count]; ++i) {
        [(Channel*)[channels objectAtIndex: i] moveLeftBy: p];
    }
}

-(void) mute {
    for(int i = 0; i < [channels count]; ++i) {
        [(Channel*)[channels objectAtIndex: i] mute];
    }
    NSString *nname = [NSString stringWithFormat:
        @"%@%@", @"muteChanged", internalId];
    BOOL muted = [(Channel*)[channels objectAtIndex: 0] isMuted];
    NSDictionary *s = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithBool: muted], @"mute", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName: nname
                                                        object: self
                                                      userInfo: s];
}
@end


@implementation Options
-(Options*) initWithOptions: (NSArray*) options_
                  andParent: (WINDOW*) parent {
    self = [super init];
    options = options_;
    highlight = 0;
    int my;
    int mx;
    getmaxyx(parent, my, mx);
    int dy = [options count];
    win = derwin(parent, dy + 2, 8, my - dy - 3, 0);
    box(win, 0, 0);
    [self print];
    return self;
}

-(void) dealloc {
    delwin(win);
    [super dealloc];
}

-(void) print {
    int dy = [options count];
    for(int i = 0; i < dy; ++i) {
        NSString *obj = [options objectAtIndex: i];
        if(i == highlight) {
            wattron(win, COLOR_PAIR(6));
        }
        mvwprintw(win, i + 1, 1, "      ");
        mvwprintw(win, i + 1, 1, "%@", obj);
        wattroff(win, COLOR_PAIR(6));
    }
}

-(void) show {
    [self print];
}

-(void) setCurrent: (int) i {
    highlight = i;
    [self print];
}

-(void) up {
    if(highlight > 0) {
        [self setCurrent: highlight - 1];
    }
}

-(void) down {
    if(highlight < [options count] - 1) {
        [self setCurrent: highlight + 1];
    }
}

-(void) moveLeftBy: (int) p {
    int by;
    int bx;
    getbegyx(win, by, bx);
    mvwin(win, by, bx - p);
}
@end


@implementation Widget
-(Widget*) initWithPosition: (int) p
                    andName: (NSString*) name_
                    andType: (View) type_
                      andId: (NSNumber*) id_
                  andParent: (WINDOW*) parent_ {
    self = [super init];
    highlight = 0;
    controls = [[NSMutableArray alloc] init];
    position = p;
    name = [name_ copy];
    type = type_;
    internalId = [id_ copy];
    parent = parent_;
    width = 8;
    [self print];
    return self;
}

-(void) dealloc {
    [controls release];
    [name release];
    [internalId release];
    delwin(win);
    [super dealloc];
}

-(void) print {
    int mx;
    getmaxyx(parent, height, mx);
    if(position + width > mx) {
        wresize(parent, height, position + width);
    }
    if(win == NULL) {
        win = derwin(parent, height, width, 0, position);
    } else {
        wresize(win, height, width);
    }
}

-(void) reprint: (int) height_ {
    werase(win);
    height = height_;
    for(int i = 0; i < [controls count]; ++i) {
        [[controls objectAtIndex: i] reprint: height];
    }
    wresize(win, height, width);
    [self printName];
}

-(void) printName {
    int color;
    if(highlighted) {
        color = COLOR_PAIR(6);
    } else {
        color = COLOR_PAIR(5);
    }
    int length = (width - [name length]) / 2;
    if(length < 0) {
        length = 0;
    }
    wattron(win, color | A_BOLD);
    mvwprintw(win, height - 1, 0, "      ");
    mvwprintw(win, height - 1, 0, "%@",
        [@"" stringByPaddingToLength: width
                          withString: @" "
                     startingAtIndex: 0]
    );
    mvwprintw(win, height - 1, length, "%@", name);
    wattroff(win, color | A_BOLD);
}

-(void) show {
    [self printName];
    for(int i = 0; i < [controls count]; ++i) {
        [[controls objectAtIndex: i] show];
    }
}

-(void) hide {
    werase(win);
}

-(Channels*) addChannels: (NSArray*) channels {
    int width_ = [channels count] + 2;
    int position_ = (width - width_) / 2;
    if(width_ > 8) {
        width = width_;
        [self print];
        [self printName];
    }
    Channels *control = [[Channels alloc] initWithChannels: channels
                                               andPosition: position_
                                                     andId: internalId
                                                 andParent: win];
    [controls addObject: control];
    [control release];
    return control;
}

-(Options*) addOptions: (NSArray*) options {
    Options *control = [[Options alloc] initWithOptions: options
                                              andParent: win];
    [controls addObject: control];
    [control release];
    return control;
}

-(void) setHighlighted: (BOOL) active {
    highlighted = active;
    [self printName];
}

-(void) setPosition: (int) position_ {
    position = position_;
    mvderwin(win, 0, position);
    for(int i = 0; i < [controls count]; ++i) {
        [[controls objectAtIndex: i] adjust];
    }
}

-(BOOL) canGoInside {
    BOOL can = NO;
    for(int i = 0; i < [controls count]; ++i) {
        id control = [controls objectAtIndex: i];
        if([control respondsToSelector:@selector(previous)] ||
           [control respondsToSelector:@selector(next)]) {
            can = YES;
            break;
        }
    }
    return can;
}

-(void) inside {
    if(!inside) {
        inside = YES;
        [[controls objectAtIndex: highlight] inside];
    }
}

-(void) outside {
    if(inside) {
        inside = NO;
        [[controls objectAtIndex: highlight] outside];
    }
}

-(void) previous {
    if(inside) {
        BOOL end = [[controls objectAtIndex: highlight] previous];
        while(end) {
            if(highlight == 0) {
                break;
            }
            highlight -= 1;
            end = [[controls objectAtIndex: highlight] previous];
        }
    }
}

-(void) next {
    if(inside) {
        BOOL end = [[controls objectAtIndex: highlight] next];
        while(end) {
            if(highlight == [controls count] - 1) {
                break;
            }
            highlight += 1;
            end = [[controls objectAtIndex: highlight] next];
        }
    }
}

-(void) up {
    if(inside) {
        [[controls objectAtIndex: highlight] up];
    } else {
        for(int i = 0; i < [controls count]; ++i) {
            [[controls objectAtIndex: i] up];
        }
    }
}

-(void) down {
    if(inside) {
        [[controls objectAtIndex: highlight] down];
    } else {
        for(int i = 0; i < [controls count]; ++i) {
            [[controls objectAtIndex: i] down];
        }
    }
}

-(void) mute {
    for(int i = 0; i < [controls count]; ++i) {
        id obj = [controls objectAtIndex: i];
        if([obj respondsToSelector: @selector(mute)]) {
            [obj mute];
        }
    }
}

-(void) moveLeftBy: (int) p {
    position -= p;
    mvwin(win, 2, position);
    for(int i = 0; i < [controls count]; ++i) {
        [[controls objectAtIndex: i] moveLeftBy: p];
    }
    [self printName];
}

-(int) height {
    return height;
}

-(int) width {
    return width;
}

-(int) endPosition {
    return position + width;
}

-(View) type {
    return type;
}

-(NSString*) name {
    return name;
}

-(NSNumber*) internalId {
    return internalId;
}
@end


@implementation Top
-(Top*) init {
    self = [super init];
    view = ALL;
    int my;
    int mx;
    getmaxyx(stdscr, my, mx);
    win = newwin(1, mx, 0, 0);
    [self print];
    return self;
}

-(void) dealloc {
    delwin(win);
    [super dealloc];
}

-(void) print {
    wmove(win, 0, 0);
    NSString *all = @"F1: All";
    NSString *playback = @"F2: Playback";
    NSString *recording = @"F3: Recording";
    NSString *outputs = @"F4: Outputs";
    NSString *inputs = @"F5: Inputs";
    if(view == ALL) {
        wprintw(win, " [%@] ", all);
    } else {
        wprintw(win, " %@ ", all);
    }
    if(view == PLAYBACK) {
        wprintw(win, " [%@] ", playback);
    } else {
        wprintw(win, " %@ ", playback);
    }
    if(view == RECORDING) {
        wprintw(win, " [%@] ", recording);
    } else {
        wprintw(win, " %@ ", recording);
    }
    if(view == OUTPUTS) {
        wprintw(win, " [%@] ", outputs);
    } else {
        wprintw(win, " %@ ", outputs);
    }
    if(view == INPUTS) {
        wprintw(win, " [%@] ", inputs);
    } else {
        wprintw(win, " %@ ", inputs);
    }
    wrefresh(win);
}

-(void) reprint {
    int my;
    int mx;
    getmaxyx(stdscr, my, mx);
    wresize(win, 1, mx);
    [self print];
}

-(void) setView: (View) type_ {
    view = type_;
    [self print];
}

-(View) view {
    return view;
}
@end


@implementation Bottom
-(Bottom*) init {
    self = [super init];
    int my;
    int mx;
    getmaxyx(stdscr, my, mx);
    win = newwin(1, mx, my - 1, 0);
    mode = OUTSIDE;
    [self print];
    return self;
}

-(void) dealloc {
    delwin(win);
    [super dealloc];
}

-(void) print {
    NSString *line;
    char mode_ = 'o';
    int color = COLOR_PAIR(6);
    if(mode == OUTSIDE) {
        line =
            @" i: inside mode, "
            @"h/l: previous/next control, "
            @"j/k: volume down/up or previous/next option, "
            @"m: (un)mute, "
            @"q: Exit";
    } else if(mode == INSIDE) {
        line =
            @" q: outside mode, "
            @"h/l: previous/next channel, "
            @"j/k: volume down/up, "
            @"m: (un)mute";
        mode_ = 'i';
        color = COLOR_PAIR(7);
    } else {
        line = @"";
        mode_ = '?';
    }
    werase(win);
    wattron(win, color | A_BOLD);
    wprintw(win, " %c ", mode_);
    wattroff(win, color | A_BOLD);
    wprintw(win, "%@", line);
    wrefresh(win);
}

-(void) reprint {
    werase(win);
    wrefresh(win);
    int my;
    int mx;
    getmaxyx(stdscr, my, mx);
    mvwin(win, my - 1, 0);
    wresize(win, 1, mx);
    [self print];
}

-(void) inside {
    if(mode == OUTSIDE) {
        mode = INSIDE;
        [self print];
    }
}

-(BOOL) outside {
    if(mode == INSIDE) {
        mode = OUTSIDE;
        [self print];
        return NO;
    }
    return YES;
}
@end


@implementation TUI
-(TUI*) init {
    self = [super init];
    allWidgets = [[NSMutableArray alloc] init];
    widgets = [[NSMutableArray alloc] init];
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
    delwin(win);
    endwin();
    [bottom release];
    [top release];
    [widgets release];
    [allWidgets release];
    [paddingStates release];
    [super dealloc];
}

-(void) reprint {
    int my;
    int mx;
    getmaxyx(stdscr, my, mx);
    int yy;
    getmaxyx(win, yy, mx);
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
                       andId: (NSNumber*) id_ {
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
    int width = 0;
    NSArray *copy = [widgets copy];
    for(int i = 0; i < [copy count]; ++i) {
        id widget = [copy objectAtIndex: i];
        if([[widget internalId] isEqualToNumber: id_]) {
            width = [widget width];
            [widgets removeObjectAtIndex: i];
        } else if(width) {
            [widget moveLeftBy: width + 1];
            width = [widget width];
        }
    }
    [copy release];
    id widget = [widgets lastObject];
    int start = [widget endPosition];
    for(int i = 0; i < [widget height]; ++i) {
        move(i + 2, start);
        for(int j = 0; j < [widget width] + 1; ++j) {
            addch(' ');
        }
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
        [[widgets objectAtIndex: highlight] setHighlighted: NO];
    }
    [widgets removeAllObjects];
    int x = 1;
    for(int i = 0; i < [allWidgets count]; ++i) {
        Widget *w = [allWidgets objectAtIndex: i];
        if([top view] == ALL || [w type] == [top view]) {
            [widgets addObject: w];
            if([w endPosition] > x) {
                [w hide];
            }
            [w setPosition: x];
            [w show];
            x = [w endPosition] + 1;
        } else if([w endPosition] > x) {
            [w hide];
        }
    }
    highlight = 0;
    if([widgets count]) {
        [[widgets objectAtIndex: highlight] setHighlighted: YES];
    }
    [self refresh: nil];
}

-(void) previous {
    if(inside) {
        [[widgets objectAtIndex: highlight] previous];
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
        [[widgets objectAtIndex: highlight] next];
    } else if(highlight < (int)[widgets count] - 1) {
        int start = [[widgets objectAtIndex: highlight] endPosition];
        [self setCurrent: highlight + 1];
        Widget *w = [widgets objectAtIndex: highlight];
        int my;
        int mx;
        getmaxyx(stdscr, my, mx);
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
    [[widgets objectAtIndex: highlight] mute];
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
