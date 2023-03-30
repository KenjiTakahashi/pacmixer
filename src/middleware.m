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


#import "middleware.h"


#define CAPITALIZE_port @"Port"
#define CAPITALIZE_profile @"Profile"
#define _CALLBACK_DO_OPTION(__option__)\
    char ** const names = data->option->names;\
    char ** const descs = data->option->descriptions;\
    const char *active = data->option->active;\
    uint8_t pnum = data->option->size;\
    NSMutableArray *pd = [NSMutableArray arrayWithCapacity: pnum];\
    NSMutableArray *pn = [NSMutableArray arrayWithCapacity: pnum];\
    for(int i = 0; i < pnum; ++i) {\
        [pn addObject: [NSString stringWithUTF8String: names[i]]];\
        [pd addObject: [NSString stringWithUTF8String: descs[i]]];\
    }\
    NSString *a = [NSString stringWithUTF8String: active];\
    [s setObject: pn forKey: @#__option__"Names"];\
    [s setObject: pd forKey: @#__option__"Descriptions"];\
    [s setObject: a forKey: @"active"CAPITALIZE_ ## __option__];

void callback_add_func(
    void *self_, const char *name, backend_entry_type type,
    uint32_t idx, backend_data_t *data
) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    Middleware *self = self_;
    [self retain];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSString *sname = nil;
    SEL ssel;
    //This block is used to set control-wise values, so index is
    //not important. This is *channel's* number, nothing to do with idx.
    Block *block = [self addBlockWithId: idx
                               andIndex: -1
                                andType: type];
    if(type == CARD && data->option != NULL) {
        sname = [NSString stringWithFormat:
            @"activeOptionChanged%d_%d", idx, type];
        ssel = @selector(setCardActiveProfile:);

        NSMutableDictionary *s = [NSMutableDictionary dictionaryWithObjectsAndKeys:
            [NSString stringWithUTF8String: name], @"name",
            [NSNumber numberWithInt: idx], @"id",
            [NSNumber numberWithInt: type], @"type", nil];
        _CALLBACK_DO_OPTION(profile);

        [center postNotificationName: @"cardAppeared"
                              object: self
                            userInfo: s];
    } else if(data->channels != NULL && data->volumes != NULL) {
        uint8_t chnum = data->channels_num;
        NSMutableArray *ch = [NSMutableArray arrayWithCapacity: chnum];
        NSMutableArray *chv = [NSMutableArray arrayWithCapacity: chnum];
        for(uint8_t i = 0; i < chnum; ++i) {
            const backend_channel_t chn = data->channels[i];
            const backend_volume_t vol = data->volumes[i];
            [ch addObject: [[channel_t alloc] initWithMaxLevel: chn.maxLevel
                                                  andNormLevel: chn.normLevel
                                                    andMutable: chn.isMutable]];
            [chv addObject: [[volume_t alloc] initWithLevel: vol.level
                                                    andMute: vol.mute]];
            Block *block = [self addBlockWithId: idx
                                       andIndex: i
                                        andType: type];
            NSString *siname = [NSString stringWithFormat:
                @"volumeChanged%d_%d_%d", idx, type, i];
            [center addObserver: block
                       selector: @selector(setVolume:)
                           name: siname
                         object: nil];
            PACMIXER_LOG("M:%s observer added", [siname UTF8String]);
        }
        sname = [NSString stringWithFormat:
            @"volumeChanged%d_%d", idx, type];
        ssel = @selector(setVolumes:);
        NSString *mname = [NSString stringWithFormat:
            @"muteChanged%d_%d", idx, type];
        [center addObserver: block
                   selector: @selector(setMute:)
                       name: mname
                     object: nil];
        PACMIXER_LOG("M:%s observer added", [mname UTF8String]);
        PACMIXER_LOG("M:%d:%s:%s received", idx, name, data->internalName);
        NSMutableDictionary *s = [
            NSMutableDictionary dictionaryWithObjectsAndKeys:
            [NSString stringWithUTF8String: name], @"name",
            [NSNumber numberWithInt: idx], @"id",
            ch, @"channels", chv, @"volumes",
            [NSNumber numberWithInt: type], @"type",
            [NSString stringWithUTF8String: data->internalName],
            @"internalName",
        nil];
        if(type == SINK_INPUT || type == SOURCE_OUTPUT) {
            NSNumber *device = [NSNumber numberWithInt: data->device];
            [s setObject: device forKey: @"deviceIndex"];
            NSString *psname = [NSString stringWithFormat:
                @"activeOptionChanged%d_%d", idx, type];
            [center addObserver: block
                       selector: @selector(setActiveDevice:)
                           name: psname
                         object: nil];
        }
        if(data->option != NULL) {
            _CALLBACK_DO_OPTION(port);

            NSString *psname = [NSString stringWithFormat:
                @"activeOptionChanged%d_%d", idx, type];
            [center addObserver: block
                       selector: @selector(setActivePort:)
                           name: psname
                         object: nil];
        }
        [center postNotificationName: @"controlAppeared"
                              object: self
                            userInfo: s];
    }
    if(sname != nil) {
        [center addObserver: block
                   selector: ssel
                       name: sname
                     object: nil];
    }
    PACMIXER_LOG("M:%s observer added", [sname UTF8String]);
    [pool release];
}

void callback_update_func(
    void *self_, backend_entry_type type,
    uint32_t idx, const backend_data_t *data
) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    Middleware *self = self_;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    if(type == SERVER && data->defaults != NULL) {
        NSString *default_sink = [NSString stringWithUTF8String:
            data->defaults->sink];
        NSString *default_source = [NSString stringWithUTF8String:
            data->defaults->source];

        NSDictionary *p = [NSDictionary dictionaryWithObjectsAndKeys:
            default_sink, @"sink", default_source, @"source", nil];
        NSDictionary *s = [NSDictionary dictionaryWithObjectsAndKeys:
            p, @"defaults", nil];
        NSString *nname = @"serverDefaultsAppeared";

        [center postNotificationName: nname
                              object: self
                            userInfo: s];
    } else if(type == CARD && data->option != NULL) {
        NSMutableDictionary *s = [NSMutableDictionary dictionary];
        _CALLBACK_DO_OPTION(profile);

        NSString *nname = [NSString stringWithFormat:
            @"cardProfileChanged%d_%d", idx, type];
        [center postNotificationName: nname
                              object: self
                            userInfo: s];
        PACMIXER_LOG("M:%s notification posted", [nname UTF8String]);
    } else if(data->volumes != NULL) {
        uint8_t chnum = data->channels_num;
        NSMutableArray *volumes = [[NSMutableArray alloc] init];
        for(int i = 0; i < chnum; ++i) {
            const backend_volume_t vol = data->volumes[i];
            volume_t *v = [[volume_t alloc] initWithLevel: vol.level
                                                  andMute: vol.mute];
            [volumes addObject: v];
            [v release];
        }
        NSMutableDictionary *s = [
            NSMutableDictionary dictionaryWithObjectsAndKeys:
            volumes, @"volumes", nil];
        [volumes release];
        if(type == SINK_INPUT || type == SOURCE_OUTPUT) {
            NSNumber *device = [NSNumber numberWithInt: data->device];
            [s setObject: device forKey: @"deviceIndex"];
        }
        if(data->option != NULL) {
            _CALLBACK_DO_OPTION(port);
        }
        NSString *nname = [NSString stringWithFormat:
        @"controlChanged%d_%d", idx, type];
        [center postNotificationName: nname
                              object: self
                            userInfo: s];
        PACMIXER_LOG("M:%s notification posted", [nname UTF8String]);
    }
    [pool release];
}

void callback_remove_func(void *self_, uint32_t idx, backend_entry_type type) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    Middleware *self = self_;
    NSDictionary *s = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSString stringWithFormat: @"%d_%d", idx, type], @"id", nil];
    NSString *nname = @"controlDisappeared";
    [[NSNotificationCenter defaultCenter] postNotificationName: nname
                                                        object: self
                                                      userInfo: s];
    PACMIXER_LOG("M:%d:%s notification posted", idx, [nname UTF8String]);
    [pool release];
}

