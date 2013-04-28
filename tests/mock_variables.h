#ifndef MOCK_VARIABLES_H
#define MOCK_VARIABLES_H

#include <string.h>

typedef int pa_threaded_mainloop;
typedef int pa_mainloop_api;
typedef int pa_context;
extern pa_threaded_mainloop s_instance;
extern pa_mainloop_api s_api;
extern pa_context s_context;

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

typedef struct OUTPUT_CARD_PROFILE {
    int index;
    char active[32];
} output_card_profile_t;

extern output_card_profile_t output_card_profile;

void reset_mock_variables();

#endif
