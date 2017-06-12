// This is a part of pacmixer @ http://github.com/KenjiTakahashi/pacmixer
// Karol "Kenji Takahashi" Woźniak © 2012 - 2015
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
#import "../frontend.h"


@implementation Options

@synthesize win = _win;
@synthesize parent = _parent;
@synthesize width = _width;
@synthesize position = _position;

-(id) initWithPosition: (int) ypos
               andName: (NSString*) label_
             andValues: (NSArray*) options_
                 andId: (NSString*) id_
             andParent: (WINDOW*) parent_ {
    _width = 0;
    for(unsigned int i = 0; i < [options_ count]; ++i) {
        unsigned int length = [[options_ objectAtIndex: i] length];
        if(length > _width) {
            _width = length;
        }
    }
    _position = ypos;
    return [self initWithName: label_
                    andValues: options_
                        andId: id_
                    andParent: parent_];
}

-(id) initWithWidth: (int) width_
            andName: (NSString*) label_
          andValues: (NSArray*) options_
              andId: (NSString*) id_
          andParent: (WINDOW*) parent_ {
    _width = width_;
    _position = getmaxy(parent_) - [options_ count] - 6;
    return [self initWithName: label_
                    andValues: options_
                        andId: id_
                    andParent: parent_];
}

-(id) initWithName: (NSString*) label_
         andValues: (NSArray*) options_
             andId: (NSString*) id_
         andParent: (WINDOW*) parent_ {
    self = [super init];
    _parent = parent_;
    label = [label_ copy];
    internalId = [id_ copy];
    highlighted = NO;
    highlight = 0;
    options = [options_ retain];
    _width += 2;
    [self calculateDimensions];
    _win = derwin(_parent, _height, _width, _position, 0);
    hidden = YES;
    [self print];
    return self;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    delwin(_win);
    [internalId release];
    [options release];
    [mapping release];
    [label release];
    [super dealloc];
}

-(void) print {
    if(!(hidden || pacmixer::setting<bool>("Filter.Options"))) {
        werase(self.win);
        box(self.win, 0, 0);
        // CJ - Label on the input selection bit (Port/Input/Output)
        if([label length] > self.width - 2) {
            mvwprintw(self.win, 0, 1, "%@", [label substringToIndex: self.width - 2]);
        } else {
            mvwprintw(self.win, 0, 1, "%@", label);
        }
        for(unsigned int i = 0; i < [options count]; ++i) {
            NSString *obj = [options objectAtIndex: i];
            if(i == current) {
                wattron(self.win, COLOR_PAIR(6));
            }
            if(highlighted && i == highlight) {
                wattroff(self.win, COLOR_PAIR(6));
                wattron(self.win, A_REVERSE);
            }
            mvwprintw(self.win, i + 1, 1, "      ");
            // CJ - individual options within the input selection bit
            if([obj length] > self.width - 2) {
                mvwprintw(self.win, i + 1, 1, "%@",
                    [obj substringToIndex: self.width - 2]
                );
            } else {
                mvwprintw(self.win, i + 1, 1, "%@", obj);
            }
            wattroff(self.win, A_REVERSE);
            wattroff(self.win, COLOR_PAIR(6));
        }
        [TUI refresh];
    }
}

-(void) reprint: (int) height_ {
    [self setPosition: height_ - [options count] - 6];
    wresize(self.win, self.height, self.width);
    [self print];
}

-(void) calculateDimensions {
    _height = [options count] + 2;
    int my;
    unsigned int mx;
    getmaxyx(_parent, my, mx);
    BOOL resizeParent = NO;
    if(_width > mx) {
        mx = _width;
        resizeParent = YES;
    }
    if(_position + _height > my) {
        my = _position + _height;
        resizeParent = YES;
    }
    if(resizeParent) {
        wresize(_parent, my, mx);
    }
}

-(void) setCurrent: (int) i {
    highlight = i;
    [self print];
}

-(void) setCurrentByName: (NSString*) name {
    highlight = [options indexOfObject: name];
    current = highlight;
    [self print];
}

-(void) setCurrentByNotification: (NSNotification*) notification {
    NSDictionary *info = [notification userInfo];
    [self setCurrentByName: [info objectForKey: @"activeProfile"]];
}

-(void) setHighlighted: (BOOL) active {
    highlighted = active;
    [self print];
}

-(void) setPosition: (int) position_ {
    _position = position_;
    mvderwin(self.win, self.position, 0);
}

-(void) replaceValues: (NSArray*) values {
    [options release];
    options = [values retain];
    [self calculateDimensions];
}

-(void) replaceMapping: (NSArray*) values {
    [mapping release];
    mapping = [values retain];
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

-(void) switchValue {
    current = highlight;
    NSString *sname = [NSString stringWithFormat:
        @"%@%@", @"activeOptionChanged", internalId];
    NSArray *source = mapping != nil ? mapping : options;
    NSDictionary *s = [NSDictionary dictionaryWithObjectsAndKeys:
        [source objectAtIndex: highlight], @"option", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName: sname
                                                        object: self
                                                      userInfo: s];
    [self print];
}

-(int) height {
    if(pacmixer::setting<bool>("Filter.Options")) {
        return 0;
    }
    return [options count] + 2;
}

-(int) endVPosition {
    return self.position + self.height;
}

-(int) endPosition {
    return [self endVPosition];
}

-(View) type {
    return SETTINGS;
}

-(NSString*) name {
    return label;
}

-(NSString*) internalId {
    return internalId;
}

-(void) show {
    hidden = NO;
    [self print];
}

-(void) hide {
    hidden = YES;
}
@end
