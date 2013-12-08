/*
 This is a part of pacmixer @ http://github.com/KenjiTakahashi/pacmixer
 Karol "Kenji Takahashi" Woźniak © 2012 - 2013

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


#ifdef TESTS
#include "../tests/mock_pulseaudio.h"
#else
#include <pulse/pulseaudio.h>
#endif
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#ifdef DEBUG
#include "debug.h"
#endif


/**
 * Holds information necessary to communicate with PA server.
 * Returned from backend_init() and passed to all other manipulation
 * functions.
 *
 * @see backend_new()
 */
typedef struct CONTEXT {
    pa_threaded_mainloop *loop; /**< Ref to PA event loop. */
    pa_context *context; /**< PA context. */
    pa_context_state_t state; /**< PA server state. */
} context_t;

/**
 * Holds references to higher level callbacks and the middleware object.
 */
typedef struct CALLBACK {
    void *add;
    void *update;
    void *remove;
    void *self;
} callback_t;

/**
 * Holds information necessary to fire a state callback.
 */
typedef struct STATE_CALLBACK {
    pa_context_state_t *state; /**< PA server state. */
    void *func; /**< Callback function. */
    void *self; /**< Middleware object. */
} state_callback_t;

/**
 * Holds information about channel.
 */
typedef struct BACKEND_CHANNEL {
    int maxLevel;
    int normLevel;
    int isMutable;
} backend_channel_t;

/**
 * Holds information about channel's current setting.
 */
typedef struct BACKEND_VOLUME {
    int level;
    int mute;
} backend_volume_t;

/**
 * Holds a list of options with their names and descriptions.
 * Used to store cards profiles and controls ports.
 */
typedef struct BACKEND_OPTION {
    char **descriptions;
    char **names;
    char *active;
    uint8_t size;
} backend_option_t;

/**
 * Holds information about default/fallback options of the PA server.
 */
typedef struct BACKEND_DEFAULT {
    char *sink;
    char *source;
} backend_default_t;

/**
 * Structure used to leverage data to higher level.
 * Middleware should check if all the structures inside are initialized,
 * because it is not guaranted in any way and it is OK if some are not.
 */
typedef struct BACKEND_DATA {
    backend_channel_t *channels;
    backend_volume_t *volumes;
    uint8_t channels_num;
    backend_option_t *option;
    backend_default_t *defaults;
    char *internalName;
} backend_data_t;

/**
 * Controls types.
 */
typedef enum {
    SINK,
    SINK_INPUT,
    SOURCE,
    SOURCE_OUTPUT,
    CARD, /**< Virtual type representing whole sound card. */
    SERVER /**< Virtual type representing whole PA server. */
} backend_entry_type;

/**
 * Initializes all necessary mechanisms and data.
 *
 * @param state_callback Callback fired when PA server changes it's state.
 *        Meant to be used mainly for dealing with lost/failed connection.
 *
 * @return CONTEXT which contains all necessary information about connection.
 *         It will be passed as first argument to all other API parts.
 */
context_t *backend_new(state_callback_t*);

/**
 * Starts the PA event loop and subscribes appropriate events.
 *
 * @param context CONTEXT as returned by backend_init().
 * @param callback Enum with higher level (middleware) callbacks.
 */
void backend_init(context_t*, callback_t*);

/**
 * Stops PA event loop and frees resources.
 *
 * @param context CONTEXT as returned by backend_init().
 */
void backend_destroy(context_t*);

/**
 * Sets volume for a single channel.
 *
 * @param c CONTEXT as returned by backend_init().
 * @param type Type of the control.
 *        By specifing type, we can use this one function for every control.
 * @param idx PA internal control index.
 * @param i Channel index (starting from 0).
 * @param v New value to set.
 *
 * @see backend_volume_setall()
 */
void backend_volume_set(context_t*, backend_entry_type, uint32_t, int, int);

/**
 * Sets volume for multiple channels at once.
 * Might be useful to avoid clashes,
 * e.g. when there are multiple channels and they're locked together.
 *
 * @param c CONTEXT as returned by backend_init().
 * @param type Type of the control.
 * @param idx PA internal control index.
 * @param v Array of new values to set.
 * @param chnum Number of items in @param v.
 *
 * @see backend_volume_set()
 */
void backend_volume_setall(context_t*, backend_entry_type, uint32_t, int*, int);

/**
 * Sets mute value for control.
 * Note that there is not way to mute a single channel!
 *
 * @param c CONTEXT as returned by backend_init().
 * @param type Type of the control.
 * @param idx PA internal control index.
 * @param v New value to set. It's boolean: 0=False, otherwise=True.
 */
