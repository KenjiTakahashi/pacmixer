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
#import <Foundation/NSDictionary.h>
#import <Foundation/NSDecimalNumber.h>
#import <Foundation/NSNotification.h>
#import <curses.h>
#import "misc.h"


@interface CheckBox: NSObject <Hiding> {
    @private
        WINDOW *win;
        NSString *label;
        NSArray *names;
        NSString *internalId;
        NSMutableArray *values;
        BOOL highlighted;
        BOOL hidden;
        int highlight;
        int position;
}

-(CheckBox*) initWithPosition: (int) ypos
                      andName: (NSString*) label_
                    andValues: (NSArray*) names_
                        andId: (NSString*) id_
                    andParent: (WINDOW*) parent;
-(void) dealloc;
-(void) print;
-(void) printCheck: (int) i;
-(void) setCurrent: (int) i;
-(void) up;
-(void) down;
-(void) setHighlighted: (BOOL) active;
-(void) setPosition: (int) position_;
-(void) setValue: (BOOL) value atIndex: (int) index;
-(void) switchValue;
-(int) height;
-(int) endPosition;
-(NSNumber*) internalId;
-(void) show;
-(void) hide;
@end
