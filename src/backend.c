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


#include "backend.h"


context_t *backend_new(state_callback_t *state_callback) {
    context_t *context = (context_t*)malloc(sizeof(context_t));
    context->loop = pa_threaded_mainloop_new();
    context->state = PA_CONTEXT_UNCONNECTED;
    pa_mainloop_api *api = pa_threaded_mainloop_get_api(context->loop);
    context->context = pa_context_new(api, "pacmixer");
    int r = pa_context_connect(context->context, NULL, 0, NULL);
    struct timespec t, rt;
    t.tv_sec = 0;
    t.tv_nsec = 100000000;
    while(r == -1) {
        nanosleep(&t, &rt);
        pa_context_unref(context->context);
        context->context = pa_context_new(api, "pacmixer");
        r = pa_context_connect(context->context, NULL, 0, NULL);
    }
    state_callback->state = &context->state;
    pa_context_set_state_callback(context->context, _cb_state_changed, state_callback);
    return context;
}

void backend_init(context_t *context, callback_t *callback) {
    pa_threaded_mainloop_start(context->loop);
    struct timespec t, rt;
    t.tv_sec = 0;
    t.tv_nsec = 10000000;
    while(
        context->state != PA_CONTEXT_READY ||
        context->state == PA_CONTEXT_FAILED ||
        context->state == PA_CONTEXT_TERMINATED
    ) {
        nanosleep(&t, &rt);
    }
    pa_context_set_subscribe_callback(context->context, _cb_event, callback);
    pa_context_subscribe(context->context, PA_SUBSCRIPTION_MASK_ALL, NULL, NULL);
    pa_context_get_sink_input_info_list(context->context, _cb_sink_input, callback);
    pa_context_get_sink_info_list(context->context, _cb_sink, callback);
    pa_context_get_source_info_list(context->context, _cb_source, callback);
    pa_context_get_source_output_info_list(context->context, _cb_source_output, callback);
    pa_context_get_card_info_list(context->context, _cb_card, callback);
    pa_context_get_server_info(context->context, _cb_server, callback);
}

void backend_destroy(context_t *context) {
    pa_threaded_mainloop_stop(context->loop);
    pa_context_disconnect(context->context);
    pa_context_unref(context->context);
    pa_threaded_mainloop_free(context->loop);
    free(context);
}

void backend_volume_set(context_t *c, backend_entry_type type, uint32_t idx, int i, int v) {
    volume_callback_t volume;
    volume.index = i;
    volume.value = v;
    switch(type) {
        case SINK:
            pa_context_get_sink_info_by_index(c->context, idx, _cb_s_sink, &volume);
            break;
        case SINK_INPUT:
            pa_context_get_sink_input_info(c->context, idx, _cb_s_sink_input, &volume);
            break;
        case SOURCE:
            pa_context_get_source_info_by_index(c->context, idx, _cb_s_source, &volume);
            break;
        case SOURCE_OUTPUT:
            pa_context_get_source_output_info(c->context, idx, _cb_s_source_output, &volume);
            break;
        default:
            break;
    }
}

void backend_volume_setall(context_t *c, backend_entry_type type, uint32_t idx, int *v, int chnum) {
    pa_cvolume volume;
    volume.channels = chnum;
    for(int i = 0; i < chnum; ++i) {
        volume.values[i] = v[i];
    }
    switch(type) {
        case SINK:
            pa_context_set_sink_volume_by_index(c->context, idx, &volume, NULL, NULL);
            break;
        case SINK_INPUT:
            pa_context_set_sink_input_volume(c->context, idx, &volume, NULL, NULL);
            break;
        case SOURCE:
            pa_context_set_source_volume_by_index(c->context, idx, &volume, NULL, NULL);
            break;
        case SOURCE_OUTPUT:
            pa_context_set_source_output_volume(c->context, idx, &volume, NULL, NULL);
            break;
        default:
            break;
    }
}

void backend_mute_set(context_t *c, backend_entry_type type, uint32_t idx, int v) {
    switch(type) {
        case SINK:
            pa_context_set_sink_mute_by_index(c->context, idx, v, NULL, NULL);
            break;
        case SINK_INPUT:
            pa_context_set_sink_input_mute(c->context, idx, v, NULL, NULL);
            break;
        case SOURCE:
            pa_context_set_source_mute_by_index(c->context, idx, v, NULL, NULL);
            break;
        case SOURCE_OUTPUT:
            pa_context_set_source_output_mute(c->context, idx, v, NULL, NULL);
            break;
        default:
            break;
    }
}

