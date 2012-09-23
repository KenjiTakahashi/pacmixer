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


#import "middleware.h"


void callback_add_func(void *self_, const char *name, uint32_t idx, const backend_channel_t *channels, uint8_t chnum) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    Middleware *self = self_;
    [self retain];
    NSMutableArray *ch = [NSMutableArray arrayWithCapacity: chnum];
    for(int i = 0; i < chnum; ++i) {
        NSNumber *lvl = [NSNumber numberWithInt: channels[i].maxLevel];
        NSNumber *nlvl = [NSNumber numberWithInt: channels[i].normLevel];
        BOOL mut = channels[i].mutable == 1 ? YES : NO;
        [ch addObject: [[channel_t alloc] initWithMaxLevel: lvl
                                              andNormLevel: nlvl
                                                andMutable: mut]];
        Block *block = [self addBlockWithId: idx
                                   andIndex: i];
        NSString *sname = [NSString stringWithFormat:
            @"%@%d%d", @"volumeChanged", idx, i];
        [[NSNotificationCenter defaultCenter] addObserver: block
                                                 selector: @selector(setVolume:)
                                                     name: sname
                                                   object: nil];
    }
    NSDictionary *s = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSString stringWithUTF8String: name], @"name",
        [NSNumber numberWithInt: idx], @"id",
        ch, @"channels",  nil];
    NSString *nname = [NSString stringWithString: @"controlAppeared"];
    [[NSNotificationCenter defaultCenter] postNotificationName: nname
                                                        object: self
                                                      userInfo: s];
    [pool release];
}

void callback_update_func(void *self_, uint32_t idx, const backend_volume_t *volumes, uint8_t chnum) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    Middleware *self = self_;
    for(int i = 0; i < chnum; ++i) {
        NSNumber *lvl = [NSNumber numberWithInt: volumes[i].level];
        BOOL mut = volumes[i].mute == 1 ? YES : NO;
        NSNumber *id_ = [NSNumber numberWithInt: idx];
        volume_t *v = [[volume_t alloc] initWithLevel: lvl
                                              andMute: mut];
        NSDictionary *s = [NSDictionary dictionaryWithObjectsAndKeys:
            v, @"volumes", nil];
        NSString *nname = [NSString stringWithFormat:
        @"%@%@%d", @"controlChanged", id_, i];
        [[NSNotificationCenter defaultCenter] postNotificationName: nname
                                                            object: self
                                                          userInfo: s];
        [v release];
    }
    [pool release];
}

void callback_remove_func(void *self_, uint32_t idx) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    Middleware *self = self_;
    NSDictionary *s = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInt: idx], @"id", nil];
    NSString *nname = [NSString stringWithString: @"controlDisappeared"];
    [[NSNotificationCenter defaultCenter] postNotificationName: nname
                                                        object: self
                                                      userInfo: s];
    [pool release];
}

@implementation Block
-(Block*) initWithContext: (context_t*) context_
                    andId: (uint32_t) idx_
                 andIndex: (int) i_ {
    self = [super init];
    idx = idx_;
    i = i_;
    context = context_;
    return self;
}

-(void) setVolume: (NSNotification*) notification {
    NSNumber *v = [[notification userInfo] objectForKey: @"volume"];
    backend_volume_set(context, idx, i, [v intValue]);
}
@end

@implementation Middleware
-(Middleware*) init {
    self = [super init];
    blocks = [[NSMutableArray alloc] init];
    context = backend_new();
    callback = malloc(sizeof(callback_t));
    callback->add = callback_add_func;
    callback->update = callback_update_func;
    callback->remove = callback_remove_func;
    callback->self = self;
    backend_init(context, callback);
    return self;
}

-(void) dealloc {
    [blocks release];
    backend_destroy(context);
    free(callback);
    [super dealloc];
}

-(Block*) addBlockWithId: (uint32_t) idx
                andIndex: (int) i {
    Block *block = [[Block alloc] initWithContext: context
                                            andId: idx
                                         andIndex: i];
    [blocks addObject: block];
    [block release];
    return block;
}
@end
