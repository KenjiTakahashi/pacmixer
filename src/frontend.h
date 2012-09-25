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


#import <Foundation/NSObject.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSString.h>
#import <Foundation/NSDecimalNumber.h>
#import <Foundation/NSNotification.h>
#import <curses.h>
#import "types.h"


@interface Channel: NSObject {
    @private
        int my;
        WINDOW *win;
        int currentLevel;
        int maxLevel;
        int normLevel;
        int delta;
        BOOL mute;
        BOOL mutable;
        BOOL inside;
        BOOL propagate;
        NSString *signal;
}

-(Channel*) initWithIndex: (int) i
              andMaxLevel: (NSNumber*) mlevel_
             andNormLevel: (NSNumber*) nlevel_
                  andMute: (NSNumber*) mute_ // it's BOOL, but we need a pointer
                andSignal: (NSString*) signal_
                andParent: (WINDOW*) parent;
-(void) dealloc;
-(void) print;
-(void) setMute: (BOOL) mute_;
-(void) setLevel: (int) level_;
-(int) level;
-(void) setLevelAndMuteN: (NSNotification*) notification;
-(void) setLevel: (int) level_ andMute: (BOOL) mute_;
-(void) setPropagation: (BOOL) p;
-(void) inside;
-(void) outside;
-(void) up;
-(void) down;
-(void) moveLeftBy: (int) p;
-(void) mute;
-(BOOL) isMuted;
@end


@interface Channels: NSObject {
    @private
        WINDOW *win;
        NSMutableArray *channels;
        BOOL inside;
        int highlight;
        NSNumber *internalId;
}

-(Channels*) initWithChannels: (NSArray*) channels_
                  andPosition: (int) position
                        andId: (NSNumber*) id_
                    andParent: (WINDOW*) parent;
-(void) dealloc;
-(void) setMute: (BOOL) mute forChannel: (int) channel;
-(void) setLevel: (int) level forChannel: (int) channel;
-(void) notify: (NSArray*) values;
-(BOOL) previous;
-(BOOL) next;
-(void) up;
-(void) down;
-(void) inside;
-(void) outside;
-(void) moveLeftBy: (int) p;
-(void) mute;
@end


@interface Options: NSObject {
    @private
        WINDOW *win;
        NSArray *options;
        int highlight;
}

-(Options*) initWithOptions: (NSArray*) options_
                   andParent: (WINDOW*) parent;
-(void) dealloc;
-(void) print;
-(void) setCurrent: (int) i;
-(void) up;
-(void) down;
-(void) moveLeftBy: (int) p;
@end


typedef enum {
    ALL,
    PLAYBACK,
    RECORDING,
    OUTPUTS,
    INPUTS
} View;


@interface Widget: NSObject {
    @private
        WINDOW *win;
        int position;
        int height;
        int width;
        NSString *name;
        View type;
        NSNumber *internalId;
        NSMutableArray *controls;
        BOOL highlighted;
        int highlight;
        BOOL inside;
        WINDOW *parent;
}

-(Widget*) initWithPosition: (int) p
                    andName: (NSString*) name_
                    andType: (View) type_
                      andId: (NSNumber*) id_
                  andParent: (WINDOW*) parent_;
-(void) dealloc;
-(void) printWithWidth: (int) width_;
-(void) printName;
-(Channels*) addChannels: (NSArray*) channels;
-(Options*) addOptions: (NSArray*) options;
-(void) setHighlighted: (BOOL) active;
-(BOOL) canGoInside;
-(void) inside;
-(void) outside;
-(void) previous;
-(void) next;
-(void) up;
-(void) down;
-(void) moveLeftBy: (int) p;
-(int) height;
-(int) width;
-(int) endPosition;
-(NSString*) name;
-(NSNumber*) internalId;
@end


@interface Top: NSObject {
    @private
        WINDOW *win;
        View view;
}

-(Top*) init;
-(void) dealloc;
-(void) print;
-(void) setView: (View) type_;
@end


typedef enum {
    INSIDE,
    OUTSIDE
} Mode;


@interface Bottom: NSObject {
    @private
        WINDOW *win;
        Mode mode;
}

-(Bottom*) init;
-(void) dealloc;
-(void) print;
-(void) inside;
-(BOOL) outside;
@end


@interface TUI: NSObject {
    @private
        NSMutableArray *widgets;
        Top *top;
        Bottom *bottom;
        WINDOW *win;
        int padding;
        NSMutableArray *paddingStates;
        int highlight;
        BOOL inside;
}

-(TUI*) init;
-(void) dealloc;
-(void) refresh: (NSNotification*) notification;
-(Widget*) addWidgetWithName: (NSString*) name
                     andType: (View) type
                       andId: (NSNumber*) id_;
-(void) removeWidget: (NSNumber*) id_;
-(void) setCurrent: (int) i;
-(void) setFilter: (View) type;
-(void) previous;
-(void) next;
-(void) up;
-(void) down;
-(void) mute;
-(void) inside;
-(BOOL) outside;
@end
