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


#import "widget.h"
#import "../frontend.h"


@implementation Widget

@synthesize internalName = _internalName;

-(Widget*) initWithPosition: (int) p
                    andName: (NSString*) name_
                    andType: (View) type_
                      andId: (NSString*) id_
                  andParent: (WINDOW*) parent_ {
    self = [super init];
    position = p + 1;
    name = [name_ copy];
    type = type_;
    internalId = [id_ copy];
    parent = parent_;
    width = 8;
    hidden = YES;
    mode = MODE_OUTSIDE;
    hasDefault = type == INPUTS || type == OUTPUTS;
    isDefault = NO;
    [self print];
    PACMIXER_LOG("F:%d:%s posted", [internalId intValue], [name UTF8String]);
    return self;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    if(ports != nil) {
        [ports release];
    }
    if(channels != nil) {
        [channels release];
    }
    [name release];
    [internalId release];
    [_internalName release];
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
    wresize(win, height, width);
    [self printName];
    [self printDefault];
    // Adjust for 'default' box, whether we have one or not
    int ch_height = height - ([ports height] > 2 ? [ports height] : 0) - 1;
    [channels reprint: ch_height];
    [ports reprint: height];
}

-(void) printName {
    if(hidden) {
        return;
    }
    int color = highlighted ? COLOR_PAIR(6) : COLOR_PAIR(5);
    int length = (width - (int)[name length]) / 2;
    if(length < 0) {
        length = 0;
    }
    wattron(win, color | A_BOLD);
    mvwprintw(win, height - 2, 0, "%@",
        [@"" stringByPaddingToLength: width
                          withString: @" "
                     startingAtIndex: 0]
    );
    NSString *sn = [name length] > 8 ? [name substringToIndex: width] : name;
    // CJ - Bottom label of the mixer channel
    mvwprintw(win, height - 2, length, "%@", sn);
    wattroff(win, color | A_BOLD);
}

-(void) printDefault {
    if (hidden) {
        return;
    }
    int y = height - 1;
    int color;
    NSString *label;
    if (hasDefault) {
        if (isDefault) {
            color = COLOR_PAIR(8);
            label = @"  Def.  ";
        } else {
            color = COLOR_PAIR(9) | A_DIM;
            label = @"  ----  ";
        }
    } else {
        color = COLOR_PAIR(1) | A_DIM;
        label = @"";
    }
    wattron(win, color);
    if([label length] > (unsigned)width) {
        mvwprintw(win, y, 0, "%@", [label substringToIndex: width]);
    } else {
        mvwprintw(win, y, 0, "%@",
            [label stringByPaddingToLength: width
                                withString: @" "
                           startingAtIndex: 0]
       );
    }
    wattroff(win, color);
    [TUI refresh];
}

-(Channels*) addChannels: (NSArray*) channels_ {
    int width_ = [channels_ count] + 2;
    int position_ = (width - width_) / 2;
    if(width_ > 8) {
        width = width_;
        [self print];
        [self printName];
        [self printDefault];
    }
    channels = [[Channels alloc] initWithChannels: channels_
                                      andPosition: position_
                                            andId: internalId
                                       andDefault: hasDefault
                                        andParent: win];
    if(!hidden) {
        [channels show];
    }
    return channels;
}

-(id) addOptions: (NSArray*) options_
        withName: (NSString*) optname {
    Options *p = [[Options alloc] initWithWidth: width - 2
                                        andName: optname
                                      andValues: options_
                                          andId: internalId
                                      andParent: win];
    ports = [[Modal alloc] initWithWindow: p];
    [p release];
    if(!hidden) {
        [ports show];
        [self printDefault];
    }
    // Adjust for 'default' box whether we have one or not
    [channels reprint: height - [ports height] - 1];
    PACMIXER_LOG("F:%d:%s options added", [internalId intValue], [name UTF8String]);
    return ports;
}

-(void) replaceOptions: (NSArray*) values {
    [ports replaceValues: values];
    [ports reprint: height];
    // Adjust for 'default' box whether we have one or not
    [channels reprint: height - [ports height] - 1];
}

-(void) setHighlighted: (BOOL) active {
    highlighted = active;
    [self printName];
}

-(void) setPosition: (int) position_ {
    position = position_ + 1;
    mvderwin(win, 0, position);
    [channels adjust];
    [ports adjust];
}

-(void) setValuesByNotification: (NSNotification*) notification {
    NSDictionary* info = [notification userInfo];
    NSArray *volumes = [info objectForKey: @"volumes"];
    if(volumes != nil) {
        for(unsigned int i = 0; i < [volumes count]; ++i) {
            volume_t *vol = [volumes objectAtIndex: i];
            [channels setLevel: [[vol level] intValue] forChannel: i];
            [channels setMute: [vol mute] forChannel: i];
        }
    }

    NSArray *port_names = [info objectForKey: @"portNames"];
    NSArray *port_descs = [info objectForKey: @"portDescriptions"];
    NSString *active_port = [info objectForKey: @"activePort"];
    if(port_names != nil && port_descs != nil && active_port != nil) {
        [self replaceOptions: port_descs];
        [ports replaceMapping: port_names];
        [ports setCurrentByName: active_port];
    }

    View option_type = type == PLAYBACK ? OUTPUTS : INPUTS;
    NSNumber *device = [info objectForKey: @"deviceIndex"];
    if(device != nil) {
        NSString *current_id = [NSString stringWithFormat:
            @"%@_%d", device, option_type];
        [ports setCurrentByName: [[TUI getWidgetWithId: current_id] name]];
    }
}

-(void) setDefault: (BOOL) default_ {
    PACMIXER_LOG("F:%d:%s set as default", [internalId intValue], [name UTF8String]);
    isDefault = default_;
    [self printDefault];
}

-(void) switchDefault {
    //We cannot un-set default in PA, so only switch if it is not set.
    if(!isDefault) {
        [self setDefault: YES];

        NSString *dname = @"serverDefaultsChanged";
        NSDictionary *p = [NSDictionary dictionaryWithObjectsAndKeys:
            self.internalName, type == INPUTS ? @"source" : @"sink", nil];
        NSDictionary *s = [NSDictionary dictionaryWithObjectsAndKeys:
            p, @"defaults", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName: dname
                                                            object: self
                                                          userInfo: s];
    }
}

-(BOOL) canGoInside {
    return channels != nil;
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

-(void) up: (int64_t) speed {
    if(mode == MODE_SETTINGS) {
        [ports up];
    } else {
        [channels up: speed];
    }
}

-(void) down: (int64_t) speed {
    if(mode == MODE_SETTINGS) {
        [ports down];
    } else {
        [channels down: speed];
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

-(int) endHPosition {
    return position + width;
}

-(int) endPosition {
    return [self endHPosition];
}

-(View) type {
    return type;
}

-(NSString*) name {
    return name;
}

-(NSString*) internalId {
    return internalId;
}

-(id) options {
    return ports;
}

-(void) show {
    hidden = NO;
    [self printName];
    [self printDefault];
    [channels show];
    [ports show];
}

-(void) hide {
    hidden = YES;
    [channels hide];
    [ports hide];
}
@end
