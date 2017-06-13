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
#import "../frontend.h"


@implementation Channel
-(Channel*) initWithIndex: (int) i
              andMaxLevel: (NSNumber*) mlevel_
             andNormLevel: (NSNumber*) nlevel_
                  andMute: (NSNumber*) mute_
                andSignal: (NSString*) signal_
                andParent: (WINDOW*) parent
          andNumberParent: (WINDOW*) numberParent {
    self = [super init];
    signal = [signal_ copy];
    propagate = YES;
    hidden = YES;

    // Set up our channel-drawing window (just a single char slice)
    my = getmaxy(parent) - 1;
    win = derwin(parent, my, 1, 0, i + 1);

    // Set up our window where we'll draw our numeric level.  For now
    // we're only going to support displaying two channels.  Really
    // we should be more clever about it and check the width of the
    // parent and if we have room for more, draw more, but since all
    // my channels are only stereo, I'm just doing this for now.
    numberAlignRight = true;
    numberWin = NULL;
    if (i == 0) {
        numberWin = derwin(numberParent, 1, 3, 0, 0);
        numberAlignRight = true;
    } else if (i == 1) {
        numberWin = derwin(numberParent, 1, 3, 0, 5);
        numberAlignRight = false;
    }

    if(mute_ != nil) {
        isMutable = YES;
    } else {
        isMutable = NO;
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
    if(hidden) {
        return;
    }

    // Mute indicator
    int color = mute ? COLOR_PAIR(4) : COLOR_PAIR(2);
    wattron(win, color | A_BOLD);
    mvwaddch(win, my - 1, 0, (mute ? 'M' : 'O') | color);
    wattroff(win, color | A_BOLD);

    // Actual mixer bar
    int currentPos = my - 1;
    if(isMutable) {
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

    // Now draw our numeric levels
    float percent = (float)currentLevel / (float)normLevel * 100.;
    if (numberWin != NULL) {
        wattron(numberWin, COLOR_PAIR(10) | A_BOLD);
        NSString *percentStr = [NSString stringWithFormat:@"%0.0f", percent];
        if (numberAlignRight) {
            // Taken from a comment at https://stackoverflow.com/questions/964322/padding-string-to-left
            NSString *padded = [@"   " stringByAppendingString:percentStr];
            mvwprintw(numberWin, 0, 0, [[padded substringFromIndex:[padded length] - 3] UTF8String]);
        } else {
            mvwprintw(numberWin, 0, 0, "%@",
                [percentStr stringByPaddingToLength: 3
                                         withString: @" "
                                    startingAtIndex: 0]
            );
        }
        wattroff(numberWin, COLOR_PAIR(10) | A_BOLD);
    }

    [TUI refresh];
}

-(void) resetNumberWin {
    // Resets our numberWin derived window, used for displaying numeric
    // levels.  The parent window for these has already been moved in
    // the Channels code, but we need to do it here as well, even though
    // the locations are pretty much hardcoded.  The geometry doesn't
    // actually update, otherwise.
    //
    // Also, this is a bit silly and Not The Right Way To Do It,
    // but it's what I'm doing regardless.  See Channel.initWithIndex
    // for where these offsets are stored initially.
    if (numberWin != NULL) {
        if (numberAlignRight) {
            mvderwin(numberWin, 0, 0);
        } else {
            mvderwin(numberWin, 0, 5);
        }
    }
}

-(void) reprint: (int) height {
    my = height - 1;
    wresize(win, my, 1);
    [self resetNumberWin];
    [self print];
}

-(void) adjust: (int) i {
    mvderwin(win, 0, i + 1);
    [self resetNumberWin];
}

-(void) setMute: (BOOL) mute_ {
    if(isMutable) {
        mute = mute_;
        [self print];
    }
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

-(void) up: (int64_t) speed {
    if(currentLevel + delta * speed < maxLevel) {
        [self setLevel: currentLevel + delta * speed];
    } else if(currentLevel < maxLevel) {
        [self setLevel: maxLevel];
    }
}

-(void) down: (int64_t) speed {
    if(currentLevel > delta * speed) {
        [self setLevel: currentLevel - delta * speed];
    } else if(currentLevel > 0) {
        [self setLevel: 0];
    }
}

-(void) mute {
    [self setMute: !mute];
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
                   andDefault: (BOOL) default_
                    andParent: (WINDOW*) parent {
    self = [super init];
    highlight = 0;
    position = position_;
    getmaxyx(parent, my, mx);
    int parent_mx = mx;
    my -= 3;
    mx = [channels_ count] + 2;
    hasPeak = NO;
    hasMute = NO;
    hidden = YES;
    for(unsigned int i = 0; i < [channels_ count]; ++i) {
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
    numberWin = derwin(parent, 1, parent_mx, my, 0);
    [self print];
    internalId = [id_ copy];
    channels = [[NSMutableArray alloc] init];
    for(unsigned int i = 0; i < [channels_ count]; ++i) {
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
                                                andParent: win
                                          andNumberParent: numberWin];
        [channels addObject: channel];
    }
    return self;
}

-(void) dealloc {
    for(unsigned int i = 0; i < [channels count]; ++i) {
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

        // The main box around the channel bars
        box(win, 0, 0);

        // Dividing line between level and mute indicator
        if(hasPeak && hasMute) {
            mvwaddch(win, my - 3, 0, ACS_LTEE);
            mvwhline(win, my - 3, 1, 0, mx - 2);
            mvwaddch(win, my - 3, mx - 1, ACS_RTEE);
        }

        // Flourish between level numbers
        if (numberWin != NULL) {
            mvwprintw(numberWin, 0, 3, "<>");
        }

        [TUI refresh];
    }
}

-(void) reprint: (int) height {
    height -= 2;
    if(!hasMute) {
        height -= 2;
    }
    my = height;
    if(hasPeak) {
        wresize(win, height, mx);
    } else {
        mvderwin(win, height - 4, position);
    }
    mvderwin(numberWin, height, 0);
    for(unsigned int i = 0; i < [channels count]; ++i) {
        [(Channel*)[channels objectAtIndex: i] reprint: height];
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
    mvderwin(numberWin, getmaxy(win), 0);
    for(unsigned int i = 0; i < [channels count]; ++i) {
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

-(void) upDown_: (UpDown) updown speed: (int64_t) speed {
    if(inside) {
        Channel *channel = [channels objectAtIndex: highlight];
        if(updown == UP) {
            [channel up: speed];
        } else {
            [channel down: speed];
        }
    } else {
        int count = [channels count];
        NSMutableArray *values = [NSMutableArray arrayWithCapacity: count];
        for(int i = 0; i < count; ++i) {
            Channel *channel = [channels objectAtIndex: i];
            [channel setPropagation: NO];
            if(updown == UP) {
                [channel up: speed];
            } else {
                [channel down: speed];
            }
            [values addObject: [NSNumber numberWithInt: [channel level]]];
            [channel setPropagation: YES];
        }
        [self notify: values];
    }
}

-(void) up: (int64_t) speed {
    [self upDown_: UP speed: speed];
}

-(void) down: (int64_t) speed {
    [self upDown_: DOWN speed: speed];
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
    for(unsigned int i = 0; i < [channels count]; ++i) {
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
    for(unsigned int i = 0; i < [channels count]; ++i) {
        Channel *channel = [channels objectAtIndex: i];
        [channel print];
        [channel show];
    }
}

-(void) hide {
    hidden = YES;
    for(unsigned int i = 0; i < [channels count]; ++i) {
        [(Channel*)[channels objectAtIndex: i] hide];
    }
}
@end
