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


#import "options.h"


@implementation Options
-(Options*) initWithPosition: (int) ypos
                     andName: (NSString*) label_
                   andValues: (NSArray*) options_
                       andId: (NSString*) id_
                   andParent: (WINDOW*) parent {
    self = [super init];
    label = [label_ copy];
    options = [options_ retain];
    internalId = [id_ copy];
    highlighted = NO;
    highlight = 0;
    int width = 0;
    int height = [options count] + 2;
    for(int i = 0; i < [options count]; ++i) {
        int length = [[options objectAtIndex: i] length];
        if(length > width) {
            width = length;
        }
    }
    int my;
    int mx;
    getmaxyx(parent, my, mx);
    width += 2;
    BOOL resizeParent = NO;
    if(width > mx) {
        mx = width;
        resizeParent = YES;
    }
    if(ypos + height > my) {
        my = ypos + height;
        resizeParent = YES;
    }
    if(resizeParent) {
        wresize(parent, my, mx);
    }
    position = ypos;
    win = derwin(parent, height, width, position, 0);
    hidden = YES;
    [self print];
    return self;
}

-(void) dealloc {
    delwin(win);
    [internalId release];
    [options release];
    [label release];
    [super dealloc];
}

-(void) print {
    if(!hidden) {
        box(win, 0, 0);
        mvwprintw(win, 0, 1, "%@", label);
        for(int i = 0; i < [options count]; ++i) {
            NSString *obj = [options objectAtIndex: i];
            if(highlighted && i == highlight) {
                wattron(win, COLOR_PAIR(6));
            }
            mvwprintw(win, i + 1, 1, "      ");
            mvwprintw(win, i + 1, 1, "%@", obj);
            wattroff(win, COLOR_PAIR(6));
        }
    }
}

-(void) setCurrent: (int) i {
    highlight = i;
    [self print];
}

-(void) setCurrentByName: (NSString*) name {
    highlight = [options indexOfObject: name];
    [self print];
}

-(void) up {
    if(highlight > 0) {
        [self setCurrent: highlight - 1];
    }
}

-(void) down {
    if(highlight < [options count] - 1) {
        [self setCurrent: highlight + 1];
    }
}

-(void) setHighlighted: (BOOL) active {
    highlighted = active;
    [self print];
}

-(void) setPosition: (int) position_ {
    position = position_;
    mvderwin(win, position, 0);
}

-(int) height {
    return [options count] + 2;
}

-(int) endPosition {
    return position + [self height];
}

-(View) type {
    return SETTINGS;
}

-(NSString*) name {
    return label;
}

-(NSNumber*) internalId {
    NSArray *components = [internalId componentsSeparatedByString: @"_"];
    int i = [[components objectAtIndex: 0] integerValue];
    return [NSNumber numberWithInt: i];
}

-(void) show {
    hidden = NO;
    [self print];
}

-(void) hide {
    hidden = YES;
}
@end
