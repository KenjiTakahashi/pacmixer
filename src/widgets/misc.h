// This is a part of pacmixer @ http://github.com/KenjiTakahashi/pacmixer
// Karol "Kenji Takahashi" Woźniak © 2012 - 2014
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
#import <Foundation/NSInvocation.h>
#import <panel.h>


typedef enum {
    OUTPUTS = 0,
    PLAYBACK = 1,
    INPUTS = 2,
    RECORDING = 3,
    SETTINGS,
    ALL,
} View;


typedef enum {
    MODE_INSIDE,
    MODE_OUTSIDE,
    MODE_SETTINGS
} Mode;


@protocol Controlling <NSObject>
-(BOOL) previous;
-(BOOL) next;
-(void) outside;
-(void) mute;
@end


@protocol Hiding <NSObject>
-(void) show;
-(void) hide;
@end


@protocol Modal <NSObject>
@property WINDOW *win;
@property WINDOW *parent;
@property int width;
@property(readonly) int height;
@property int position;

-(void) reprint: (int) height_;
-(void) setHighlighted: (BOOL) active;
@end


@interface Modal: NSObject {
    @private
        id<Modal> window;
        int owidth;
        PANEL *pan;
}

-(Modal*) initWithWindow: (id<Modal>) window_;
-(void) dealloc;
-(void) reprint: (int) height_;
-(void) setHighlighted: (BOOL) active;
-(void) adjust;
-(void) forwardInvocation: (NSInvocation*) inv;
@end
