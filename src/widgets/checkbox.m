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
                  andNames: (NSArray*) names_
              andYPosition: (int) ypos
              andXPosition: (int) xpos
                 andParent: (WINDOW*) parent {
    self = [super init];
    label = [label_ copy];
    names = [names_ retain];
    values = [[NSMutableArray alloc] init];
    highlighted = NO;
    highlight = 0;
    width = 0;
    for(int i = 0; i < [names count]; ++i) {
        int length = [[names objectAtIndex: i] length];
        if(length > width) {
            width = length;
        }
        [values addObject: [NSNumber numberWithBool: NO]];
    }
    win = derwin(parent, [values count] + 2, width + 5, ypos, xpos);
    [self print];
    return self;
}

-(void) print {
    box(win, 0, 0);
    mvwprintw(win, 0, 1, "%@", label);
    for(int i = 0; i < [values count]; ++i) {
        mvwprintw(win, i + 1, 1, "[ ]%@", [names objectAtIndex: i]);
    }
}

-(void) printCheck: (int) i {
    if(highlighted) {
        wattron(win, A_REVERSE);
    }
    mvwaddch(win, i + 1, 2,
        [[values objectAtIndex: i] boolValue] ? 'X' : ' '
    );
    wattroff(win, A_REVERSE);
}

-(void) setCurrent: (int) i {
    mvwaddch(win, highlight + 1, 2,
        [[values objectAtIndex: highlight] boolValue] ? 'X' : ' ' | A_NORMAL
    );
    highlight = i;
    [self printCheck: highlight];
}

-(void) up {
    if(highlight > 0) {
        [self setCurrent: highlight - 1];
    }
}

-(void) down {
    if(highlight < [names count] - 1) {
        [self setCurrent: highlight + 1];
    }
}

-(void) setHighlighted: (BOOL) active {
    highlighted = active;
    [self setCurrent: highlight];
}

-(void) setValue: (BOOL) value atIndex: (int) index {
    NSNumber *newValue = [NSNumber numberWithBool: value];
    [values replaceObjectAtIndex: index withObject: newValue];
    NSString *name = @"SettingChanged";
    NSString *fullkey = [NSString stringWithFormat:
        @"%@/%@", label, [names objectAtIndex: index]];
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithBool: value], fullkey, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName: name
                                                        object: self
                                                      userInfo: info];
    [self printCheck: index];
}

-(void) switchValue {
    BOOL currentValue = [[values objectAtIndex: highlight] boolValue];
    [self setValue: !currentValue atIndex: highlight];
}

-(int) endPosition {
    return width;
}

-(void) dealloc {
    delwin(win);
    [values release];
    [names release];
    [label release];
    [super dealloc];
}
@end
