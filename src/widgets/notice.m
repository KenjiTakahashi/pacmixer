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


#import "notice.h"


@implementation Notice
-(Notice*) initWithMessage: (NSString*) message_
                 andParent: (WINDOW*) parent {
    self = [super init];
    message = [message_ copy];
    int mx = getmaxx(stdscr);
    int py;
    int px;
    getmaxyx(parent, py, px);
    int l = [message length] + 2;
    int lines = 1;
    int width = l;
    while(l > mx) {
        l -= mx;
        lines += 1;
    }
    if(lines > 1) {
        width = mx;
    }
    if(px < width) {
        wresize(parent, py, width);
        px = width;
    }
    win = derwin(parent, lines + 2, width, (py - lines) / 2, (px - width) / 2);
    [self print];
    return self;
}

-(void) print {
    wattron(win, A_REVERSE);
    box(win, 0, 0);
    mvwprintw(win, 1, 1, "%s", [message UTF8String]);
    wattroff(win, A_REVERSE);
}

-(void) dealloc {
    delwin(win);
    [super dealloc];
}
@end