void backend_mute_set(context_t*, backend_entry_type, uint32_t, int);

/**
 * Sets active profile for a card.
 *
 * @param c CONTEXT as returned by backend_init().
 * @param type Type of the control. It is always CARD here.
 * @param idx PA internal control index.
 * @param active Active profile's name.
 */
void backend_card_profile_set(context_t*, backend_entry_type, uint32_t, const char*);

/**
 * Sets default sink/source for given context.
 * Only SINK and SOURCE entry types have this property,
 * for other types this function does nothing.
 *
 * @param c CONTEXT as returned by backend_init().
 * @param type Type of the control.
 * @param internalName Name of the control to be set as default.
 */
void backend_default_set(context_t*, backend_entry_type, const char*);

/**
 * Sets active port value for a control.
 *
 * @param c CONTEXT as returned by backend_init().
 * @param type Type of the control. It should be SINK or SOURCE.
 * @param idx PA internal control index.
 * @param active Active port's name.
 */
void backend_port_set(context_t*, backend_entry_type, uint32_t, const char*);

typedef void (*tcallback_add_func)(void*, const char*, backend_entry_type, uint32_t, const backend_data_t*);
typedef void (*tcallback_update_func)(void*, backend_entry_type, uint32_t, backend_data_t*);
typedef void (*tcallback_remove_func)(void*, uint32_t, backend_entry_type);
typedef void (*tstate_callback_func)(void*);

typedef struct CLIENT_CALLBACK {
    callback_t *callback;
    backend_channel_t *channels;
    backend_volume_t *volumes;
    uint8_t chnum;
    uint32_t index;
} client_callback_t;

typedef struct VOLUME_CALLBACK {
    int index;
    int value;
} volume_callback_t;


/**
 * Internal macro.
 * Generates internal device adding/updating functions.
 * Generated function documentation follows.
 *
 * Callback. Fired after getting info about new or updated `type` device.
 *
 * @param c PA context. It is NOT our backend CONTEXT.
 * @param info `type` info.
 * @param eol Stop indicator.
 * @param userdata Additional data of type CALLBACK.
 *
 * @see _cb1()
 * @see _cb_u()
 */
#define _CB_DEVICE(func, info_type, _cb_func, type)\
    void func(pa_context *c, const info_type *info, int eol, void *userdata) {\
        if(!eol) {\
            uint32_t n = info->n_ports;\
            backend_option_t *optdata = NULL;\
            if(n > 0) {\
                optdata = (backend_option_t*)malloc(sizeof(backend_option_t));\
                optdata->descriptions = (char**)malloc(n * sizeof(char*));\
                optdata->names = (char**)malloc(n * sizeof(char*));\
                for(uint32_t i = 0; i < n; ++i) {\
                    const char *desc = info->ports[i]->description;\
                    optdata->descriptions[i] = (char*)malloc((strlen(desc) + 1) * sizeof(char));\
                    strcpy(optdata->descriptions[i], desc);\
                    const char *name = info->ports[i]->name;\
                    optdata->names[i] = (char*)malloc((strlen(name) + 1) * sizeof(char));\
                    strcpy(optdata->names[i], name);\
                }\
                const char *active_opt = info->active_port->description;\
                optdata->active = (char*)malloc((strlen(active_opt) + 1) * sizeof(char));\
                strcpy(optdata->active, active_opt);\
                optdata->size = n;\
            }\
            _cb_func(info->index, type, info->volume, info->mute, info->description, info->name, optdata, userdata);\
            _do_option_free(optdata, n);\
        }\
    }\

/**
 * Internal macro.
 * Generates internal stream adding/updating functions.
 * Generated function documentation follows.
 *
 * Callback. Fired after getting info about new or updated `type` stream.
 * For new streams, it creates necessary structures and fires _cb_client.
 * For updated streams, it just calls _cb_u().
 *
 * @param c PA context. It is NOT our backend CONTEXT.
 * @param info `type` info.
 * @param eol Stop indicator.
 * @param userdata Additional data of type CALLBACK.
 *
 * @see _cb_u()
 */
