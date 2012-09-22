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
    NSNumber *id_ = [info objectForKey: @"id"];
    Widget *w = [tui addWidgetWithName: [info objectForKey: @"name"]
                                 andId: id_];
    NSArray *channels = [info objectForKey: @"channels"];
    if(channels != nil) {
        Channels *channelsW = [w addChannels: channels];
        NSString *nname = [NSString stringWithFormat:
            @"%@%@", @"controlChanged", id_];
        SEL selector = @selector(setLevelsAndMutesN:);
        [[NSNotificationCenter defaultCenter] addObserver: channelsW
                                                 selector: selector
                                                     name: nname
                                                   object: nil];
    }
    NSArray *options = [info objectForKey: @"options"];
    if(options != nil) {
        [w addOptions: options];
    }
}

-(void) removeWidget: (NSNotification*) notification {
    NSDictionary *info = [notification userInfo];
    [tui removeWidget: [info objectForKey: @"id"]];
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
