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


#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>
#import <Foundation/NSDecimalNumber.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSDictionary.h>
#import <curses.h>
#import "misc.h"
#import "../types.h"


@class TUI;


@interface Options: NSObject <Hiding, Modal> {
    @protected
        WINDOW *_win;
        WINDOW *_parent;
        unsigned int _width;
        int _height;
        NSString *label;
        NSString *internalId;
        NSArray *options;
        NSArray *mapping;
        BOOL highlighted;
        unsigned int current;
        unsigned int highlight;
        int _position;
        BOOL hidden;
}

@property WINDOW *win;
@property WINDOW *parent;
@property unsigned int width;
@property(readonly) int height;
@property int position;

-(id) initWithPosition: (int) ypos
               andName: (NSString*) label_
             andValues: (NSArray*) options_
                 andId: (NSString*) id_
             andParent: (WINDOW*) parent_;
-(id) initWithWidth: (int) width_
            andName: (NSString*) label_
          andValues: (NSArray*) options_
              andId: (NSString*) id_
          andParent: (WINDOW*) parent_;
-(id) initWithName: (NSString*) label_
         andValues: (NSArray*) options_
             andId: (NSString*) id_
         andParent: (WINDOW*) parent_;
-(void) dealloc;
-(void) print;
-(void) reprint: (int) height_;
-(void) calculateDimensions;
-(void) setCurrent: (int) i;
-(void) setCurrentByName: (NSString*) name;
-(void) setCurrentByNotification: (NSNotification*) notification;
-(void) setHighlighted: (BOOL) active;
-(void) setPosition: (int) position_;
-(void) replaceValues: (NSArray*) values;
-(void) replaceMapping: (NSArray*) values;
-(void) up;
-(void) down;
-(void) switchValue;
-(int) height;
-(int) endPosition;
-(View) type;
-(NSString*) name;
-(NSString*) internalId;
-(void) show;
-(void) hide;
@end
