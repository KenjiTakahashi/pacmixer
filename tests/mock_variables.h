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


#ifndef MOCK_VARIABLES_H
#define MOCK_VARIABLES_H


#include <string.h>
#include <stdint.h>


#define STRING_SIZE 32
#define PA_CHANNELS_MAX 32U // Taken from PA sources.

typedef int pa_threaded_mainloop;
typedef int pa_mainloop_api;
typedef int pa_context;
typedef int pa_context_state_t;
typedef struct PA_CLIENT_INFO {
    uint32_t index;
    char name[STRING_SIZE];
} pa_client_info;
typedef struct PA_CVOLUME {
    int channels;
    int values[PA_CHANNELS_MAX];
} pa_cvolume;
struct PA_INFO {
    uint32_t index;
    pa_cvolume volume;
    int mute;
    const char *name;
    uint32_t client;
    const char *description;
    uint32_t sink;
    uint32_t source;
};
typedef struct PA_INFO pa_sink_input_info;
typedef struct PA_INFO pa_source_output_info;
struct PA_PORT_INFO {
    char name[STRING_SIZE];
    char description[STRING_SIZE];
};
typedef struct PA_PORT_INFO pa_sink_port_info;
typedef struct PA_PORT_INFO pa_source_port_info;
typedef struct PA_PORT_INFO pa_sink_port_info;
typedef struct PA_PORT_INFO pa_source_port_info;
struct PA_PORT_INFO_INFO {
    uint32_t index;
    pa_cvolume volume;
    int mute;
    char name[STRING_SIZE];
    char description[STRING_SIZE];
    int n_ports;
    struct PA_PORT_INFO **ports;
    struct PA_PORT_INFO *active_port;
};
typedef struct PA_PORT_INFO_INFO pa_sink_info;
typedef struct PA_PORT_INFO_INFO pa_source_info;
typedef struct PA_CARD_PROFILE_INFO {
    char name[STRING_SIZE];
    char description[STRING_SIZE];
} pa_card_profile_info;
typedef char pa_proplist[STRING_SIZE];
typedef struct PA_CARD_INFO {
    uint32_t index;
    int n_profiles;
    pa_proplist proplist;
    pa_card_profile_info *profiles;
    pa_card_profile_info *active_profile;
} pa_card_info;
typedef struct PA_SERVER_INFO {
    const char *default_sink_name;
    const char *default_source_name;
} pa_server_info;
typedef struct OUTPUT_INDEX_ACTIVE {
    int index;
    char active[STRING_SIZE];
} output_index_active_t;

extern pa_threaded_mainloop s_instance;
extern pa_mainloop_api s_api;
extern pa_context s_context;
extern pa_context_state_t s_state;

extern int output_sink_volume[3];
extern int output_sink_input_volume[3];
extern int output_source_volume[3];
extern int output_source_output_volume[3];

extern int output_sink_info[3];
extern int output_sink_input_info[3];
extern int output_source_info[3];
extern int output_source_output_info[3];

extern int output_sink_mute[2];
extern int output_sink_input_mute[2];
extern int output_source_mute[2];
extern int output_source_output_mute[2];

extern output_index_active_t output_card_profile;

extern output_index_active_t output_sink_port;
extern output_index_active_t output_source_port;

extern int output_card_info;

extern int output_client_info;

extern char default_sink[STRING_SIZE];
extern char default_source[STRING_SIZE];

enum {
    PA_CONTEXT_UNCONNECTED,
    PA_CONTEXT_READY,
    PA_CONTEXT_FAILED,
    PA_CONTEXT_TERMINATED
};

enum {
    PA_INVALID_INDEX,
    PA_VALID_INDEX,
    PA_CLIENT_INDEX
};

void reset_mock_variables();

#endif
