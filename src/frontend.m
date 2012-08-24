#import "frontend.h"


@implementation Channel
-(Channel*) initWithIndex: (int) i
                andParent: (WINDOW*) parent {
    self = [super init];
    int mx;
    getmaxyx(parent, my, mx);
    win = derwin(parent, my, 1, 0, i + 1);
    wbkgd(win, COLOR_PAIR(2));
    return self;
}

-(Channel*) initWithIndex: (int) i
                  andMute: (bool) mute_
                andParent: (WINDOW*) parent {
    self = [self initWithIndex: i andParent: parent];
    mvwaddch(win, my - 3, 0, ACS_HLINE | COLOR_PAIR(1));
    [self setMute: mute_];
    return self;
}

-(void) dealloc {
    delwin(win);
    [super dealloc];
}

-(void) setMute: (bool) mute_ {
    mute = mute_;
    if(mute) {
        mvwaddch(win, my - 2, 0, ' ' | COLOR_PAIR(4));
    } else {
        mvwaddch(win, my - 2, 0, ' ' | COLOR_PAIR(1));
        mvwaddch(win, my - 2, 0, ' ' | COLOR_PAIR(2));
    }
}
@end


@implementation Widget
-(Widget*) initWithPosition: (int) p andChannels: (int) channels {
    self = [super init];
    controls = [[NSMutableArray alloc] init];
    position = p;
    int my;
    int mx;
    getmaxyx(stdscr, my, mx);
    int y = 10; // FIXME: change this to actual header size
    height = my - y - 2;
    width = channels + 2;
    win = newwin(height, width, y, p);
    for(int i = 0; i < channels; ++i) {
        Channel *control = [[Channel alloc] initWithIndex: i
                                                  andMute: true
                                                andParent: win];
        [controls addObject: control];
    }
    [[controls objectAtIndex: 0] setMute: false];
    // TODO: create different (i.e. combobox) controls.
    // TODO: box will go outside, widget is merely for name and
    // and other controls storage (we want it to be at least 2ch wide).
    box(win, 0, 0);
    // TODO: tees at correct positions
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
    wprintw(win, "%s", [inside UTF8String]);
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
    wprintw(win, "%s", [outside UTF8String]);
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
    Widget *widget = [[Widget alloc] initWithPosition: x andChannels: channels];
    [widgets addObject: widget];
}
@end