void backend_card_profile_set(context_t *c, backend_entry_type type, uint32_t idx, const char *active) {
    pa_context_set_card_profile_by_index(c->context, idx, active, NULL, NULL);
}

void backend_default_set(context_t *c, backend_entry_type type, const char *internalName) {
    switch(type) {
        case SINK:
            pa_context_set_default_sink(c->context, internalName, NULL, NULL);
            break;
        case SOURCE:
            pa_context_set_default_source(c->context, internalName, NULL, NULL);
            break;
        default:
            break;
    }
}

void backend_port_set(context_t *c, backend_entry_type type, uint32_t idx, const char *active) {
    switch(type) {
        case SINK:
            pa_context_set_sink_port_by_index(c->context, idx, active, NULL, NULL);
            break;
        case SOURCE:
            pa_context_set_source_port_by_index(c->context, idx, active, NULL, NULL);
            break;
        default:
            break;
    }
}

void _cb_state_changed(pa_context *c, void *userdata) {
    state_callback_t *state_callback = (state_callback_t*)userdata;
    pa_context_state_t nstate = pa_context_get_state(c);
    *state_callback->state = nstate;
    if(nstate == PA_CONTEXT_FAILED || nstate == PA_CONTEXT_TERMINATED) {
        ((tstate_callback_func)(state_callback->func))(state_callback->self);
    }
}

void _cb_client(pa_context *c, const pa_client_info *info, int eol, void *userdata) {
    if(!eol && info->index != PA_INVALID_INDEX) {
        client_callback_t *client_callback = (client_callback_t*)userdata;
        callback_t *callback = client_callback->callback;
#ifdef DEBUG
debug_fprintf(__func__, "%d:%s appeared", client_callback->index, info->name);
#endif
        backend_data_t data;
        data.channels = client_callback->channels;
        data.volumes = client_callback->volumes;
        data.channels_num = client_callback->chnum;
        data.option = NULL;
        ((tcallback_add_func)(callback->add))(callback->self, info->name, SINK_INPUT, client_callback->index, &data);
        free(client_callback->channels);
        free(client_callback->volumes);
        free(client_callback);
    }
}

#define _CB_DO_OPTION(_cb_func, type)\
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

#define _CB_SET_VOLUME(type, by_index)\
    if(!eol) {\
        volume_callback_t *volume = (volume_callback_t*)userdata;\
        if(info->index != PA_INVALID_INDEX) {\
            pa_cvolume cvolume = info->volume;\
            cvolume.values[volume->index] = volume->value;\
            pa_context_set_ ## type ## _volume ## by_index(c, info->index, &cvolume, NULL, NULL);\
        }\
    }\

void _cb_sink(pa_context *c, const pa_sink_info *info, int eol, void *userdata) {
    _CB_DO_OPTION(_cb1, SINK);
}

void _cb_u_sink(pa_context *c, const pa_sink_info *info, int eol, void *userdata) {
    _CB_DO_OPTION(_cb_u, SINK);
}

void _cb_s_sink(pa_context *c, const pa_sink_info *info, int eol, void *userdata) {
    _CB_SET_VOLUME(sink, _by_index);
}

void _cb_sink_input(pa_context *c, const pa_sink_input_info *info, int eol, void *userdata) {
    if(!eol) {
        _cb2(c, info->index, info->volume, info->mute, info->name, SINK_INPUT, info->client, userdata);
    }
}

void _cb_u_sink_input(pa_context *c, const pa_sink_input_info *info, int eol, void *userdata) {
    if(!eol) {
        _cb_u(info->index, SINK_INPUT, info->volume, info->mute, NULL, NULL, NULL, userdata);
    }
}

void _cb_s_sink_input(pa_context *c, const pa_sink_input_info *info, int eol, void *userdata) {
    _CB_SET_VOLUME(sink_input, );
}

void _cb_source(pa_context *c, const pa_source_info *info, int eol, void *userdata) {
    _CB_DO_OPTION(_cb1, SOURCE);
}

void _cb_u_source(pa_context *c, const pa_source_info *info, int eol, void *userdata) {
    _CB_DO_OPTION(_cb_u, SOURCE);
}

void _cb_s_source(pa_context *c, const pa_source_info *info, int eol, void *userdata) {
    _CB_SET_VOLUME(source, _by_index);
}

