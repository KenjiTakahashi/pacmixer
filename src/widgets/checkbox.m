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


#import "checkbox.h"


@implementation CheckBox
-(CheckBox*) initWithLabel: (NSString*) label_
                 andValues: (NSArray*) values_
              andYPosition: (int) ypos
              andXPosition: (int) xpos
                 andParent: (WINDOW*) parent {
    self = [super init];
    label = [label_ copy];
    values = [values_ retain];
    width = 0;
    for(int i = 0; i < [values count]; ++i) {
        int length = [[values objectAtIndex: i] length];
        if(length > width) {
            width = length;
        }
    }
    win = derwin(parent, [values count] + 2, width + 5, ypos, xpos);
    [self print];
    return self;
}

-(void) print {
    box(win, 0, 0);
    mvwprintw(win, 0, 1, "%@", label);
    for(int i = 0; i < [values count]; ++i) {
        mvwprintw(win, i + 1, 1, "[ ]%@", [values objectAtIndex: i]);
    }
}

-(int) endPosition {
    return width;
}

-(void) dealloc {
    delwin(win);
    [values release];
    [label release];
    [super dealloc];
}
@end