void callback_state_func(void *self_, server_state state) {
#if GNUSTEP_BASE_MINOR_VERSION < 24
    [NSThread _createThreadForCurrentPthread];
#endif
    Middleware *self = self_;
    NSString *name = state == S_CAME ? @"backendAppeared" : @"backendGone";
    [[NSNotificationCenter defaultCenter] postNotificationName: name
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
    data = [[NSMutableDictionary alloc] init];
    return self;
}

-(void) dealloc {
    [data release];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [super dealloc];
}

-(void) addDataByCArray: (int) n
             withValues: (char**const) values
                andKeys: (char**const) keys {
    for(int j = 0; j < n; ++j) {
        NSString *val = [NSString stringWithUTF8String: values[j]];
        NSString *key = [NSString stringWithUTF8String: keys[j]];
        [data setObject: val forKey: key];
    }
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
    free(values);
}

-(void) setMute: (NSNotification*) notification {
    BOOL v = [[[notification userInfo] objectForKey: @"mute"] boolValue];
    backend_mute_set(context, type, idx, v ? 1 : 0);
}

-(void) setCardActiveProfile: (NSNotification*) notification {
    NSString *active = [[notification userInfo] objectForKey: @"option"];
    backend_card_profile_set(context, type, idx, [active UTF8String]);
}

-(void) setActivePort: (NSNotification*) notification {
    NSString *active = [[notification userInfo] objectForKey: @"option"];
    backend_port_set(context, type, idx, [active UTF8String]);
}

-(void) setActiveDevice: (NSNotification*) notification {
    NSString *active = [[notification userInfo] objectForKey: @"option"];
    backend_device_set(context, type, idx, [active UTF8String]);
}

-(void) setDefaults: (NSNotification*) notification {
    NSDictionary *userInfo = [notification userInfo];
    NSDictionary *defaults = [userInfo objectForKey: @"defaults"];
    NSString *default_sink = [defaults objectForKey: @"sink"];
    NSString *default_source = [defaults objectForKey: @"source"];

    if(default_sink != nil) {
        backend_default_set(context, SINK, [default_sink UTF8String]);
    }
    if(default_source != nil) {
        backend_default_set(context, SOURCE, [default_source UTF8String]);
    }
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
    callback->state = callback_state_func;
    callback->self = self;

    context = backend_new(callback);

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    Block *block = [self addBlockWithId: -1
                               andIndex: -1
                                andType: CARD]; //It does not matter.
    [center addObserver: block
               selector: @selector(setDefaults:)
                   name: @"serverDefaultsChanged"
                 object: nil];

    [center addObserver: self
               selector: @selector(restart:)
                   name: @"backendGone"
                 object: self];
    return self;
}

-(void) restart: (NSNotification*) _ {
    backend_init(context, callback);
}

-(void) dealloc {
    [blocks release];
    if(context != NULL) {
        backend_destroy(context);
    }
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