void _cb_source_output(pa_context *c, const pa_source_output_info *info, int eol, void *userdata) {
    if(!eol) {
        _cb2(c, info->index, info->volume, info->mute, info->name, SOURCE_OUTPUT, info->client, userdata);
    }
}

void _cb_u_source_output(pa_context *c, const pa_source_output_info *info, int eol, void *userdata) {
    if(!eol) {
        _cb_u(info->index, SOURCE_OUTPUT, info->volume, info->mute, NULL, NULL, NULL, userdata);
    }
}

void _cb_s_source_output(pa_context *c, const pa_source_output_info *info, int eol, void *userdata) {
    _CB_SET_VOLUME(source_output, );
}

void _cb_card(pa_context *c, const pa_card_info *info, int eol, void *userdata) {
    if(!eol && info->index != PA_INVALID_INDEX) {
        callback_t *callback = (callback_t*)userdata;
        int n = info->n_profiles;
        backend_data_t data;
        if(n > 0) {
            data.option = _do_card(info, n);
        } else {
            data.option = NULL;
        }
        const char *desc = pa_proplist_gets(info->proplist, PA_PROP_DEVICE_DESCRIPTION);
        ((tcallback_add_func)(callback->add))(callback->self, desc, CARD, info->index, &data);
        if(n > 0) {
            _do_option_free(data.option, n);
        }
    }
}

void _cb_u_card(pa_context *c, const pa_card_info *info, int eol, void *userdata) {
    if(!eol && info->index != PA_INVALID_INDEX) {
        callback_t *callback = (callback_t*)userdata;
        int n = info->n_profiles;
        backend_data_t data;
        if(n > 0) {
            data.option = _do_card(info, n);
        } else {
            data.option = NULL;
        }
        ((tcallback_update_func)(callback->update))(callback->self, CARD, info->index, &data);
        if(n > 0) {
            _do_option_free(data.option, n);
        }
    }
}

void _cb_server(pa_context *c, const pa_server_info *info, void *userdata) {
    callback_t *callback = (callback_t*)userdata;

    backend_data_t data;
    data.defaults = (backend_default_t*)malloc(sizeof(backend_default_t));

    const char *sink_name = info->default_sink_name;
    data.defaults->sink = (char*)malloc((strlen(sink_name) + 1) * sizeof(char));
    strcpy(data.defaults->sink, sink_name);

    const char *source_name = info->default_source_name;
    data.defaults->source = (char*)malloc((strlen(source_name) + 1) * sizeof(char));
    strcpy(data.defaults->source, source_name);

    ((tcallback_update_func)(callback->update))(callback->self, SERVER, 0, &data);

    free(data.defaults->source);
    free(data.defaults->sink);
    free(data.defaults);
}

#define _CB_SINGLE_EVENT(event, type, by_index)\
    if(t__ == PA_SUBSCRIPTION_EVENT_ ## event) {\
        if(t_ == PA_SUBSCRIPTION_EVENT_CHANGE && idx != PA_INVALID_INDEX) {\
            pa_context_get_ ## type ## _info ## by_index(c, idx, _cb_u_ ## type, userdata);\
        }\
        if(t_ == PA_SUBSCRIPTION_EVENT_REMOVE && idx != PA_INVALID_INDEX) {\
            callback_t *callback = (callback_t*)userdata;\
            ((tcallback_remove_func)(callback->remove))(callback->self, idx, event);\
        }\
        if(t_ == PA_SUBSCRIPTION_EVENT_NEW && idx != PA_INVALID_INDEX) {\
            pa_context_get_ ## type ## _info ## by_index(c, idx, _cb_ ## type, userdata);\
        }\
    }\

void _cb_event(pa_context *c, pa_subscription_event_type_t t, uint32_t idx, void *userdata) {
    int t_ = t & PA_SUBSCRIPTION_EVENT_TYPE_MASK;
    int t__ = t & PA_SUBSCRIPTION_EVENT_FACILITY_MASK;
    _CB_SINGLE_EVENT(CARD, card, _by_index);
    _CB_SINGLE_EVENT(SINK, sink, _by_index);
    _CB_SINGLE_EVENT(SINK_INPUT, sink_input, );
    _CB_SINGLE_EVENT(SOURCE, source, _by_index);
    _CB_SINGLE_EVENT(SOURCE_OUTPUT, source_output, );
    if(t__ == PA_SUBSCRIPTION_EVENT_SERVER) {
        pa_context_get_server_info(c, _cb_server, userdata);
    }
}

