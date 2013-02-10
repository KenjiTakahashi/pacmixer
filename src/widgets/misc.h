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


#import <Foundation/NSObject.h>


typedef enum {
    ALL,
    PLAYBACK,
    RECORDING,
    OUTPUTS,
    INPUTS,
    SETTINGS
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
