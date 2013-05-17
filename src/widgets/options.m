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
#import "../frontend.h"


@implementation Options
-(id) initWithPosition: (int) ypos
               andName: (NSString*) label_
             andValues: (NSArray*) options_
                 andId: (NSString*) id_
             andParent: (WINDOW*) parent_ {
    width = 0;
    for(int i = 0; i < [options_ count]; ++i) {
        int length = [[options_ objectAtIndex: i] length];
        if(length > width) {
            width = length;
        }
    }
    position = ypos;
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
    width = width_;
    position = getmaxy(parent_) - [options_ count] - 3;
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
    parent = parent_;
    label = [label_ copy];
    options = [options_ retain];
    internalId = [id_ copy];
    highlighted = NO;
    highlight = 0;
    height = [options count] + 2;
    int my;
    int mx;
    getmaxyx(parent, my, mx);
    width += 2;
    BOOL resizeParent = NO;
    if(width > mx) {
        mx = width;
        resizeParent = YES;
    }
    if(position + height > my) {
        my = position + height;
        resizeParent = YES;
    }
    if(resizeParent) {
        wresize(parent, my, mx);
    }
    win = derwin(parent, height, width, position, 0);
    hidden = YES;
    [self print];
    return self;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    delwin(win);
    [internalId release];
    [options release];
    [label release];
    [super dealloc];
}

-(void) print {
    if(!hidden) {
        box(win, 0, 0);
        if([label length] > width - 2) {
            mvwprintw(win, 0, 1, "%@", [label substringToIndex: width - 2]);
        } else {
            mvwprintw(win, 0, 1, "%@", label);
        }
        for(int i = 0; i < [options count]; ++i) {
            NSString *obj = [options objectAtIndex: i];
            if(i == current) {
                wattron(win, COLOR_PAIR(6));
            }
            if(highlighted && i == highlight) {
                wattroff(win, COLOR_PAIR(6));
                wattron(win, A_REVERSE);
            }
            mvwprintw(win, i + 1, 1, "      ");
            if([obj length] > width - 2) {
                mvwprintw(win, i + 1, 1, "%@",
                    [obj substringToIndex: width - 2]
                );
            } else {
                mvwprintw(win, i + 1, 1, "%@", obj);
            }
            wattroff(win, A_REVERSE);
            wattroff(win, COLOR_PAIR(6));
        }
        [TUI refresh];
    }
}

-(void) reprint: (int) height_ {
    [self setPosition: height_ - [options count] - 3];
    wresize(win, height, width);
    [self print];
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
    option_t *info = [[notification userInfo] objectForKey: @"profile"];
    [self setCurrentByName: [info active]];
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

-(void) switchValue {
    current = highlight;
    NSString *sname = [NSString stringWithFormat:
        @"%@%@", @"activeOptionChanged", internalId];
    NSDictionary *s = [NSDictionary dictionaryWithObjectsAndKeys:
        [options objectAtIndex: highlight], @"option", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName: sname
                                                        object: self
                                                      userInfo: s];
    [self print];
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


@implementation ROptions
-(void) dealloc {
    if(pan != NULL) {
        del_panel(pan);
    }
    [super dealloc];
}

-(void) reprint: (int) height_ {
    [super reprint: height_];
    if(pan != NULL) {
        wresize(win, [options count] + 2, getmaxx(stdscr));
        replace_panel(pan, win);
        move_panel(pan, height - [options count], 0);
    }
}

-(void) setHighlighted: (BOOL) active {
    if(active) {
        owidth = width;
        int by = getbegy(win);
        width = getmaxx(stdscr);
        delwin(win);
        win = newwin([options count] + 2, width, by + 2, 0);
        pan = new_panel(win);
        [super setHighlighted: active];
    } else {
        width = owidth;
        if(pan != NULL) {
            del_panel(pan);
            pan = NULL;
        }
        delwin(win);
        win = derwin(parent, height, width, position, 0);
        [super setHighlighted: active];
    }
}

-(void) adjust {
    if(pan == NULL) {
        mvderwin(win, position, 0);
    }
}
@end
