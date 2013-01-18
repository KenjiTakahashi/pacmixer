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


#import "channels.h"


@implementation Channel
-(Channel*) initWithIndex: (int) i
              andMaxLevel: (NSNumber*) mlevel_
             andNormLevel: (NSNumber*) nlevel_
                  andMute: (NSNumber*) mute_
                andSignal: (NSString*) signal_
                andParent: (WINDOW*) parent {
    self = [super init];
    signal = [signal_ copy];
    propagate = YES;
    hidden = YES;
    my = getmaxy(parent) - 1;
    win = derwin(parent, my, 1, 0, i + 1);
    if(mute_ != nil) {
        mutable = YES;
    } else {
        mutable = NO;
    }
    if(mlevel_ != nil) {
        maxLevel = [mlevel_ intValue];
        normLevel = [nlevel_ intValue];
        delta = maxLevel / 100;
    }
    [self print];
    return self;
}

-(void) dealloc {
    delwin(win);
    [signal release];
    [super dealloc];
}

-(void) print {
    if(!hidden) {
        if(mute) {
            mvwaddch(win, my - 1, 0, ' ' | COLOR_PAIR(4));
        } else {
            mvwaddch(win, my - 1, 0, ' ' | COLOR_PAIR(2));
        }
        int currentPos = my - 1;
        if(mutable) {
            currentPos -= 2;
        }
        float dy = (float)currentPos / (float)maxLevel;
        int limit = dy * currentLevel;
        int high = dy * normLevel;
        int medium = high * (4. / 5.);
        int low = high * (2. / 5.);
        for(int i = 0; i < my - 3; ++i) {
            int color = COLOR_PAIR(2);
            if(i < limit) {
                if(i >= high) {
                    color = COLOR_PAIR(5);
                } else if(i >= medium) {
                    color = COLOR_PAIR(4);
                } else if(i >= low) {
                    color = COLOR_PAIR(3);
                }
            } else {
                color = COLOR_PAIR(1);
            }
            mvwaddch(win, currentPos - i, 0, ' ' | color);
        }
    }
}

-(void) reprint: (int) height {
    my = height - 1;
    wresize(win, my, 1);
    [self print];
}

-(void) adjust: (int) i {
    mvderwin(win, 0, i + 1);
}

-(void) setMute: (BOOL) mute_ {
    if(mutable) {
        mute = mute_;
    }
    [self print];
}

-(void) setLevel: (int) level_ {
    currentLevel = level_;
    [self print];
    if(propagate) {
        NSDictionary *s = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt: currentLevel], @"volume", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName: signal
                                                            object: self
                                                          userInfo: s];
    }
}

-(int) level {
    return currentLevel;
}

-(void) setLevelAndMuteN: (NSNotification*) notification {
    volume_t *info = [[notification userInfo] objectForKey: @"volumes"];
    [self setLevel: [[info level] intValue]
           andMute: [info mute]];
}

-(void) setLevel: (int) level_
         andMute: (BOOL) mute_ {
    currentLevel = level_;
    mute = mute_;
    [self print];
}

-(void) setPropagation: (BOOL) p {
    propagate = p;
}

-(void) inside {
    wattron(win, A_BLINK);
    [self print];
}

-(void) outside {
    wattroff(win, A_BLINK);
    [self print];
}

-(void) up {
    if(currentLevel < maxLevel + delta) {
        [self setLevel: currentLevel + delta];
    } else if(currentLevel < maxLevel) {
        [self setLevel: maxLevel];
    }
}

-(void) down {
    if(currentLevel > delta) {
        [self setLevel: currentLevel - delta];
    } else if(currentLevel > 0) {
        [self setLevel: 0];
    }
}

-(void) mute {
    if(mutable) {
        if(mute) {
            [self setMute: NO];
        } else {
            [self setMute: YES];
        }
    }
}

-(BOOL) isMuted {
    return mute;
}

-(void) show {
    hidden = NO;
    [self print];
}

-(void) hide {
    hidden = YES;
}
@end


@implementation Channels
-(Channels*) initWithChannels: (NSArray*) channels_
                  andPosition: (int) position_
                        andId: (NSString*) id_
                    andParent: (WINDOW*) parent {
    self = [super init];
    highlight = 0;
    position = position_;
    getmaxyx(parent, my, mx);
    my -= 1;
    mx = [channels_ count] + 2;
    hasPeak = NO;
    hasMute = NO;
    hidden = YES;
    for(int i = 0; i < [channels_ count]; ++i) {
        channel_t *obj = [channels_ objectAtIndex: i];
        if([obj maxLevel] != nil) {
            hasPeak = YES;
        }
        if([obj mutable]) {
            hasMute = YES;
        }
        if(hasPeak && hasMute) {
            break;
        }
    }
    if(!hasMute) {
        my -= 2;
    }
    y = 0;
    if(!hasPeak) {
        y = my - 3;
        my = 3;
    }
    win = derwin(parent, my, mx, y, position);
    [self print];
    internalId = [id_ copy];
    channels = [[NSMutableArray alloc] init];
    for(int i = 0; i < [channels_ count]; ++i) {
        channel_t *obj = [channels_ objectAtIndex: i];
        NSNumber *mute;
        if([obj mutable]) {
            mute = [NSNumber numberWithBool: YES];
        } else {
            mute = nil;
        }
        NSString *bname = [NSString stringWithFormat:
            @"%@_%d", internalId, i];
        NSString *csignal = [NSString stringWithFormat:
            @"%@%@", @"volumeChanged", bname];
        Channel *channel = [[Channel alloc] initWithIndex: i
                                              andMaxLevel: [obj maxLevel]
                                             andNormLevel: [obj normLevel]
                                                  andMute: mute
                                                andSignal: csignal
                                                andParent: win];
        SEL selector = @selector(setLevelAndMuteN:);
        NSString *nname = [NSString stringWithFormat:
            @"%@%@", @"controlChanged", bname];
        [[NSNotificationCenter defaultCenter] addObserver: channel
                                                 selector: selector
                                                     name: nname
                                                   object: nil];
#ifdef DEBUG
debug_fprintf(__func__, "f:%s observer added", [nname UTF8String]);
#endif
        [channels addObject: channel];
    }
    return self;
}