#define _CB_STREAM_(c, info, type, userdata)\
    if(info->index != PA_INVALID_INDEX) {\
        /* TODO: We'll need this name once status line is done. */\
        if(info->client != PA_INVALID_INDEX) {\
            callback_t *callback = (callback_t*)userdata;\
            uint8_t chnum = info->volume.channels;\
            backend_channel_t *channels = _do_channels(info->volume, chnum);\
            backend_volume_t *volumes = _do_volumes(info->volume, chnum, info->mute);\
            client_callback_t *client_cb = (client_callback_t*)malloc(sizeof(client_callback_t));\
            client_cb->callback = callback;\
            client_cb->channels = channels;\
            client_cb->volumes = volumes;\
            client_cb->chnum = chnum;\
            client_cb->index = info->index;\
            pa_context_get_client_info(c, info->client, _cb_client, client_cb);\
        }\
    }
#define _CB_STREAM_U(c, info, type, userdata)\
    _cb_u(info->index, type, info->volume, info->mute, NULL, NULL, NULL, userdata);
#define _CB_STREAM(func, info_type, _cb_func, type)\
    void func(pa_context *c, const info_type *info, int eol, void *userdata) {\
        if(!eol) {\
            _cb_func(c, info, type, userdata);\
        }\
    }\

/**
 * Internal macro.
 * Generates internal volume setting functions.
 * Generated function documentation follows.
 *
 * Callback. Fired after getting `type` info for setter.
 * Note: It frees userdata.
 *
 * @param c PA context. It is NOT our backend CONTEXT.
 * @param info `type` info.
 * @param eol Stop indicator.
 * @param userdata Additional data of type VOLUME_CALLBACK.
 *
 * @see backend_volume_set()
 */
#define _CB_SET_VOLUME(func, info_type, type, by_index)\
    void func(pa_context *c, const info_type *info, int eol, void *userdata) {\
        if(!eol) {\
            volume_callback_t *volume = (volume_callback_t*)userdata;\
            if(info->index != PA_INVALID_INDEX) {\
                pa_cvolume cvolume = info->volume;\
                cvolume.values[volume->index] = volume->value;\
                pa_context_set_ ## type ## _volume ## by_index(c, info->index, &cvolume, NULL, NULL);\
            }\
        }\
    }\

/**
 * Internal function.
 * Callback. Fired when PA server changes state.
 * Tests the state change and fires higher level state callback, if needed.
 *
 * @param c PA context. It is NOT our backend CONTEXT.
 * @param userdata Additional data of type STATE_CALLBACK.
 */
void _cb_state_changed(pa_context*, void*);

/**
 * Internal function.
 * Callback. Fired after getting client info.
 * Checks if everything went smoothly, then fires higher level add callback.
 * Also frees client data arrays on our side.
 *
 * @param c PA context. It is NOT our backend CONTEXT.
 * @param info INPUT/OUTPUT client info.
 * @param eol Stop indicator.
 * @param userdata Additional data of type CLIENT_CALLBACK.
 *
 * @see _cb2()
 */
void _cb_client(pa_context*, const pa_client_info*, int, void*);

/**
 * Internal function.
 * Callback. Fired after getting info about new SINK_INPUT.
 * Checks if we are done, makes up BACKEND_OPTION structure and calls _cb2().
 *
 * @param c PA context. It is NOT our backend CONTEXT.
 * @param info SINK_INPUT info.
 * @param eol Stop indicator.
 * @param userdata Additional data of type CALLBACK.
 *
 * @see _cb2()
 */
void _cb_sink_input(pa_context*, const pa_sink_input_info*, int, void*);

/**
 * Internal function.
 * Callback. Fired after getting update info about existing SINK_INPUT.
 * Merely checks if we are done with iteration and calls _cb_u().
 *
 * @param c PA context. It is NOT our backend CONTEXT.
 * @param info SINK_INPUT info.
 * @param eol Stop indicator.
 * @param userdata Additional data of type CALLBACK.
 *
 * @see _cb_u()
 */
void _cb_u_sink_input(pa_context*, const pa_sink_input_info*, int, void*);

/**
 * Internal function.
 * Callback. Fired after getting info about new SOURCE_OUTPUT.
 * Merely checks if we are done with iteration and calls _cb2().
 *
 * @param c PA context. It is NOT our backend CONTEXT.
 * @param info SOURCE_OUTPUT info.
 * @param eol Stop indicator.
 * @param userdata Additional data of type CALLBACK.
 *
 * @see _cb2()
 */
void _cb_source_output(pa_context*, const pa_source_output_info*, int, void*);

/**
 * Internal function.
 * Callback. Fired after getting update info about existing SOURCE_OUTPUT.
 * Merely checks if we are done with iteration and calls _cb_u().
 *
 * @param c PA context. It is NOT our backend CONTEXT.
 * @param info SOURCE_OUTPUT info.
 * @param eol Stop indicator.
 * @param userdata Additional data of type CALLBACK.
 *
 * @see _cb_u()
 */
