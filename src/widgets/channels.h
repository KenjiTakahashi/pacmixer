// This is a part of pacmixer @ http://github.com/KenjiTakahashi/pacmixer
// Karol "Kenji Takahashi" Woźniak © 2012 - 2013, 2015
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
#import <Foundation/NSDecimalNumber.h>
#import <Foundation/NSString.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSNotification.h>
#import <curses.h>
#import "../types.h"
#import "misc.h"


@class TUI;


@interface Channel: NSObject <Hiding> {
    @private
        int my;
        WINDOW *win;
        WINDOW *numberWin;
        int currentLevel;
        int maxLevel;
        int normLevel;
        int delta;
        BOOL mute;
        BOOL isMutable;
        BOOL inside;
        BOOL propagate;
        BOOL hidden;
        NSString *signal;
        BOOL numberAlignRight;
}

-(Channel*) initWithIndex: (int) i
              andMaxLevel: (NSNumber*) mlevel_
             andNormLevel: (NSNumber*) nlevel_
                  andMute: (NSNumber*) mute_ // it's BOOL, but we need a pointer
                andSignal: (NSString*) signal_
                andParent: (WINDOW*) parent
          andNumberParent: (WINDOW*) numberParent;
-(void) dealloc;
-(void) print;
-(void) reprint: (int) height;
-(void) resetNumberWin;
-(void) adjust: (int) i;
-(void) setMute: (BOOL) mute_;
-(void) setLevel: (int) level_;
-(int) level;
-(void) setLevel: (int) level_ andMute: (BOOL) mute_;
-(void) setPropagation: (BOOL) p;
-(void) inside;
-(void) outside;
-(void) up: (int64_t) speed;
-(void) down: (int64_t) speed;
-(void) mute;
-(BOOL) isMuted;
-(void) show;
-(void) hide;
@end


typedef enum {
    UP,
    DOWN
} UpDown;

@interface Channels: NSObject <Controlling, Hiding> {
    @private
        WINDOW *win;
        WINDOW *numberWin;
        NSMutableArray *channels;
        BOOL inside;
        BOOL hasPeak;
        BOOL hasMute;
        BOOL hidden;
        int position;
        int y;
        int my;
        int mx;
        unsigned int highlight;
        NSString *internalId;
}

-(Channels*) initWithChannels: (NSArray*) channels_
                  andPosition: (int) position_
                        andId: (NSString*) id_
                   andDefault: (BOOL) default_
                    andParent: (WINDOW*) parent;
-(void) dealloc;
-(void) print;
-(void) reprint: (int) height;
-(void) setMute: (BOOL) mute forChannel: (int) channel;
-(void) setLevel: (int) level forChannel: (int) channel;
-(void) adjust;
-(void) notify: (NSArray*) values;
-(BOOL) previous;
-(BOOL) next;
-(void) upDown_: (UpDown) updown speed: (int64_t) speed;
-(void) up: (int64_t) sp;
-(void) down: (int64_t) sp;
-(void) inside;
-(void) outside;
-(void) mute;
-(void) show;
-(void) hide;
@end
