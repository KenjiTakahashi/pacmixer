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
#import <Foundation/NSString.h>
#import <curses.h>
#import "misc.h"


@interface Top: NSObject {
    @private
        WINDOW *win;
        View view;
}

-(Top*) init;
-(void) dealloc;
-(void) printString: (NSString*) str
           withView: (View) view_;
-(void) print;
-(void) reprint;
-(void) setView: (View) type_;
-(View) view;
@end


typedef enum {
    MODE_INSIDE,
    MODE_OUTSIDE,
    MODE_SETTINGS
} Mode;


@interface Bottom: NSObject {
    @private
        WINDOW *win;
        Mode mode;
        View view;
}

-(Bottom*) init;
-(void) dealloc;
-(void) print;
-(void) reprint;
-(void) inside;
-(void) settings;
-(BOOL) outside;
-(void) setView: (View) view_;
-(Mode) mode;
@end
