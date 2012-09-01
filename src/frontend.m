#import "frontend.h"


@implementation Channel
-(Channel*) initWithIndex: (int) i
              andMaxLevel: (NSNumber*) mlevel_
                  andMute: (NSNumber*) mute_
             andPrintMute: (BOOL) printMute_
                andParent: (WINDOW*) parent {
    self = [super init];
    int mx;
    printMute = printMute_;
    getmaxyx(parent, my, mx);
    my -= 1;
    win = derwin(parent, my, 1, 0, i + 1);
    if(mute_ != nil) {
        mutable = YES;
        [self setMute: [mute_ boolValue]];
    } else {
        mutable = NO;
    }
    if(mlevel_ != nil) {
        maxLevel = [mlevel_ intValue];
    }
    return self;
}

-(void) dealloc {
    delwin(win);
    [super dealloc];
}

-(void) setMute: (BOOL) mute_ {
    if(mutable) {
        mute = mute_;
        if(mute) {
            mvwaddch(win, my - 1, 0, ' ' | COLOR_PAIR(4));
        } else {
            mvwaddch(win, my - 1, 0, ' ' | COLOR_PAIR(2));
        }
    }
    wrefresh(win);
}

-(void) setLevel: (int) level_ {
    currentLevel = level_;
    int currentPos = my - 1;
    if(printMute) {
        currentPos -= 2;
    }
    float dy = (float)currentPos / (float)maxLevel;
    int limit = dy * currentLevel;
    int high = dy * 100; // FIXME: 100% might not be at 100
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
    wrefresh(win);
}

-(void) up {
    if(currentLevel < maxLevel) {
        [self setLevel: currentLevel + 1];
    }
}

