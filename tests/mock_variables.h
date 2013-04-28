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

void reset_mock_variables();
