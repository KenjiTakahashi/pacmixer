// This is a part of pacmixer @ http://github.com/KenjiTakahashi/pacmixer
// Karol "Kenji Takahashi" Woźniak © 2012 - 2013
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
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver: self
               selector: @selector(addWidget:)
                   name: @"controlAppeared"
                 object: nil];
    [center addObserver: self
               selector: @selector(removeWidget:)
                   name: @"controlDisappeared"
                 object: nil];
    [center addObserver: self
               selector: @selector(addWidget:)
                   name: @"cardAppeared"
                 object: nil];
    tui = [[TUI alloc] init];
    [center addObserver: tui
               selector: @selector(setDefaults:)
                   name: @"serverDefaultsAppeared"
                 object: nil];
    middleware = [[Middleware alloc] init];
    return self;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [tui release];
    [middleware release];
    [pool drain];
    [super dealloc];
}

-(void) addWidget: (NSNotification*) notification {
    NSDictionary *info = [notification userInfo];
    NSNumber *id_ = [info objectForKey: @"id"];
    backend_entry_type typeb = [[info objectForKey: @"type"] intValue];
    View type;
    switch(typeb) {
        case SINK:
            type = OUTPUTS;
            break;
        case SINK_INPUT:
            type = PLAYBACK;
            break;
        case SOURCE:
            type = INPUTS;
            break;
        case SOURCE_OUTPUT:
            type = RECORDING;
            break;
        case CARD:
            type = SETTINGS;
            break;
        default:
            type = ALL;
            break;
    }
    NSString *name = [info objectForKey: @"name"];
    NSString *internalId = [NSString stringWithFormat:
        @"%@_%d", id_, typeb];
#ifdef DEBUG
debug_fprintf(__func__, "d:%d:%s passed", [id_ intValue], [name UTF8String]);
#endif
    NSArray *channels = [info objectForKey: @"channels"];
    NSArray *volumes = [info objectForKey: @"volumes"];
    if(channels != nil && volumes != nil) {
        Widget *w = [tui addWidgetWithName: name
                                   andType: type
                                     andId: internalId];
        w.internalName = [info objectForKey: @"internalName"];
        Channels *channelsWidgets = [w addChannels: channels];
        for(int i = 0; i < [channels count]; ++i) {
            volume_t *volume = [volumes objectAtIndex: i];
            [channelsWidgets setLevel: [[volume level] intValue]
                           forChannel: i];
            [channelsWidgets setMute: [volume mute]
                          forChannel: i];
        }
        option_t *ports = [info objectForKey: @"ports"];
        if(ports != nil) {
            id opt = [w addOptions: [ports options]
                          withName: @"Ports"];
            [opt setCurrentByName: [ports active]];
        }
    } else {
        option_t *profile = [info objectForKey: @"profile"];
        if(profile != nil) {
            [tui addProfiles: [profile options]
                  withActive: [profile active]
                     andName: name
                       andId: internalId];
        }
    }
    [TUI refresh];
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
            case 's':
                [tui settings];
                break;
            case 'd':
                [tui setAsDefault];
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
            case KEY_F(12):
            case '0':
                [tui showSettings];
                break;
            case ' ':
                [tui switchSetting];
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