-(void) down {
    if(currentLevel > 0) { // TODO: is minLevel always == 0?
        [self setLevel: currentLevel - 1];
    }
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
@end


@implementation Channels
-(Channels*) initWithChannels: (NSArray*) channels_
                  andPosition: (int) position
                    andParent: (WINDOW*) parent {
    self = [super init];
    int my;
    int mx;
    getmaxyx(parent, my, mx);
    my -= 1;
    mx = [channels_ count] + 2;
    BOOL hasPeak = NO;
    BOOL hasMute = NO;
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
    int y = 0;
    if(!hasPeak) {
        y = my - 3;
        my = 3;
    }
    win = derwin(parent, my, mx, y, position);
    box(win, 0, 0);
    if(hasPeak && hasMute) {
        mvwaddch(win, my - 3, 0, ACS_LTEE);
        mvwhline(win, my - 3, 1, 0, mx - 2);
        mvwaddch(win, my - 3, mx - 1, ACS_RTEE);
    }
    channels = [[NSMutableArray alloc] init];
    for(int i = 0; i < [channels_ count]; ++i) {
        channel_t *obj = [channels_ objectAtIndex: i];
        NSNumber *mute;
        if([obj mutable]) {
            mute = [NSNumber numberWithBool: YES];
        } else {
            mute = nil;
        }
        Channel *channel = [[Channel alloc] initWithIndex: i
                                              andMaxLevel: [obj maxLevel]
                                                  andMute: mute
                                             andPrintMute: hasMute
                                                andParent: win];
        NSNumber *level = [NSNumber numberWithInt: 100]; // FIXME
        [channel setLevel: 100];
        [channels addObject: channel];
    }
    touchwin(parent);
    wrefresh(win);
    return self;
}

-(void) dealloc {
    delwin(win);
    [channels release];
    [super dealloc];
}

-(void) setMute: (BOOL) mute {
    for(int i = 0; i < [channels count]; ++i) {
        [self setMute: mute forChannel: i];
    }
}

-(void) setLevel: (int) level {
    for(int i = 0; i < [channels count]; ++i) {
        [self setLevel: level forChannel: i];
    }
}

-(void) setMute: (BOOL) mute forChannel: (int) channel {
    [[channels objectAtIndex: channel] setMute: mute];
}

-(void) setLevel: (int) level forChannel: (int) channel {
    [[channels objectAtIndex: channel] setLevel: level];
}

-(void) up {
    for(int i = 0; i < [channels count]; ++i) {
        [[channels objectAtIndex: i] up];
    }
}

-(void) down {
    for(int i = 0; i < [channels count]; ++i) {
        [[channels objectAtIndex: i] down];
    }
}

-(void) mute {
    for(int i = 0; i < [channels count]; ++i) {
        [[channels objectAtIndex: i] mute];
    }
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
    wrefresh(win);
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
@end


@implementation Widget
-(Widget*) initWithPosition: (int) p
                    andName: (NSString*) name_ {
    self = [super init];
    controls = [[NSMutableArray alloc] init];
    position = p;
    name = name_;
    [self printWithWidth: 8];
    wrefresh(win);
    return self;
}

-(void) dealloc {
    delwin(win);
    [controls release];
    [super dealloc];
}

-(void) printWithWidth: (int) width_ {
    width = width_;
    int my;
    int mx;
    getmaxyx(stdscr, my, mx);
    height = my - 4;
    if(win == NULL) {
        win = newwin(height, width, 2, position);
    } else {
        wresize(win, height, width);
    }
    [self printName];
}

-(void) printName {
    int color;
    if(highlight) {
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

-(Channels*) addChannels: (NSArray*) channels {
    int width_ = [channels count] + 2;
    if(width_ > 8) {
        [self printWithWidth: width_];
    }
    int position_ = (width - width_) / 2;
    Channels *control = [[Channels alloc] initWithChannels: channels
                                               andPosition: position_
                                                 andParent: win];
    [controls addObject: control];
    [control release];
    wrefresh(win);
    return control;
}

-(Options*) addOptions: (NSArray*) options {
    Options *control = [[Options alloc] initWithOptions: options
                                            andParent: win];
    [controls addObject: control];
    [control release];
    wrefresh(win);
    return control;
}

-(void) setHighlight: (BOOL) active {
    highlight = active;
    [self printName];
    wrefresh(win);
}

-(void) up {
    for(int i = 0; i < [controls count]; ++i) {
        [[controls objectAtIndex: i] up];
    }
}

-(void) down {
    for(int i = 0; i < [controls count]; ++i) {
        [[controls objectAtIndex: i] down];
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

-(int) endPosition {
    return position + width;
}
@end


@implementation Top
-(Top*) init {
    self = [super init];
    view = PLAYBACK;
    int my;
    int mx;
    getmaxyx(stdscr, my, mx);
    win = newwin(10, mx, 0, 0);
    [self print];
    return self;
}

-(void) dealloc {
    delwin(win);
    [super dealloc];
}

-(void) print {
    NSString *playback = @"F2: Playback";
    NSString *recording = @"F3: Recording";
    NSString *outputs = @"F4: Outputs";
    NSString *inputs = @"F5: Inputs";
    // FIXME: refactor this
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
            @"j/k: volume down/up or previous/next option, "
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
    bottom = [[Bottom alloc] init];
    top = [[Top alloc] init];
    return self;
}

-(void) dealloc {
    endwin();
    [bottom release];
    [top release];
    [widgets release];
    [super dealloc];
}

-(Widget*) addWidgetWithName: (NSString*) name {
    int x = [[widgets lastObject] endPosition] + 1;
    Widget *widget = [[Widget alloc] initWithPosition: x
                                              andName: name];
    if(x == 1) {
        [widget setHighlight: YES];
    }
    [widgets addObject: widget];
    [widget release];
    return widget;
}

-(void) setCurrent: (int) i {
    [[widgets objectAtIndex: highlight] setHighlight: NO];
    highlight = i;
    [[widgets objectAtIndex: highlight] setHighlight: YES];
}

-(void) previous {
    if(highlight > 0) {
        [self setCurrent: highlight - 1];
    }
}

-(void) next {
    if(highlight < [widgets count] - 1) {
        [self setCurrent: highlight + 1];
    }
}

-(void) up {
    [[widgets objectAtIndex: highlight] up];
}

-(void) down {
    [[widgets objectAtIndex: highlight] down];
}

-(void) upMore {
}

-(void) downMore {
}

-(void) mute {
    [[widgets objectAtIndex: highlight] mute];
}

-(void) inside {
    [bottom inside];
}

-(BOOL) outside {
    return [bottom outside];
}
@end
