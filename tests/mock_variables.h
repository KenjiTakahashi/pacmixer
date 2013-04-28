#ifndef MOCK_VARIABLES_H
#define MOCK_VARIABLES_H

#include <string.h>

#define STRING_SIZE 32

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

void reset_mock_variables();

#endif
