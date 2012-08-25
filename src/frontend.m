#import "frontend.h"


@implementation channel_t
-(channel_t*) initWithMaxLevel: (int) maxLevel_
                    andMutable: (BOOL) mutable_ {
    self = [super init];
    maxLevel = maxLevel_;
    mutable = mutable_;
    return self;
}

-(int) maxLevel {
    return maxLevel;
}

-(BOOL) mutable {
    return mutable;
}
@end


@implementation Channel
-(Channel*) initWithIndex: (int) i
              andMaxLevel: (NSNumber*) mlevel_
                  andMute: (NSNumber*) mute_
                andParent: (WINDOW*) parent {
    self = [super init];
    int mx;
    getmaxyx(parent, my, mx);
    my -= 1;
    win = derwin(parent, my, 1, 0, i + 1);
    if(mute_ != nil) {
        mutable = YES;
        mvwaddch(win, my - 2, 0, ACS_HLINE | COLOR_PAIR(1));
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
    mute = mute_;
    if(mute) {
        mvwaddch(win, my - 1, 0, ' ' | COLOR_PAIR(4));
    } else {
        mvwaddch(win, my - 1, 0, ' ' | COLOR_PAIR(2));
    }
}

-(void) setLevel: (int) level_ {
    currentLevel = level_;
    int currentPos = my - 1;
    if(mutable) {
        currentPos -= 2;
    }
    float dy = (float)currentPos / (float)maxLevel;
    int limit = dy * currentLevel;
    int high = dy * 100; // FIXME: 100% might not be at 100
    int medium = high * (4. / 5.);
    int low = high * (2. / 5.);
    for(int i = 0; i < limit; ++i) {
        int color = COLOR_PAIR(2);
        if(i >= high) {
            color = COLOR_PAIR(5);
        } else if(i >= medium) {
            color = COLOR_PAIR(4);
        } else if(i >= low) {
            color = COLOR_PAIR(3);
        }
        mvwaddch(win, currentPos - i, 0, ' ' | color);
    }
}
@end


@implementation Channels
-(Channels*) initWithChannels: (NSArray*) channels_
                    andParent: (WINDOW*) parent {
    self = [super init];
    int my;
    int mx;
    getmaxyx(parent, my, mx);
    my -= 1;
    win = derwin(parent, my, [channels_ count] + 2, 0, 1);
    box(win, 0, 0);
    channels = [[NSMutableArray alloc] init];
    for(int i = 0; i < [channels_ count]; ++i) {
        channel_t *obj = [channels_ objectAtIndex: i];
        NSNumber *level = [NSNumber numberWithInt: 100]; // FIXME
        NSNumber *mlevel = [NSNumber numberWithInt: [obj maxLevel]];
        NSNumber *mute = [NSNumber numberWithBool: [obj mutable]];
        Channel *channel = [[Channel alloc] initWithIndex: i
                                              andMaxLevel: mlevel
                                                  andMute: mute
                                                andParent: win];
        [channel setLevel: 100];
        [channels addObject: channel];
    }
    // TODO: tees at correct positions
    // FIXME: remove settings below, they're here for testing purposes
    [[channels objectAtIndex: 0] setMute: false];
    [[channels objectAtIndex: 0] setLevel: 130];
    touchwin(parent);
    wrefresh(win);
    return self;
}

-(void) dealloc {
    delwin(win);
    [channels release];
    [super dealloc];
}
@end


@implementation Widget
-(Widget*) initWithPosition: (int) p
                    andName: (NSString*) name_ {
    self = [super init];
    controls = [[NSMutableArray alloc] init];
    position = p;
    name = name_;
    int my;
    int mx;
    getmaxyx(stdscr, my, mx);
    int y = 10; // FIXME: change this to actual header size
    height = my - y - 2;
    width = 6;
    win = newwin(height, width, y, p);
    int length = (width - [name length]) / 2;
    if(length < 0) {
        length = 0;
    }
    wattron(win, COLOR_PAIR(5));
    mvwprintw(win, height - 1, 0, "      ");
    mvwprintw(win, height - 1, length, "%@", name);
    wattroff(win, COLOR_PAIR(5));
    wrefresh(win);
    return self;
}

-(void) dealloc {
    delwin(win);
    [controls release];
    [super dealloc];
}

-(void) addChannels: (NSArray*) channels {
    width = [channels count] + 4;
    if(width < 6) {
        width = 6;
    }
    Channels* control = [[Channels alloc] initWithChannels: channels
                                                 andParent: win];
    [controls addObject: control];
    wrefresh(win);
}

-(int) endPosition {
    return position + width;
}
@end


@implementation Top
-(Top*) init {
    self = [super init];
    pool = [[NSAutoreleasePool alloc] init];
    int my;
    int mx;
    getmaxyx(stdscr, my, mx);
    NSString *inside = [NSString stringWithString: @"Card: <NA>\n"
                                                   @"Chip:"];
    win = newwin(10, mx, 0, 0);
    wprintw(win, "%@", inside);
    wrefresh(win);
    return self;
}

-(void) dealloc {
    [pool release];
    delwin(win);
    [super dealloc];
}
@end


@implementation Bottom
-(Bottom*) init {
    self = [super init];
    pool = [[NSAutoreleasePool alloc] init];
    int my;
    int mx;
    getmaxyx(stdscr, my, mx);
    NSString *outside = [NSString stringWithString: @"F1: Help "
                                                    @"F2: System Information "
                                                    @"Esc: Exit"];
    win = newwin(1, mx, my - 1, 0);
    wprintw(win, "%@", outside);
    wrefresh(win);
    return self;
}

-(void) dealloc {
    [pool release];
    delwin(win);
    [super dealloc];
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
    init_pair(5, -1, COLOR_MAGENTA); // extreme (>100%) level volume
    refresh();
    top = [[Top alloc] init];
    bottom = [[Bottom alloc] init];
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
    int x = [[widgets lastObject] endPosition];
    Widget *widget = [[Widget alloc] initWithPosition: x
                                              andName: name];
    [widgets addObject: widget];
    return widget;
}
@end
