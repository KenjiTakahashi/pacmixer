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


#import "middleware.h"


void callback_add_func(
    void *self_, const char *name, backend_entry_type type, uint32_t idx,
    const backend_channel_t *channels, const backend_volume_t *volumes,
    const backend_card_t *card,
    uint8_t chnum
) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    Middleware *self = self_;
    [self retain];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSString *sname;
    SEL ssel;
    Block *block = [self addBlockWithId: idx
                               andIndex: -1
                                andType: type];
    if(type == CARD) {
        sname = [NSString stringWithFormat:
            @"%@%d_%d", @"cardActiveProfileChanged", idx, type];
        ssel = @selector(setCardActiveProfile:);
        char ** const profiles = card->profiles;
        const char *active = card->active_profile;
        card_profile_t *p = [[card_profile_t alloc] initWithProfiles: profiles
                                                        andNProfiles: chnum
                                                    andActiveProfile: active];
        NSDictionary *s = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSString stringWithUTF8String: name], @"name",
            [NSNumber numberWithInt: idx], @"id",
            p, @"profile", [NSNumber numberWithInt: type], @"type", nil];
        [center postNotificationName: @"cardAppeared"
                              object: self
                            userInfo: s];
    } else {
        NSMutableArray *ch = [NSMutableArray arrayWithCapacity: chnum];
        NSMutableArray *chv = [NSMutableArray arrayWithCapacity: chnum];
        for(int i = 0; i < chnum; ++i) {
            const backend_channel_t chn = channels[i];
            [ch addObject: [[channel_t alloc] initWithMaxLevel: chn.maxLevel
                                                  andNormLevel: chn.normLevel
                                                    andMutable: chn.mutable]];
            [chv addObject: [[volume_t alloc] initWithLevel: volumes[i].level
                                                    andMute: volumes[i].mute]];
            Block *block = [self addBlockWithId: idx
                                       andIndex: i
                                        andType: type];
            NSString *siname = [NSString stringWithFormat:
                @"%@%d_%d_%d", @"volumeChanged", idx, type, i];
            [center addObserver: block
                       selector: @selector(setVolume:)
                           name: siname
                         object: nil];
#ifdef DEBUG
debug_fprintf(__func__, "m:%s observer added", [siname UTF8String]);
#endif
        }
        sname = [NSString stringWithFormat:
            @"%@%d_%d", @"volumeChanged", idx, type];
        ssel = @selector(setVolumes:);
        NSString *mname = [NSString stringWithFormat:
            @"%@%d_%d", @"muteChanged", idx, type];
        [center addObserver: block
                   selector: @selector(setMute:)
                       name: mname
                     object: nil];
#ifdef DEBUG
debug_fprintf(__func__, "m:%s observer added", [mname UTF8String]);
debug_fprintf(__func__, "m:%d:%s received", idx, name);
#endif
        NSDictionary *s = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSString stringWithUTF8String: name], @"name",
            [NSNumber numberWithInt: idx], @"id",
            ch, @"channels", chv, @"volumes",
            [NSNumber numberWithInt: type], @"type", nil];
        [center postNotificationName: @"controlAppeared"
                              object: self
                            userInfo: s];
    }
    [center addObserver: block
               selector: ssel
                   name: sname
                 object: nil];
#ifdef DEBUG
debug_fprintf(__func__, "m:%s observer added", [sname UTF8String]);
#endif
    [pool release];
}

