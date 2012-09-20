#import "main.h"


@implementation Dispatcher
-(Dispatcher*) init {
    self = [super init];
    pool = [[NSAutoreleasePool alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(addWidget:)
                                                 name: @"controlAppeared"
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(removeWidget:)
                                                 name: @"controlDisappeared"
                                               object: nil];
    tui = [[TUI alloc] init];
    middleware = [[Middleware alloc] init];
    //[middleware run];
    return self;
}

-(void) dealloc {
    [tui release];
    [middleware release];
    [pool drain];
    [super dealloc];
}

-(void) addWidget: (NSNotification*) notification {
    NSDictionary *info = [notification userInfo];
    Widget *w = [tui addWidgetWithName: [info objectForKey: @"name"]];
    NSArray *channels = [info objectForKey: @"channels"];
    if(channels != nil) {
        [w addChannels: channels];
    }
    NSArray *options = [info objectForKey: @"options"];
    if(options != nil) {
        [w addOptions: options];
    }
}

-(void) removeWidget: (NSNotification*) notification {
    NSDictionary *info = [notification userInfo];
    [tui removeWidget: [info objectForKey: @"name"]];
}

-(void) run {
    int ch;
    BOOL quit = NO;
    while(!quit) {
        ch = getch();
        switch(ch) {
            case 27:
            case 'q':
                quit = [tui outside];
                break;
            case 'h':
            case KEY_LEFT:
                [tui previous];
                break;
            case 'l':
            case KEY_RIGHT:
                [tui next];
                break;
            case 'k':
            case KEY_UP:
                [tui up];
                break;
            case 'j':
            case KEY_DOWN:
                [tui down];
                break;
            case 'm':
                [tui mute];
                break;
            case 'i':
                [tui inside];
                break;
        }
    }
}
@end


int main(int argc, char const *argv[]) {
    Dispatcher *dispatcher = [[Dispatcher alloc] init];
    [dispatcher run];
    [dispatcher release];
    return 0;
}