void _cb_u_source_output(pa_context*, const pa_source_output_info*, int, void*);

/**
 * Internal function.
 * Callback. Fired after getting info about new CARD.
 *
 * @param c PA context. It is NOT our backend CONTEXT.
 * @param info CARD info.
 * @param eol Stop indicator.
 * @param userdata Additional data of type CALLBACK.
 */
void _cb_card(pa_context*, const pa_card_info*, int, void*);

/**
 * Internal function.
 * Callback. Fired after getting update info about existing CARD.
 *
 * @param c PA context. It is not our backend CONTEXT.
 * @param info CARD info.
 * @param eol Stop indicator.
 * @param userdata Additional data of type CALLBACK.
 */
void _cb_u_card(pa_context*, const pa_card_info*, int, void*);

/**
 * Internal function.
 * Callback. Fired after getting info about PA server settings updates.
 *
 * @param c PA context. It is not our backend CONTEXT.
 * @param info SERVER info.
 * @param userdata Additional data of type CALLBACK.
 */
void _cb_server(pa_context*, const pa_server_info*, void *userdata);


/**
 * Internal function.
 * Callback. Fired when PA server emits an event.
 * Checks event type and facility, then calls appropriate function:
 *  [*] Specific PA get function for NEW and CHANGE events
 *  [*] Higher level remove callback for REMOVE events.
 *
 * @param c PA context. It is NOT our backend CONTEXT.
 * @param t Event type mask.
 * @param idx PA internal control index.
 * @param userdata Additional data of type CALLBACK.
 */
void _cb_event(pa_context*, pa_subscription_event_type_t, uint32_t, void*);


/**
 * Helper function.
 * Creates BACKEND_CHANNEL used by higher level callbacks.
 *
 * @param volume PA volume representation array. Not used ATM.
 * @param chnum Number of items in @param volume.
 *
 * @return Array of BACKEND_CHANNEL.
 */
backend_channel_t *_do_channels(pa_cvolume, uint8_t);

/**
 * Helper function.
 * Creates BACKEND_VOLUME used by higher level callbacks
 * from low level PA representation.
 *
 * @param volume PA volume representation array.
 * @param chnum Number of items in @param volume.
 * @param mute Control's current mute value.
 *
 * @return Array of BACKEND_VOLUME.
 */
backend_volume_t *_do_volumes(pa_cvolume, uint8_t, int);

/**
 * Helper function.
 * Creates BACKEND_OPTION used by higher level callbacks
 * for low level PA representation.
 *
 * @param info Card info structure received from PA.
 * @param n Number of profiles.
 *
 * @return Array of BACKEND_OPTION.
 */
backend_option_t *_do_card(const pa_card_info*, int);

/**
 * Frees an array of BACKEND_OPTION.
 *
 * @param card Array of BACKEND_OPTION.
 * @param n Number of profiles.
 */
void _do_option_free(backend_option_t*, int n);


/**
 * Internal helper function.
 * Used to propagate info about control's current volume and mute values.
 * Makes up necessary information using BACKEND_VOLUME type
 * and calls higher level update callback.
 *
 * @param index PA internal control index.
 * @param type Type of the control.
 * @param volume Volume values.
 * @param mute Mute value.
 * @param description Human readable name of the control (IGNORED).
 * @param internalName Internal name of the control (IGNORED).
 * @param optdata Options data. Can be NULL.
 * @param userdata Additional data of type CALLBACK.
 *
 * @see _do_volumes()
 */
void _cb_u(uint32_t, backend_entry_type, pa_cvolume, int, const char*, const char*, backend_option_t*, void*);

/**
 * Internal helper function.
 * Used to propagate info about newly appearing SINKs and SOURCEs.
 * Makes up necessary information using BACKEND_CHANNEL type
 * and calls higher level add callback.
 *
 * @param index PA internal control index.
 * @param type Type of the control.
 * @param volume Volume values.
 * @param mute Mute value.
 * @param description Human readable name of the control.
 * @param internalName Internal name of the control.
 * @param options Options data (BACKEND_OPTION).
 * @param userdata Additional data of type CALLBACK.
 *
 * @see _do_channels()
 * @see _do_volumes()
 */
void _cb1(uint32_t, backend_entry_type, pa_cvolume, int, const char*, const char*, backend_option_t*, void*);