void callback_update_func(
    void *self_, backend_entry_type type, uint32_t idx,
    const backend_volume_t *volumes, const backend_card_t *card,
    uint8_t chnum
) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    Middleware *self = self_;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    if(type == CARD) {
        char ** const profiles = card->profiles;
        const char *active = card->active_profile;
        card_profile_t *p = [[card_profile_t alloc] initWithProfiles: profiles
                                                        andNProfiles: chnum
                                                    andActiveProfile: active];
        NSDictionary *s = [NSDictionary dictionaryWithObjectsAndKeys:
            p, @"profile", nil];
        NSString *nname = [NSString stringWithFormat:
            @"%@%d_%d", @"cardProfileChanged", idx, type];
        [center postNotificationName: nname
                              object: self
                            userInfo: s];
#ifdef DEBUG
debug_fprintf(__func__, "m:%s notification posted", [nname UTF8String]);
#endif
    } else {
        for(int i = 0; i < chnum; ++i) {
            volume_t *v = [[volume_t alloc] initWithLevel: volumes[i].level
                                                  andMute: volumes[i].mute];
            NSDictionary *s = [NSDictionary dictionaryWithObjectsAndKeys:
                v, @"volumes", nil];
            NSString *nname = [NSString stringWithFormat:
            @"%@%d_%d_%d", @"controlChanged", idx, type, i];
            [center postNotificationName: nname
                                  object: self
                                userInfo: s];
#ifdef DEBUG
debug_fprintf(__func__, "m:%s notification posted", [nname UTF8String]);
#endif
            [v release];
        }
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

void callback_state_func(void *self_) {
    Middleware *self = self_;
    [[NSNotificationCenter defaultCenter] postNotificationName: @"backendGone"
                                                        object: self
                                                      userInfo: nil];
}

@implementation Block
-(Block*) initWithContext: (context_t*) context_
                    andId: (uint32_t) idx_
                 andIndex: (int) i_
                  andType: (backend_entry_type) type_ {
    self = [super init];
    context = context_;
    idx = idx_;
    i = i_;
    type = type_;
    return self;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [super dealloc];
}

-(void) setVolume: (NSNotification*) notification {
    NSNumber *v = [[notification userInfo] objectForKey: @"volume"];
    backend_volume_set(context, type, idx, i, [v intValue]);
}

-(void) setVolumes: (NSNotification*) notification {
    NSArray *v = [[notification userInfo] objectForKey: @"volume"];
    int count = [v count];
    int *values = malloc(count * sizeof(int));
    for(int j = 0; j < count; ++j) {
        values[j] = [[v objectAtIndex: j] intValue];
    }
    backend_volume_setall(context, type, idx, values, count);
}

-(void) setMute: (NSNotification*) notification {
    BOOL v = [[[notification userInfo] objectForKey: @"mute"] boolValue];
    backend_mute_set(context, type, idx, v ? 1 : 0);
}

-(void) setCardActiveProfile: (NSNotification*) notification {
    NSString *name = [[notification userInfo] objectForKey: @"profile"];
    backend_card_profile_set(context, type, idx, [name UTF8String]);
}
@end

@implementation Middleware
-(Middleware*) init {
    self = [super init];
    blocks = [[NSMutableArray alloc] init];
    callback = malloc(sizeof(callback_t));
    callback->add = callback_add_func;
    callback->update = callback_update_func;
    callback->remove = callback_remove_func;
    callback->self = self;
    state_callback = malloc(sizeof(state_callback_t));
    state_callback->func = callback_state_func;
    state_callback->self = self;
    [NSThread detachNewThreadSelector: @selector(initContext)
                             toTarget: self
                           withObject: nil];
    return self;
}

-(void) initContext {
    context = backend_new(state_callback);
    backend_init(context, callback);
    NSString *name = @"backendAppeared";
    [[NSNotificationCenter defaultCenter] postNotificationName: name
                                                        object: self
                                                      userInfo: nil];
}

-(void) dealloc {
    [blocks release];
    backend_destroy(context);
    free(state_callback);
    free(callback);
    [super dealloc];
}

-(Block*) addBlockWithId: (uint32_t) idx
                andIndex: (int) i
                 andType: (backend_entry_type) type {
    Block *block = [[Block alloc] initWithContext: context
                                            andId: idx
                                         andIndex: i
                                          andType: type];
    [blocks addObject: block];
    [block release];
    return block;
}
@end
