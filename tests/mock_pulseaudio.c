/*
 This is a part of pacmixer @ http://github.com/KenjiTakahashi/pacmixer
 Karol "Kenji Takahashi" Woźniak © 2013

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


#include "mock_pulseaudio.h"


pa_threaded_mainloop *pa_threaded_mainloop_new() {
    return &s_instance;
}

pa_mainloop_api *pa_threaded_mainloop_get_api(pa_threaded_mainloop *loop) {
    return &s_api;
}

pa_context *pa_context_new(pa_mainloop_api *api, const char *name) {
    return &s_context;
}

int pa_context_connect(pa_context *context, void *s, int n, void *m) {
    return s_instance;
}

void pa_context_unref(pa_context *context) {}

void pa_context_set_state_callback(pa_context *context, void *s, void *m) {}

void pa_threaded_mainloop_start(pa_threaded_mainloop *loop) {}

void pa_context_set_subscribe_callback(pa_context *context, void *s, void *m) {}

void pa_context_subscribe(pa_context *context, int mask, void *s, void *m) {}

void pa_context_get_sink_input_info_list(pa_context *context, void *s, void *m) {}

void pa_context_get_source_output_info_list(pa_context *context, void *s, void *m) {}

void pa_context_get_sink_info_list(pa_context *context, void *s, void *m) {}

void pa_context_get_source_info_list(pa_context *context, void *s, void *m) {}

void pa_context_get_card_info_list(pa_context *context, void *s, void *m) {}

void pa_threaded_mainloop_stop(pa_threaded_mainloop* loop) {}

void pa_context_disconnect(pa_context *context) {}

void pa_threaded_mainloop_free(pa_threaded_mainloop *loop) {}

typedef struct VOLUME_CALLBACK {
    int index;
    int value;
} volume_callback_t;

#define PA_CONTEXT_GET_INFO(output)\
    volume_callback_t *volume = m;\
    output[0] = idx;\
    output[1] = volume->index;\
    output[2] = volume->value;\

void pa_context_get_sink_info_by_index(pa_context *context, uint32_t idx, void *s, void *m) {
    PA_CONTEXT_GET_INFO(output_sink_info);
}

void pa_context_get_sink_input_info(pa_context *context, uint32_t idx, void *s, void *m) {
    PA_CONTEXT_GET_INFO(output_sink_input_info);
}

void pa_context_get_source_info_by_index(pa_context *context, uint32_t idx, void *s, void *m) {
    PA_CONTEXT_GET_INFO(output_source_info);
}

void pa_context_get_source_output_info(pa_context *context, uint32_t idx, void *s, void *m) {
    PA_CONTEXT_GET_INFO(output_source_output_info);
}

#define PA_CONTEXT_SET_VOLUME(output)\
    output[0] = idx;\
    output[1] = v->values[0];\
    output[2] = v->values[1];\

void pa_context_set_sink_volume_by_index(pa_context *context, uint32_t idx, pa_cvolume *v, void *s, void *m) {
    PA_CONTEXT_SET_VOLUME(output_sink_volume);
}

void pa_context_set_sink_input_volume(pa_context *context, uint32_t idx, pa_cvolume *v, void *s, void *m) {
    PA_CONTEXT_SET_VOLUME(output_sink_input_volume);
}

void pa_context_set_source_volume_by_index(pa_context *context, uint32_t idx, pa_cvolume *v, void *s, void *m) {
    PA_CONTEXT_SET_VOLUME(output_source_volume);
}

void pa_context_set_source_output_volume(pa_context *context, uint32_t idx, pa_cvolume *v, void *s, void *m) {
    PA_CONTEXT_SET_VOLUME(output_source_output_volume);
}

#define PA_CONTEXT_SET_MUTE(output)\
    output[0] = idx;\
    output[1] = v;\

void pa_context_set_sink_mute_by_index(pa_context* context, uint32_t idx, int v, void *s, void *m) {
    PA_CONTEXT_SET_MUTE(output_sink_mute);
}

void pa_context_set_sink_input_mute(pa_context *context, uint32_t idx, int v, void *s, void *m) {
    PA_CONTEXT_SET_MUTE(output_sink_input_mute);
}

void pa_context_set_source_mute_by_index(pa_context *context, uint32_t idx, int v, void *s, void *m) {
    PA_CONTEXT_SET_MUTE(output_source_mute);
}

void pa_context_set_source_output_mute(pa_context *context, uint32_t idx, int v, void *s, void *m) {
    PA_CONTEXT_SET_MUTE(output_source_output_mute);
}

void pa_context_set_card_profile_by_index(pa_context *context, uint32_t idx, const char *name, void *s, void *m) {
    output_card_profile.index = idx;
    strcpy(output_card_profile.active, name);
}

#define PA_CONTEXT_SET_PORT(output)\
    output.index = idx;\
    strcpy(output.active, name);\

void pa_context_set_sink_port_by_index(pa_context *context, uint32_t idx, const char *name, void *s, void *m) {
    PA_CONTEXT_SET_PORT(output_sink_port);
}

void pa_context_set_source_port_by_index(pa_context *context, uint32_t idx, const char *name, void *s, void *m) {
    PA_CONTEXT_SET_PORT(output_source_port);
}

pa_context_state_t pa_context_get_state(pa_context *context) {
    return s_instance;
}

const char *pa_proplist_gets(pa_proplist proplist, int mask) {
    return "str";
}

void pa_context_get_card_info_by_index(pa_context *context, uint32_t idx, void *s, void *m) {}

void pa_context_get_client_info(pa_context *context, uint32_t idx, void *s, void *m) {}
