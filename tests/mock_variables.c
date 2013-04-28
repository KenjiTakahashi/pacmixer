#include "mock_variables.h"


pa_threaded_mainloop s_instance = -1;
pa_mainloop_api s_api = 1;
pa_context s_context = 1;

int output_sink_volume[2] = {0, 0};
int output_sink_input_volume[2] = {0, 0};
int output_source_volume[2] = {0, 0};
int output_source_output_volume[2] = {0, 0};

int output_sink_info[3] = {0, 0, 0};
int output_sink_input_info[3] = {0, 0, 0};
int output_source_info[3] = {0, 0, 0};
int output_source_output_info[3] = {0, 0, 0};

int output_sink_mute[2] = {0, 0};
int output_sink_input_mute[2] = {0, 0};
int output_source_mute[2] = {0, 0};
int output_source_output_mute[2] = {0, 0};

void reset_mock_variables() {
    s_instance = -1;
    s_api = 1;
    s_context = 1;
    output_sink_volume[0] = 0;
    output_sink_volume[1] = 0;
    output_sink_input_volume[0] = 0;
    output_sink_input_volume[1] = 0;
    output_source_volume[0] = 0;
    output_source_volume[1] = 0;
    output_source_output_volume[0] = 0;
    output_source_output_volume[1] = 0;
    output_sink_info[0] = 0;
    output_sink_info[1] = 0;
    output_sink_info[2] = 0;
    output_sink_input_info[0] = 0;
    output_sink_input_info[1] = 0;
    output_sink_input_info[2] = 0;
    output_source_info[0] = 0;
    output_source_info[1] = 0;
    output_source_info[2] = 0;
    output_source_output_info[0] = 0;
    output_source_output_info[1] = 0;
    output_source_output_info[2] = 0;
    output_sink_mute[0] = 0;
    output_sink_mute[1] = 0;
    output_sink_input_mute[0] = 0;
    output_sink_input_mute[1] = 0;
    output_source_mute[0] = 0;
    output_source_mute[1] = 0;
    output_source_output_mute[0] = 0;
    output_source_output_mute[1] = 0;
}
