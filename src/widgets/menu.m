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


#import "menu.h"


@implementation Top
-(Top*) init {
    self = [super init];
    view = ALL;
    int mx = getmaxx(stdscr);
    win = newwin(1, mx, 0, 0);
    [self print];
    return self;
}

-(void) dealloc {
    delwin(win);
    [super dealloc];
}

-(void) print {
    wmove(win, 0, 0);
    NSString *all = @"F1: All";
    NSString *playback = @"F2: Playback";
    NSString *recording = @"F3: Recording";
    NSString *outputs = @"F4: Outputs";
    NSString *inputs = @"F5: Inputs";
    if(view == ALL) {
        wprintw(win, " [%@] ", all);
    } else {
        wprintw(win, " %@ ", all);
    }
    if(view == PLAYBACK) {
        wprintw(win, " [%@] ", playback);
    } else {
        wprintw(win, " %@ ", playback);
    }
    if(view == RECORDING) {
        wprintw(win, " [%@] ", recording);
    } else {
        wprintw(win, " %@ ", recording);
    }
    if(view == OUTPUTS) {
        wprintw(win, " [%@] ", outputs);
    } else {
        wprintw(win, " %@ ", outputs);
    }
    if(view == INPUTS) {
        wprintw(win, " [%@] ", inputs);
    } else {
        wprintw(win, " %@ ", inputs);
    }
    wrefresh(win);
}

-(void) reprint {
    int mx = getmaxx(stdscr);
    wresize(win, 1, mx);
    [self print];
}

-(void) setView: (View) type_ {
    view = type_;
    [self print];
}

-(View) view {
    return view;
}
@end


@implementation Bottom
-(Bottom*) init {
    self = [super init];
    int my;
    int mx;
    getmaxyx(stdscr, my, mx);
    win = newwin(1, mx, my - 1, 0);
    mode = OUTSIDE;
    [self print];
    return self;
}

-(void) dealloc {
    delwin(win);
    [super dealloc];
}

-(void) print {
    NSString *line;
    char mode_ = 'o';
    int color = COLOR_PAIR(6);
    if(mode == OUTSIDE) {
        line =
            @" i: inside mode, "
            @"h/l: previous/next control, "
            @"j/k: volume down/up or previous/next option, "
            @"m: (un)mute, "
            @"q: Exit";
    } else if(mode == INSIDE) {
        line =
            @" q: outside mode, "
            @"h/l: previous/next channel, "
            @"j/k: volume down/up, "
            @"m: (un)mute";
        mode_ = 'i';
        color = COLOR_PAIR(7);
    } else {
        line = @"";
        mode_ = '?';
    }
    werase(win);
    wattron(win, color | A_BOLD);
    wprintw(win, " %c ", mode_);
    wattroff(win, color | A_BOLD);
    wprintw(win, "%@", line);
    wrefresh(win);
}

-(void) reprint {
    werase(win);
    wrefresh(win);
    int my;
    int mx;
    getmaxyx(stdscr, my, mx);
    mvwin(win, my - 1, 0);
    wresize(win, 1, mx);
    [self print];
}

-(void) inside {
    if(mode == OUTSIDE) {
        mode = INSIDE;
        [self print];
    }
}

-(BOOL) outside {
    if(mode == INSIDE) {
        mode = OUTSIDE;
        [self print];
        return NO;
    }
    return YES;
}
@end
