/*
 This is a part of pacmixer @ http://github.com/KenjiTakahashi/pacmixer
 Karol "Kenji Takahashi" Woźniak © 2013 - 2014

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


#include <stdint.h>
#include <string.h>
#include "mock_variables.h"


typedef int pa_context_state_t;

typedef enum {
    PA_CONTEXT_NOFAIL
} pa_context_flags_t;

typedef enum {
    PA_SUBSCRIPTION_MASK_ALL,
    PA_SUBSCRIPTION_EVENT_TYPE_MASK,
    PA_SUBSCRIPTION_EVENT_FACILITY_MASK,
    PA_SUBSCRIPTION_EVENT_CARD,
    PA_SUBSCRIPTION_EVENT_CHANGE,
    PA_SUBSCRIPTION_EVENT_REMOVE,
    PA_SUBSCRIPTION_EVENT_NEW,
    PA_SUBSCRIPTION_EVENT_SINK_INPUT,
    PA_SUBSCRIPTION_EVENT_SINK,
    PA_SUBSCRIPTION_EVENT_SOURCE,
    PA_SUBSCRIPTION_EVENT_SOURCE_OUTPUT,
    PA_SUBSCRIPTION_EVENT_SERVER
} pa_subscription_event_type_t;

enum {
    PA_PROP_DEVICE_DESCRIPTION
};

#define PA_VOLUME_UI_MAX 150
#define PA_VOLUME_NORM 100

pa_threaded_mainloop *pa_threaded_mainloop_new();
pa_mainloop_api *pa_threaded_mainloop_get_api(pa_threaded_mainloop*);
pa_context *pa_context_new(pa_mainloop_api*, const char*);
int pa_context_connect(pa_context*, void*, int, void*);
void pa_context_unref(pa_context*);
void pa_context_set_state_callback(pa_context*, void(*)(pa_context*, void*), void*);
void pa_threaded_mainloop_start(pa_threaded_mainloop*);
void pa_context_set_subscribe_callback(pa_context*, void(*)(pa_context*, pa_subscription_event_type_t, uint32_t, void*), void*);
void pa_context_subscribe(pa_context*, int, void*, void*);
void pa_context_get_sink_input_info_list(pa_context*, void(*)(pa_context*, const pa_sink_input_info*, int, void*), void*);
void pa_context_get_sink_info_list(pa_context*, void(*)(pa_context*, const pa_sink_info*, int, void*), void*);
void pa_context_get_source_output_info_list(pa_context*, void(*)(pa_context*, const pa_source_output_info*, int, void*), void*);
void pa_context_get_source_info_list(pa_context*, void(*)(pa_context*, const pa_source_info*, int, void*), void*);
void pa_context_get_card_info_list(pa_context*, void(*)(pa_context*, const pa_card_info*, int, void*), void*);
void pa_threaded_mainloop_stop(pa_threaded_mainloop*);
void pa_context_disconnect(pa_context*);
void pa_threaded_mainloop_free(pa_threaded_mainloop*);
void pa_context_get_sink_info_by_index(pa_context*, uint32_t, void(*)(pa_context*, const pa_sink_info*, int, void*), void*);
void pa_context_get_sink_input_info(pa_context*, uint32_t, void(*)(pa_context*, const pa_sink_input_info*, int, void*), void*);
void pa_context_get_source_info_by_index(pa_context*, uint32_t, void(*)(pa_context*, const pa_source_info*, int, void*), void*);
void pa_context_get_source_output_info(pa_context*, uint32_t, void(*)(pa_context*, const pa_source_output_info*, int, void*), void*);
void pa_context_set_sink_volume_by_index(pa_context*, uint32_t, pa_cvolume*, void*, void*);
void pa_context_set_sink_input_volume(pa_context*, uint32_t, pa_cvolume*, void*, void*);
void pa_context_set_source_volume_by_index(pa_context*, uint32_t, pa_cvolume*, void*, void*);
void pa_context_set_source_output_volume(pa_context*, uint32_t, pa_cvolume*, void*, void*);
void pa_context_set_sink_mute_by_index(pa_context*, uint32_t, int, void*, void*);
void pa_context_set_sink_input_mute(pa_context*, uint32_t, int, void*, void*);
void pa_context_set_source_mute_by_index(pa_context*, uint32_t, int, void*, void*);
void pa_context_set_source_output_mute(pa_context*, uint32_t, int, void*, void*);
void pa_context_set_card_profile_by_index(pa_context*, uint32_t, const char*, void*, void*);
void pa_context_set_sink_port_by_index(pa_context*, uint32_t, const char*, void*, void*);
void pa_context_set_source_port_by_index(pa_context*, uint32_t, const char*, void*, void*);
void pa_context_set_default_sink(pa_context*, const char*, void*, void*);
void pa_context_set_default_source(pa_context*, const char*, void*, void*);
pa_context_state_t pa_context_get_state(pa_context*);
const char *pa_proplist_gets(const pa_proplist, int);
void pa_context_get_card_info_by_index(pa_context*, uint32_t, void(*)(pa_context*, const pa_card_info*, int, void*), void*);
void pa_context_get_client_info(pa_context*, uint32_t, void(*)(pa_context*, const pa_client_info*, int, void*), void*);
void pa_context_get_server_info(pa_context*, void(*)(pa_context*, const pa_server_info*, void*), void*);
void pa_context_move_sink_input_by_name(pa_context*, uint32_t, const char*, void(*)(pa_context*, int, void*), void*);
void pa_context_move_source_output_by_name(pa_context*, uint32_t, const char*, void(*)(pa_context*, int, void*), void*);
