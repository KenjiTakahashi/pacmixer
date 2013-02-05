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
    highlight = 0;
    controls = [[NSMutableArray alloc] init];
    position = p;
    name = [name_ copy];
    type = type_;
    internalId = [id_ copy];
    parent = parent_;
    width = 8;
    hidden = YES;
    [self print];
#ifdef DEBUG
debug_fprintf(__func__, "f:%d:%s printed", [internalId intValue], [name UTF8String]);
#endif
    return self;
}

-(void) dealloc {
    [controls release];
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
    for(int i = 0; i < [controls count]; ++i) {
        [[controls objectAtIndex: i] reprint: height];
    }
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

-(Channels*) addChannels: (NSArray*) channels {
    int width_ = [channels count] + 2;
    int position_ = (width - width_) / 2;
    if(width_ > 8) {
        width = width_;
        [self print];
        [self printName];
    }
    Channels *control = [[Channels alloc] initWithChannels: channels
                                               andPosition: position_
                                                     andId: internalId
                                                 andParent: win];
    if(!hidden) {
        [control show];
    }
    [controls addObject: control];
    [control release];
    return control;
}

-(void) setHighlighted: (BOOL) active {
    highlighted = active;
    [self printName];
}

-(void) setPosition: (int) position_ {
    position = position_;
    mvderwin(win, 0, position);
    for(int i = 0; i < [controls count]; ++i) {
        [[controls objectAtIndex: i] adjust];
    }
}

-(BOOL) canGoInside {
    BOOL can = NO;
    for(int i = 0; i < [controls count]; ++i) {
        id control = [controls objectAtIndex: i];
        if([control respondsToSelector:@selector(previous)] ||
           [control respondsToSelector:@selector(next)]) {
            can = YES;
            break;
        }
    }
    return can;
}

-(void) inside {
    if(!inside) {
        inside = YES;
        [[controls objectAtIndex: highlight] inside];
    }
}

-(void) outside {
    if(inside) {
        inside = NO;
        [(id<Controlling>)[controls objectAtIndex: highlight] outside];
    }
}

-(void) previous {
    if(inside) {
        id<Controlling> control = [controls objectAtIndex: highlight];
        BOOL end = [control previous];
        while(end) {
            if(highlight == 0) {
                break;
            }
            highlight -= 1;
            control = [controls objectAtIndex: highlight];
            end = [control previous];
        }
    }
}

-(void) next {
    if(inside) {
        id<Controlling> control = [controls objectAtIndex: highlight];
        BOOL end = [control next];
        while(end) {
            if(highlight == [controls count] - 1) {
                break;
            }
            highlight += 1;
            end = [(id<Controlling>)[controls objectAtIndex: highlight] next];
        }
    }
}

-(void) up {
    if(inside) {
        [[controls objectAtIndex: highlight] up];
    } else {
        for(int i = 0; i < [controls count]; ++i) {
            [[controls objectAtIndex: i] up];
        }
    }
}

-(void) down {
    if(inside) {
        [[controls objectAtIndex: highlight] down];
    } else {
        for(int i = 0; i < [controls count]; ++i) {
            [[controls objectAtIndex: i] down];
        }
    }
}

-(void) mute {
    for(int i = 0; i < [controls count]; ++i) {
        id<Controlling> obj = [controls objectAtIndex: i];
        if([obj respondsToSelector: @selector(mute)]) {
            [obj mute];
        }
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
    for(int i = 0; i < [controls count]; ++i) {
        [[controls objectAtIndex: i] show];
    }
}

-(void) hide {
    hidden = YES;
    for(int i = 0; i < [controls count]; ++i) {
        [[controls objectAtIndex: i] hide];
    }
}
@end
