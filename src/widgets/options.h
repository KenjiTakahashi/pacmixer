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


#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>
#import <Foundation/NSDecimalNumber.h>
#import <curses.h>


@interface Options: NSObject {
    @private
        WINDOW *win;
        NSString *label;
        NSString *internalId;
        NSArray *options;
        BOOL highlighted;
        int highlight;
        int position;
}

-(Options*) initWithPosition: (int) ypos
                     andName: (NSString*) label_
                   andValues: (NSArray*) options_
                       andId: (NSString*) id_
                   andParent: (WINDOW*) parent;
-(void) dealloc;
-(void) print;
-(void) setCurrent: (int) i;
-(void) up;
-(void) down;
-(void) setHighlighted: (BOOL) active;
-(int) height;
-(int) endPosition;
-(NSNumber*) internalId;
@end
