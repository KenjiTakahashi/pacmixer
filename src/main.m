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
    NSNumber *typen = [info objectForKey: @"type"];
    backend_entry_type typeb = [typen intValue];
    View type;
    switch(typeb) {
        case SINK:
            type = INPUTS;
            break;
        case SINK_INPUT:
            type = PLAYBACK;
            break;
        case SOURCE:
            type = OUTPUTS;
            break;
        case SOURCE_OUTPUT:
            type = RECORDING;
            break;
        default:
            type = ALL;
            break;
    }
    NSString *name = [info objectForKey: @"name"];
    Widget *w = [tui addWidgetWithName: name
                               andType: type
                                 andId: id_];
#ifdef DEBUG
FILE *f = fopen(debug_filename, "a");
fprintf(f, "%s(%s):d:%d:%s passed\n", __TIME__, __func__, [id_ intValue], [name UTF8String]);
fclose(f);
#endif
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
            case KEY_F(1):
            case '1':
                [tui setFilter: ALL];
                break;
            case KEY_F(2):
            case '2':
                [tui setFilter: PLAYBACK];
                break;
            case KEY_F(3):
            case '3':
                [tui setFilter: RECORDING];
                break;
            case KEY_F(4):
            case '4':
                [tui setFilter: OUTPUTS];
                break;
            case KEY_F(5):
            case '5':
                [tui setFilter: INPUTS];
                break;
            case KEY_RESIZE:
                [tui reprint];
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
