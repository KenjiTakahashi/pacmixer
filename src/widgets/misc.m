// This is a part of pacmixer @ http://github.com/KenjiTakahashi/pacmixer
// Karol "Kenji Takahashi" Woźniak © 2013 - 2014
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


@implementation Modal
-(Modal*) initWithWindow: (id<Modal>) window_ {
    self = [super init];
    window = [window_ retain];
    return self;
}

-(void) dealloc {
    if(pan != NULL) {
        del_panel(pan);
    }
    [window release];
    [super dealloc];
}

-(void) reprint: (int) height_ {
    [window reprint: height_];
    if(pan != NULL) {
        wresize(window.win, window.height, getmaxx(stdscr));
        replace_panel(pan, window.win);
        move_panel(pan, window.position + 2, 0);
    }
}

-(void) setHighlighted: (BOOL) active {
    if(active) {
        owidth = window.width;
        window.width = getmaxx(stdscr);
        delwin(window.win);
        window.win = newwin(
            window.height, window.width, window.position + 2, 0
        );
        pan = new_panel(window.win);
    } else {
        window.width = owidth;
        if(pan != NULL) {
            del_panel(pan);
            pan = NULL;
        }
        delwin(window.win);
        window.win = derwin(
            window.parent, window.height, window.width, window.position, 0
        );
    }
    [window setHighlighted: active];
}

-(void) adjust {
    if(pan == NULL) {
        mvderwin(window.win, window.position, 0);
    }
}

-(void) forwardInvocation: (NSInvocation*) inv {
    if([window respondsToSelector: [inv selector]]) {
        [inv invokeWithTarget: window];
    } else {
        [super forwardInvocation: inv];
    }
}
@end