backend_channel_t *_do_channels(pa_cvolume volume, uint8_t chnum) {
    backend_channel_t *channels = (backend_channel_t*)malloc(chnum * sizeof(backend_channel_t));
    for(int i = 0; i < chnum; ++i) {
        channels[i].maxLevel = PA_VOLUME_UI_MAX;
        channels[i].normLevel = PA_VOLUME_NORM;
        channels[i].isMutable = 1;
    }
    return channels;
}

backend_volume_t *_do_volumes(pa_cvolume volume, uint8_t chnum, int mute) {
    backend_volume_t *volumes = (backend_volume_t*)malloc(chnum * sizeof(backend_volume_t));
    for(int i = 0; i < chnum; ++i) {
        volumes[i].level = volume.values[i];
        volumes[i].mute = mute;
    }
    return volumes;
}

backend_option_t *_do_card(const pa_card_info *info, int n) {
    backend_option_t *card = (backend_option_t*)malloc(sizeof(backend_option_t));
    pa_card_profile_info *profiles = info->profiles;
    card->descriptions = (char**)malloc(n * sizeof(char*));
    card->names = (char**)malloc(n * sizeof(char*));
    for(int i = 0; i < n; ++i) {
        const char *desc = profiles[i].description;
        card->descriptions[i] = (char*)malloc((strlen(desc) + 1) * sizeof(char));
        strcpy(card->descriptions[i], desc);
        const char *name = profiles[i].name;
        card->names[i] = (char*)malloc((strlen(name) + 1) * sizeof(char));
        strcpy(card->names[i], name);
    }
    const char *active = info->active_profile->description;
    card->active = (char*)malloc((strlen(active) + 1) * sizeof(char));
    strcpy(card->active, active);
    card->size = n;
    return card;
}

void _do_option_free(backend_option_t *option, int n) {
    if(option == NULL) {
        return;
    }
    free(option->active);
    for(int i = 0; i < n; ++i) {
        free(option->descriptions[i]);
        free(option->names[i]);
    }
    free(option->descriptions);
    free(option->names);
    free(option);
}

void _cb_u(uint32_t index, backend_entry_type type, pa_cvolume volume, int mute, const char *description, const char *internalName, backend_option_t *optdata, void *userdata) {
    if(index != PA_INVALID_INDEX) {
        callback_t *callback = (callback_t*)userdata;
        uint8_t chnum = volume.channels;
        backend_data_t data;
        data.volumes = _do_volumes(volume, chnum, mute);
        data.channels_num = chnum;
        data.option = optdata;
        ((tcallback_update_func)(callback->update))(callback->self, type, index, &data);
        free(data.volumes);
    }
}

void _cb1(uint32_t index, backend_entry_type type, pa_cvolume volume, int mute, const char *description, const char *internalName, backend_option_t *options, void *userdata) {
    if(index != PA_INVALID_INDEX) {
#ifdef DEBUG
debug_fprintf(__func__, "%d:%s appeared", index, description);
#endif
        callback_t *callback = (callback_t*)userdata;
        uint8_t chnum = volume.channels;
        backend_data_t data;
        data.channels = _do_channels(volume, chnum);
        data.volumes = _do_volumes(volume, chnum, mute);
        data.channels_num = chnum;
        data.option = options;
        data.internalName = (char*)malloc((strlen(internalName) + 1) * sizeof(char));
        strcpy(data.internalName, internalName);
        ((tcallback_add_func)(callback->add))(callback->self, description, type, index, &data);
        free(data.channels);
        free(data.volumes);
    }
}

void _cb2(pa_context *c, uint32_t index, pa_cvolume volume, int mute, const char *name, backend_entry_type type, uint32_t client, void *userdata) {
    if(index != PA_INVALID_INDEX) {
        /* TODO: We'll need this name once status line is done. */
        if(client != PA_INVALID_INDEX) {
            callback_t *callback = (callback_t*)userdata;
            uint8_t chnum = volume.channels;
            backend_channel_t *channels = _do_channels(volume, chnum);
            backend_volume_t *volumes = _do_volumes(volume, chnum, mute);
            client_callback_t *client_callback = (client_callback_t*)malloc(sizeof(client_callback_t));
            client_callback->callback = callback;
            client_callback->channels = channels;
            client_callback->volumes = volumes;
            client_callback->chnum = chnum;
            client_callback->index = index;
            pa_context_get_client_info(c, client, _cb_client, client_callback);
        }
    }
}
