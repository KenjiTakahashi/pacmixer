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


#import "widget.h"
#import "../frontend.h"


@implementation Widget
-(Widget*) initWithPosition: (int) p
                    andName: (NSString*) name_
                    andType: (View) type_
                      andId: (NSString*) id_
                  andParent: (WINDOW*) parent_ {
    self = [super init];
    position = p;
    name = [name_ copy];
    type = type_;
    internalId = [id_ copy];
    parent = parent_;
    width = 8;
    hidden = YES;
    mode = MODE_OUTSIDE;
    [self print];
#ifdef DEBUG
debug_fprintf(__func__, "f:%d:%s printed", [internalId intValue], [name UTF8String]);
#endif
    return self;
}

-(void) dealloc {
    if(ports != nil) {
        [ports release];
    }
    if(channels != nil) {
        [channels release];
    }
    [name release];
    [internalId release];
    delwin(win);
    [super dealloc];
}

-(void) print {
    int mx;
    getmaxyx(parent, height, mx);
    wresize(parent, height, mx + width + 1);
    if(win == NULL) {
        win = derwin(parent, height, width, 0, position);
    } else {
        wresize(win, height, width);
    }
    [TUI refresh];
}

-(void) reprint: (int) height_ {
    werase(win);
    height = height_;
    [channels reprint: height];
    [ports reprint: height];
    wresize(win, height, width);
    [self printName];
}

-(void) printName {
    int color = highlighted ? COLOR_PAIR(6) : COLOR_PAIR(5);
    int length = (width - (int)[name length]) / 2;
    if(length < 0) {
        length = 0;
    }
    wattron(win, color | A_BOLD);
    mvwprintw(win, height - 1, 0, "%@",
        [@"" stringByPaddingToLength: width
                          withString: @" "
                     startingAtIndex: 0]
    );
    mvwprintw(win, height - 1, length, "%@", name);
    wattroff(win, color | A_BOLD);
}

-(Channels*) addChannels: (NSArray*) channels_ {
    int width_ = [channels_ count] + 2;
    int position_ = (width - width_) / 2;
    if(width_ > 8) {
        width = width_;
        [self print];
        [self printName];
    }
    channels = [[Channels alloc] initWithChannels: channels_
                                      andPosition: position_
                                            andId: internalId
                                        andParent: win];
    if(!hidden) {
        [channels show];
    }
    return channels;
}

-(ROptions*) addOptions: (NSArray*) options_
               withName: (NSString*) optname {
    [channels reprint: height - [options_ count] - 2];
    ports = [[ROptions alloc] initWithWidth: width - 2
                                    andName: optname
                                  andValues: options_
                                      andId: internalId
                                  andParent: win];
    if(!hidden) {
        [ports show];
    }
    return ports;
}

-(void) setHighlighted: (BOOL) active {
    highlighted = active;
    [self printName];
}

-(void) setPosition: (int) position_ {
    position = position_;
    mvderwin(win, 0, position);
    [channels adjust];
    [ports adjust];
}

-(BOOL) canGoInside {
    BOOL can = [channels respondsToSelector:@selector(previous)];
    return can || [channels respondsToSelector:@selector(next)];
}

-(BOOL) canGoSettings {
    return ports != nil;
}

-(void) inside {
    if(mode == MODE_SETTINGS) {
        [ports setHighlighted: NO];
    }
    if(mode != MODE_INSIDE) {
        mode = MODE_INSIDE;
        [channels inside];
    }
}

-(void) settings {
    if(mode == MODE_INSIDE) {
        [channels outside];
    }
    if(mode != MODE_SETTINGS) {
        mode = MODE_SETTINGS;
        [ports setHighlighted: YES];
    }
}

-(void) outside {
    if(mode != MODE_OUTSIDE) {
        if(mode == MODE_INSIDE) {
            [channels outside];
        } else if(mode == MODE_SETTINGS) {
            [ports setHighlighted: NO];
        }
        mode = MODE_OUTSIDE;
    }
}

-(void) previous {
    [channels previous];
}

-(void) next {
    [channels next];
}

-(void) up {
    if(mode == MODE_SETTINGS) {
        [ports up];
    } else {
        [channels up];
    }
}

-(void) down {
    if(mode == MODE_SETTINGS) {
        [ports down];
    } else {
        [channels down];
    }
}

-(void) mute {
    [channels mute];
}

-(void) switchValue {
    if(mode == MODE_SETTINGS) {
        [ports switchValue];
    }
}

-(int) width {
    return width;
}

-(int) endPosition {
    return position + width;
}

-(View) type {
    return type;
}

-(NSString*) name {
    return name;
}

-(NSNumber*) internalId {
    NSArray *components = [internalId componentsSeparatedByString: @"_"];
    int i = [[components objectAtIndex: 0] integerValue];
    return [NSNumber numberWithInt: i];
}

-(void) show {
    hidden = NO;
    [self printName];
    [channels show];
    [ports show];
}

-(void) hide {
    hidden = YES;
    [channels hide];
    [ports hide];
}
@end
