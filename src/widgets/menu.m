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

-(void) printString: (NSString*) str
           withView: (View) view_ {
    if(view == view_) {
        wprintw(win, " [%@] ", str);
    } else {
        wprintw(win, " %@ ", str);
    }
}

-(void) print {
    wmove(win, 0, 0);
    NSString *all = @"F1: All";
    NSString *playback = @"F2: Playback";
    NSString *recording = @"F3: Recording";
    NSString *outputs = @"F4: Outputs";
    NSString *inputs = @"F5: Inputs";
    NSString *settings = @"F12: Settings";
    [self printString: all withView: ALL];
    [self printString: playback withView: PLAYBACK];
    [self printString: recording withView: RECORDING];
    [self printString: outputs withView: OUTPUTS];
    [self printString: inputs withView: INPUTS];
    [self printString: settings withView: SETTINGS];
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
    mode = MODE_OUTSIDE;
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
    if(view == SETTINGS) {
        line =
            @" h/l: previous/next group, "
            @"j/k: previous/next setting, "
            @"space: (un)check setting, "
            @"q: Exit";
    } else if(mode == MODE_OUTSIDE) {
        line =
            @" i: inside mode, "
            @"s: settings mode, "
            @"h/l: previous/next control, "
            @"j/k: volume down/up, "
            @"m: (un)mute, "
            @"d: set as default, "
            @"q: Exit";
    } else if(mode == MODE_INSIDE) {
        line =
            @" q: outside mode, "
            @"s: settings mode, "
            @"h/l: previous/next channel, "
            @"j/k: volume down/up, "
            @"m: (un)mute"
            @"d: set as default, ";
        mode_ = 'i';
        color = COLOR_PAIR(7);
    } else if(mode == MODE_SETTINGS) {
        line =
            @" q: outside mode, "
            @"i: inside mode, "
            @"h/l: previous/next control, "
            @"j/k: previous/next setting, "
            @"space: (un)check setting";
        mode_ = 's';
        color = COLOR_PAIR(4);
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
    int my;
    int mx;
    getmaxyx(stdscr, my, mx);
    mvwin(win, my - 1, 0);
    wresize(win, 1, mx);
    [self print];
}

-(void) inside {
    if(mode != MODE_INSIDE) {
        mode = MODE_INSIDE;
        [self print];
    }
}

-(void) settings {
    if(mode != MODE_SETTINGS) {
        mode = MODE_SETTINGS;
        [self print];
    }
}

-(BOOL) outside {
    if(mode != MODE_OUTSIDE) {
        mode = MODE_OUTSIDE;
        [self print];
        return NO;
    }
    return YES;
}

-(void) setView: (View) view_ {
    view = view_;
    [self print];
}

-(Mode) mode {
    return mode;
}
@end
