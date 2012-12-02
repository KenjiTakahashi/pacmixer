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


#import "misc.h"
#import "channels.h"
#import "options.h"


@interface Widget: NSObject <Controlling, Hiding> {
    @private
        WINDOW *win;
        int position;
        int height;
        int width;
        NSString *name;
        View type;
        NSString *internalId;
        NSMutableArray *controls;
        BOOL highlighted;
        int highlight;
        BOOL inside;
        WINDOW *parent;
}

-(Widget*) initWithPosition: (int) p
                    andName: (NSString*) name_
                    andType: (View) type_
                      andId: (NSString*) id_
                  andParent: (WINDOW*) parent_;
-(void) dealloc;
-(void) print;
-(void) reprint: (int) height_;
-(void) printName;
-(Channels*) addChannels: (NSArray*) channels;
-(Options*) addOptions: (NSArray*) options;
-(void) setHighlighted: (BOOL) active;
-(void) setPosition: (int) position_;
-(BOOL) canGoInside;
-(void) inside;
-(void) outside;
-(void) previous;
-(void) next;
-(void) up;
-(void) down;
-(int) height;
-(int) width;
-(int) endPosition;
-(View) type;
-(NSString*) name;
-(NSNumber*) internalId;
-(void) show;
-(void) hide;
@end