-(void) dealloc {
    for(int i = 0; i < [channels count]; ++i) {
        Channel *channel = [channels objectAtIndex: i];
        [[NSNotificationCenter defaultCenter] removeObserver: channel];
    }
    delwin(win);
    [channels release];
    [internalId release];
    [super dealloc];
}

-(void) print {
    if(!hidden) {
        box(win, 0, 0);
        if(hasPeak && hasMute) {
            mvwaddch(win, my - 3, 0, ACS_LTEE);
            mvwhline(win, my - 3, 1, 0, mx - 2);
            mvwaddch(win, my - 3, mx - 1, ACS_RTEE);
        }
    }
}

-(void) reprint: (int) height {
    height -= 1;
    if(!hasMute) {
        height -= 2;
    }
    my = height;
    for(int i = 0; i < [channels count]; ++i) {
        [(Channel*)[channels objectAtIndex: i] reprint: height];
    }
    if(hasPeak) {
        wresize(win, height, mx);
    } else {
        mvderwin(win, height - 4, position);
    }
    [self print];
}

-(void) setMute: (BOOL) mute forChannel: (int) channel {
    [(Channel*)[channels objectAtIndex: channel] setMute: mute];
}

-(void) setLevel: (int) level forChannel: (int) channel {
    Channel *ch = [channels objectAtIndex: channel];
    [ch setPropagation: NO];
    [ch setLevel: level];
    [ch setPropagation: YES];
}

-(void) adjust {
    mvderwin(win, y, position);
    for(int i = 0; i < [channels count]; ++i) {
        [[channels objectAtIndex: i] adjust: i];
    }
}

-(void) notify: (NSArray*) values {
    NSString *nname = [NSString stringWithFormat:
        @"%@%@", @"volumeChanged", internalId];
    NSDictionary *s = [NSDictionary dictionaryWithObjectsAndKeys:
        values, @"volume", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName: nname
                                                        object: self
                                                      userInfo: s];
}

-(BOOL) previous {
    if(inside && highlight > 0) {
        [(Channel*)[channels objectAtIndex: highlight] outside];
        highlight -= 1;
        [(Channel*)[channels objectAtIndex: highlight] inside];
        return NO;
    }
    return YES;
}

-(BOOL) next {
    if(inside && highlight < [channels count] - 1) {
        [(Channel*)[channels objectAtIndex: highlight] outside];
        highlight += 1;
        [(Channel*)[channels objectAtIndex: highlight] inside];
        return NO;
    }
    return YES;
}

-(void) upDown_: (NSString*) selname {
    if(inside) {
        Channel *channel = [channels objectAtIndex: highlight];
        [channel performSelector: NSSelectorFromString(selname)];
    } else {
        int count = [channels count];
        NSMutableArray *values = [NSMutableArray arrayWithCapacity: count];
        for(int i = 0; i < count; ++i) {
            Channel *channel = [channels objectAtIndex: i];
            [channel setPropagation: NO];
            [channel performSelector: NSSelectorFromString(selname)];
            [values addObject: [NSNumber numberWithInt: [channel level]]];
            [channel setPropagation: YES];
        }
        [self notify: values];
    }
}

-(void) up {
    [self upDown_: @"up"];
}

-(void) down {
    [self upDown_: @"down"];
}

-(void) inside {
    if(!inside) {
        inside = YES;
        [(Channel*)[channels objectAtIndex: highlight] inside];
    }
}

-(void) outside {
    if(inside) {
        inside = NO;
        [(Channel*)[channels objectAtIndex: highlight] outside];
    }
}

-(void) mute {
    for(int i = 0; i < [channels count]; ++i) {
        [(Channel*)[channels objectAtIndex: i] mute];
    }
    NSString *nname = [NSString stringWithFormat:
        @"%@%@", @"muteChanged", internalId];
    BOOL muted = [(Channel*)[channels objectAtIndex: 0] isMuted];
    NSDictionary *s = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithBool: muted], @"mute", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName: nname
                                                        object: self
                                                      userInfo: s];
}

-(void) show {
    hidden = NO;
    [self print];
    for(int i = 0; i < [channels count]; ++i) {
        Channel *channel = [channels objectAtIndex: i];
        [channel print];
        [channel show];
    }
}

-(void) hide {
    hidden = YES;
    for(int i = 0; i < [channels count]; ++i) {
        [(Channel*)[channels objectAtIndex: i] hide];
    }
}
@end
