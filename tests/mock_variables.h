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

typedef struct OUTPUT_INDEX_ACTIVE {
    int index;
    char active[STRING_SIZE];
} output_index_active_t;

extern output_index_active_t output_card_profile;

extern output_index_active_t output_sink_port;
extern output_index_active_t output_source_port;

enum {
    PA_CONTEXT_UNCONNECTED,
    PA_CONTEXT_READY,
    PA_CONTEXT_FAILED,
    PA_CONTEXT_TERMINATED
};

enum {
    PA_INVALID_INDEX,
    PA_VALID_INDEX
};

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
    char description[STRING_SIZE];
    int n_ports;
    struct PA_PORT_INFO **ports;
    struct PA_PORT_INFO *active_port;
};
typedef struct PA_PORT_INFO_INFO pa_sink_info;
typedef struct PA_PORT_INFO_INFO pa_source_info;

void reset_mock_variables();

#endif
