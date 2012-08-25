#import "frontend.h"


@implementation Channel
-(Channel*) initWithIndex: (int) i
                 andLevel: (NSNumber*) level_
                  andMute: (NSNumber*) mute_
                andParent: (WINDOW*) parent {
    self = [super init];
    int mx;
    getmaxyx(parent, my, mx);
    my -= 1;
    win = derwin(parent, my, 1, 0, i + 1);
    if(mute_ != nil) {
        mvwaddch(win, my - 2, 0, ACS_HLINE | COLOR_PAIR(1));
        [self setMute: [mute_ boolValue]];
    }
    if(level_ != nil) {
        [self setLevel: level_];
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

-(void) setLevel: (NSNumber*) level_ {
    level = level_;
}
@end


@implementation Channels
-(Channels*) initWithChannels: (int) channels_
                    andParent: (WINDOW*) parent {
    self = [super init];
    int my;
    int mx;
    getmaxyx(parent, my, mx);
    my -= 1;
    win = derwin(parent, my, channels_ + 2, 0, 1);
    box(win, 0, 0);
    channels = [[NSMutableArray alloc] init];
    for(int i = 0; i < channels_; ++i) {
        NSNumber* level = [NSNumber numberWithInt: 100];
        NSNumber* mute = [NSNumber numberWithBool: YES];
        Channel *channel = [[Channel alloc] initWithIndex: i
                                                 andLevel: level
                                                  andMute: mute
                                                andParent: win];
        [channels addObject: channel];
    }
    // TODO: tees at correct positions
    [[channels objectAtIndex: 0] setMute: false];
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
                    andName: (NSString*) name_
                andChannels: (int) channels {
    self = [super init];
    controls = [[NSMutableArray alloc] init];
    position = p;
    name = name_;
    int my;
    int mx;
    getmaxyx(stdscr, my, mx);
    int y = 10; // FIXME: change this to actual header size
    height = my - y - 2;
    width = channels + 4;
    if(width < 6) {
        width = 6;
    }
    win = newwin(height, width, y, p);
    Channels* control = [[Channels alloc] initWithChannels: channels
                                                 andParent: win];
    [controls addObject: control];
    // TODO: create different (i.e. combobox) controls.
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
    [widgets release];
    [super dealloc];
}

-(void) addWidgetWithChannels: (int) channels {
    int x = [[widgets lastObject] endPosition];
    Widget *widget = [[Widget alloc] initWithPosition: x
                                              andName: @"test"
                                          andChannels: channels];
    [widgets addObject: widget];
}
@end
