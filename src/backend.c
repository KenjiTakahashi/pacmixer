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
    context_t *context = malloc(sizeof(context_t));
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
}

void backend_destroy(context_t *context) {
    pa_threaded_mainloop_stop(context->loop);
    pa_context_disconnect(context->context);
    pa_context_unref(context->context);
    pa_threaded_mainloop_free(context->loop);
    free(context);
}

void backend_volume_set(context_t *c, backend_entry_type type, uint32_t idx, int i, int v) {
    volume_callback_t *volume = malloc(sizeof(volume_callback_t));
    volume->index = i;
    volume->value = v;
    switch(type) {
        case SINK:
            pa_context_get_sink_info_by_index(c->context, idx, _cb_s_sink, volume);
            break;
        case SINK_INPUT:
            pa_context_get_sink_input_info(c->context, idx, _cb_s_sink_input, volume);
            break;
        case SOURCE:
            pa_context_get_source_info_by_index(c->context, idx, _cb_s_source, volume);
            break;
        case SOURCE_OUTPUT:
            pa_context_get_source_output_info(c->context, idx, _cb_s_source_output, volume);
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

void _cb_state_changed(pa_context *c, void *userdata) {
    state_callback_t *state_callback = userdata;
    pa_context_state_t nstate = pa_context_get_state(c);
    *state_callback->state = nstate;
    if(nstate == PA_CONTEXT_FAILED || nstate == PA_CONTEXT_TERMINATED) {
        ((tstate_callback_func)(state_callback->func))(state_callback->self);
    }
}

void _cb_client(pa_context *c, const pa_client_info *info, int eol, void *userdata) {
    if(!eol && info->index != PA_INVALID_INDEX) {
        client_callback_t *client_callback = userdata;
        callback_t *callback = client_callback->callback;
#ifdef DEBUG
debug_fprintf(__func__, "%d:%s appeared", client_callback->index, info->name);
#endif
        ((tcallback_add_func)(callback->add))(callback->self, info->name, SINK_INPUT, client_callback->index, client_callback->channels, client_callback->volumes, NULL, client_callback->chnum);
        free(client_callback->channels);
        free(client_callback->volumes);
        free(client_callback);
    }
}

void _cb_sink(pa_context *c, const pa_sink_info *info, int eol, void *userdata) {
    if(!eol) {
        _cb1(info->index, info->volume, info->mute, info->description, SINK, userdata);
    }
}

void _cb_u_sink(pa_context *c, const pa_sink_info *info, int eol, void *userdata) {
    if(!eol) {
        _cb_u(info->index, SINK, info->volume, info->mute, userdata);
    }
}

void _cb_s_sink(pa_context *c, const pa_sink_info *info, int eol, void *userdata) {
    if(!eol) {
        volume_callback_t *volume = userdata;
        if(info->index != PA_INVALID_INDEX) {
            pa_cvolume cvolume = info->volume;
            cvolume.values[volume->index] = volume->value;
            pa_context_set_sink_volume_by_index(c, info->index, &cvolume, NULL, NULL);
        }
        free(volume);
    }
}

void _cb_sink_input(pa_context *c, const pa_sink_input_info *info, int eol, void *userdata) {
    if(!eol) {
        _cb2(c, info->index, info->volume, info->mute, info->name, SINK_INPUT, info->client, userdata);
    }
}

void _cb_u_sink_input(pa_context *c, const pa_sink_input_info *info, int eol, void *userdata) {
    if(!eol) {
        _cb_u(info->index, SINK_INPUT, info->volume, info->mute, userdata);
    }
}

void _cb_s_sink_input(pa_context *c, const pa_sink_input_info *info, int eol, void *userdata) {
    if(!eol) {
        volume_callback_t *volume = userdata;
        if(info->index != PA_INVALID_INDEX) {
            pa_cvolume cvolume = info->volume;
            cvolume.values[volume->index] = volume->value;
            pa_context_set_sink_input_volume(c, info->index, &cvolume, NULL, NULL);
        }
        free(volume);
    }
}

void _cb_source(pa_context *c, const pa_source_info *info, int eol, void *userdata) {
    if(!eol) {
        _cb1(info->index, info->volume, info->mute, info->description, SOURCE, userdata);
    }
}

void _cb_u_source(pa_context *c, const pa_source_info *info, int eol, void *userdata) {
    if(!eol) {
        _cb_u(info->index, SOURCE, info->volume, info->mute, userdata);
    }
}

void _cb_s_source(pa_context *c, const pa_source_info *info, int eol, void *userdata) {
    if(!eol) {
        volume_callback_t *volume = userdata;
        if(info->index != PA_INVALID_INDEX) {
            pa_cvolume cvolume = info->volume;
            cvolume.values[volume->index] = volume->value;
            pa_context_set_source_volume_by_index(c, info->index, &cvolume, NULL, NULL);
        }
        free(volume);
    }
}

void _cb_source_output(pa_context *c, const pa_source_output_info *info, int eol, void *userdata) {
    if(!eol) {
        _cb2(c, info->index, info->volume, info->mute, info->name, SOURCE_OUTPUT, info->client, userdata);
    }
}

void _cb_u_source_output(pa_context *c, const pa_source_output_info *info, int eol, void *userdata) {
    if(!eol) {
        _cb_u(info->index, SOURCE_OUTPUT, info->volume, info->mute, userdata);
    }
}

void _cb_s_source_output(pa_context *c, const pa_source_output_info *info, int eol, void *userdata) {
    if(!eol) {
        volume_callback_t *volume = userdata;
        if(info->index != PA_INVALID_INDEX) {
            pa_cvolume cvolume = info->volume;
            cvolume.values[volume->index] = volume->value;
            pa_context_set_source_output_volume(c, info->index, &cvolume, NULL, NULL);
        }
        free(volume);
    }
}

void _cb_card(pa_context *c, const pa_card_info *info, int eol, void *userdata) {
    if(!eol && info->index != PA_INVALID_INDEX) {
        callback_t *callback = userdata;
        int n = info->n_profiles;
        backend_card_t *card = _do_card(info, n);
        const char *desc = pa_proplist_gets(info->proplist, PA_PROP_DEVICE_DESCRIPTION);
        ((tcallback_add_func)(callback->add))(callback->self, desc, CARD, info->index, NULL, NULL, card, n);
        _do_card_free(card, n);
    }
}

void _cb_u_card(pa_context *c, const pa_card_info *info, int eol, void *userdata) {
    if(!eol && info->index != PA_INVALID_INDEX) {
        callback_t *callback = userdata;
        int n = info->n_profiles;
        backend_card_t *card = _do_card(info, n);
        ((tcallback_update_func)(callback->update))(callback->self, CARD, info->index, NULL, card, n);
         _do_card_free(card, n);
    }
}

void _cb_event(pa_context *c, pa_subscription_event_type_t t, uint32_t idx, void *userdata) {
    int t_ = t & PA_SUBSCRIPTION_EVENT_TYPE_MASK;
    int t__ = t & PA_SUBSCRIPTION_EVENT_FACILITY_MASK;
    if(t__ == PA_SUBSCRIPTION_EVENT_CARD) {
        if(t_ == PA_SUBSCRIPTION_EVENT_CHANGE && idx != PA_INVALID_INDEX) {
            pa_context_get_card_info_by_index(c, idx, _cb_u_card, userdata);
        }
        if(t_ == PA_SUBSCRIPTION_EVENT_REMOVE && idx != PA_INVALID_INDEX) {
            callback_t *callback = userdata;
            ((tcallback_remove_func)(callback->remove))(callback->self, idx);
        }
        if(t_ == PA_SUBSCRIPTION_EVENT_NEW && idx != PA_INVALID_INDEX) {
            pa_context_get_card_info_by_index(c, idx, _cb_card, userdata);
        }
    }
    if(t__ == PA_SUBSCRIPTION_EVENT_SINK_INPUT) {
        if(t_ == PA_SUBSCRIPTION_EVENT_CHANGE && idx != PA_INVALID_INDEX) {
            pa_context_get_sink_input_info(c, idx, _cb_u_sink_input, userdata);
        }
        if(t_ == PA_SUBSCRIPTION_EVENT_REMOVE && idx != PA_INVALID_INDEX) {
            callback_t *callback = userdata;
            ((tcallback_remove_func)(callback->remove))(callback->self, idx);
        }
        if(t_ == PA_SUBSCRIPTION_EVENT_NEW && idx != PA_INVALID_INDEX) {
            pa_context_get_sink_input_info(c, idx, _cb_sink_input, userdata);
        }
    }
    if(t__ == PA_SUBSCRIPTION_EVENT_SINK) {
        if(t_ == PA_SUBSCRIPTION_EVENT_CHANGE && idx != PA_INVALID_INDEX) {
            pa_context_get_sink_info_by_index(c, idx, _cb_u_sink, userdata);
        }
        if(t_ == PA_SUBSCRIPTION_EVENT_REMOVE && idx != PA_INVALID_INDEX) {
            callback_t *callback = userdata;
            ((tcallback_remove_func)(callback->remove))(callback->self, idx);
        }
        if(t_ == PA_SUBSCRIPTION_EVENT_NEW && idx != PA_INVALID_INDEX) {
            pa_context_get_sink_info_by_index(c, idx, _cb_sink, userdata);
        }
    }
    if(t__ == PA_SUBSCRIPTION_EVENT_SOURCE) {
        if(t_ == PA_SUBSCRIPTION_EVENT_CHANGE && idx != PA_INVALID_INDEX) {
            pa_context_get_source_info_by_index(c, idx, _cb_u_source, userdata);
        }
        if(t_ == PA_SUBSCRIPTION_EVENT_REMOVE && idx != PA_INVALID_INDEX) {
            callback_t *callback = userdata;
            ((tcallback_remove_func)(callback->remove))(callback->self, idx);
        }
        if(t_ == PA_SUBSCRIPTION_EVENT_NEW && idx != PA_INVALID_INDEX) {
            pa_context_get_source_info_by_index(c, idx, _cb_source, userdata);
        }
    }
    if(t__ == PA_SUBSCRIPTION_EVENT_SOURCE_OUTPUT) {
        if(t_ == PA_SUBSCRIPTION_EVENT_CHANGE && idx != PA_INVALID_INDEX) {
            pa_context_get_source_output_info(c, idx, _cb_u_source_output, userdata);
        }
        if(t_ == PA_SUBSCRIPTION_EVENT_REMOVE && idx != PA_INVALID_INDEX) {
            callback_t *callback = userdata;
            ((tcallback_remove_func)(callback->remove))(callback->self, idx);
        }
        if(t_ == PA_SUBSCRIPTION_EVENT_NEW && idx != PA_INVALID_INDEX) {
            pa_context_get_source_output_info(c, idx, _cb_source_output, userdata);
        }
    }
}

backend_channel_t *_do_channels(pa_cvolume volume, uint8_t chnum) {
    backend_channel_t *channels = malloc(chnum * sizeof(backend_channel_t));
    for(int i = 0; i < chnum; ++i) {
        channels[i].maxLevel = PA_VOLUME_UI_MAX;
        channels[i].normLevel = PA_VOLUME_NORM;
        channels[i].mutable = 1;
    }
    return channels;
}

backend_volume_t *_do_volumes(pa_cvolume volume, uint8_t chnum, int mute) {
    backend_volume_t *volumes = malloc(chnum * sizeof(backend_volume_t));
    for(int i = 0; i < chnum; ++i) {
        volumes[i].level = volume.values[i];
        volumes[i].mute = mute;
    }
    return volumes;
}

backend_card_t *_do_card(const pa_card_info* info, int n) {
    backend_card_t *card = malloc(sizeof(backend_card_t));
    pa_card_profile_info *profiles = info->profiles;
    card->profiles = malloc(n * sizeof(char*));
    for(int i = 0; i < n; ++i) {
        const char *desc = profiles[i].description;
        card->profiles[i] = malloc((strlen(desc) + 1) * sizeof(char));
        strcpy(card->profiles[i], desc);
    }
    const char *active = info->active_profile[0].description;
    card->active_profile = malloc((strlen(active) + 1) * sizeof(char));
    strcpy(card->active_profile, active);
    return card;
}

void _do_card_free(backend_card_t *card, int n) {
    free(card->active_profile);
    for(int i = 0; i < n; ++i) {
        free(card->profiles[i]);
    }
    free(card->profiles);
    free(card);
}

void _cb_u(uint32_t index, backend_entry_type type, pa_cvolume volume, int mute, void *userdata) {
    if(index != PA_INVALID_INDEX) {
        callback_t *callback = userdata;
        uint8_t chnum = volume.channels;
        backend_volume_t *volumes = _do_volumes(volume, chnum, mute);
        ((tcallback_update_func)(callback->update))(callback->self, type, index, volumes, NULL, chnum);
        free(volumes);
    }
}

void _cb1(uint32_t index, pa_cvolume volume, int mute, const char *description, backend_entry_type type, void *userdata) {
    if(index != PA_INVALID_INDEX) {
        callback_t *callback = userdata;
        uint8_t chnum = volume.channels;
        backend_channel_t *channels = _do_channels(volume, chnum);
#ifdef DEBUG
debug_fprintf(__func__, "%d:%s appeared", index, description);
#endif
        backend_volume_t *volumes = _do_volumes(volume, chnum, mute);
        ((tcallback_add_func)(callback->add))(callback->self, description, type, index, channels, volumes, NULL, chnum);
        free(channels);
        free(volumes);
    }
}

void _cb2(pa_context *c, uint32_t index, pa_cvolume volume, int mute, const char *name, backend_entry_type type, uint32_t client, void *userdata) {
    if(index != PA_INVALID_INDEX) {
        /* TODO: We'll need this name once status line is done. */
        if(client != PA_INVALID_INDEX) {
            callback_t *callback = userdata;
            uint8_t chnum = volume.channels;
            backend_channel_t *channels = _do_channels(volume, chnum);
            backend_volume_t *volumes = _do_volumes(volume, chnum, mute);
            client_callback_t *client_callback = malloc(sizeof(client_callback_t));
            client_callback->callback = callback;
            client_callback->channels = channels;
            client_callback->volumes = volumes;
            client_callback->chnum = chnum;
            client_callback->index = index;
            pa_context_get_client_info(c, client, _cb_client, client_callback);
        }
    }
}
