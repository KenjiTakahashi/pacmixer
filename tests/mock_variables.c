#include "mock_variables.h"


pa_threaded_mainloop s_instance = -1;
pa_mainloop_api s_api = 1;
pa_context s_context = 1;
pa_context_state_t s_state = PA_CONTEXT_UNCONNECTED;

int output_sink_volume[3] = {PA_INVALID_INDEX, 0, 0};
int output_sink_input_volume[3] = {PA_INVALID_INDEX, 0, 0};
int output_source_volume[3] = {PA_INVALID_INDEX, 0, 0};
int output_source_output_volume[3] = {PA_INVALID_INDEX, 0, 0};

int output_sink_info[3] = {PA_INVALID_INDEX, 0, 0};
int output_sink_input_info[3] = {PA_INVALID_INDEX, 0, 0};
int output_source_info[3] = {PA_INVALID_INDEX, 0, 0};
int output_source_output_info[3] = {PA_INVALID_INDEX, 0, 0};

int output_sink_mute[2] = {PA_INVALID_INDEX, 0};
int output_sink_input_mute[2] = {PA_INVALID_INDEX, 0};
int output_source_mute[2] = {PA_INVALID_INDEX, 0};
int output_source_output_mute[2] = {PA_INVALID_INDEX, 0};

output_index_active_t output_card_profile = {.index = PA_INVALID_INDEX, .active = ""};

output_index_active_t output_sink_port = {.index = PA_INVALID_INDEX, .active = ""};
output_index_active_t output_source_port = {.index = PA_INVALID_INDEX, .active = ""};

int output_card_info = PA_INVALID_INDEX;

int output_client_info = PA_INVALID_INDEX;

void reset_mock_variables() {
    s_instance = -1;
    s_api = 1;
    s_context = 1;
    output_sink_volume[0] = PA_INVALID_INDEX;
    output_sink_volume[1] = 0;
    output_sink_volume[2] = 0;
    output_sink_input_volume[0] = PA_INVALID_INDEX;
    output_sink_input_volume[1] = 0;
    output_sink_input_volume[2] = 0;
    output_source_volume[0] = PA_INVALID_INDEX;
    output_source_volume[1] = 0;
    output_source_volume[2] = 0;
    output_source_output_volume[0] = PA_INVALID_INDEX;
    output_source_output_volume[1] = 0;
    output_source_output_volume[2] = 0;
    output_sink_info[0] = PA_INVALID_INDEX;
    output_sink_info[1] = 0;
    output_sink_info[2] = 0;
    output_sink_input_info[0] = PA_INVALID_INDEX;
    output_sink_input_info[1] = 0;
    output_sink_input_info[2] = 0;
    output_source_info[0] = PA_INVALID_INDEX;
    output_source_info[1] = 0;
    output_source_info[2] = 0;
    output_source_output_info[0] = PA_INVALID_INDEX;
    output_source_output_info[1] = 0;
    output_source_output_info[2] = 0;
    output_sink_mute[0] = PA_INVALID_INDEX;
    output_sink_mute[1] = 0;
    output_sink_input_mute[0] = PA_INVALID_INDEX;
    output_sink_input_mute[1] = 0;
    output_source_mute[0] = PA_INVALID_INDEX;
    output_source_mute[1] = 0;
    output_source_output_mute[0] = PA_INVALID_INDEX;
    output_source_output_mute[1] = 0;
    output_card_profile.index = 0;
    strcpy(output_card_profile.active, "");
    output_sink_port.index = 0;
    strcpy(output_sink_port.active, "");
    output_source_port.index = 0;
    strcpy(output_source_port.active, "");
    output_card_info = PA_INVALID_INDEX;
    output_client_info = PA_INVALID_INDEX;
}
