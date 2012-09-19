/*
 This is a part of pacmixer @ http://github.com/KenjiTakahashi/pacmixer
 Karol "Kenji Takahashi" Woźniak © 2012

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


context_t *backend_new() {
    context_t *context = malloc(sizeof(context_t));
    context->loop = pa_threaded_mainloop_new();
    pa_mainloop_api *api = pa_threaded_mainloop_get_api(context->loop);
    context->context = pa_context_new(api, "pacmixer");
    pa_context_connect(context->context, NULL, 0, NULL);
    pa_context_set_state_callback(context->context, _cb_state_changed, &context->state);
    return context;
}

int backend_init(context_t *context) {
    pa_threaded_mainloop_start(context->loop);
    while(context->state != PA_CONTEXT_READY) {
        if(context->state == PA_CONTEXT_FAILED || context->state == PA_CONTEXT_TERMINATED) {
            printf("failed to connect to PA server!\n");
            return -1;
        }
    }
    pa_context_set_subscribe_callback(context->context, _cb_event, NULL);
    pa_context_subscribe(context->context, PA_SUBSCRIPTION_MASK_ALL, NULL, NULL);
    pa_context_get_sink_input_info_list(context->context, _cb_sink_input, NULL);
    pa_context_get_sink_info_list(context->context, _cb_sink, NULL);
    return 0;
}

void backend_destroy(context_t *context) {
    pa_threaded_mainloop_stop(context->loop);
    pa_context_disconnect(context->context);
    pa_context_unref(context->context);
    pa_threaded_mainloop_free(context->loop);
    free(context);
}

void _cb_state_changed(pa_context *c, void *userdata) {
    pa_context_state_t *_pa_state = userdata;
    *_pa_state = pa_context_get_state(c);
}

void _cb_client(pa_context *c, const pa_client_info *info, int eol, void *userdata) {
    if(!eol && info->index != PA_INVALID_INDEX) {
        printf("::%s\n", info->name);
    }
}

void _cb_sink(pa_context *c, const pa_sink_info *info, int eol, void *userdata) {
    if(!eol && info->index != PA_INVALID_INDEX) {
        printf("%s\n", info->description);
    }
}

void _cb_sink_input(pa_context *c, const pa_sink_input_info *info, int eol, void *userdata) {
    if(!eol && info->index != PA_INVALID_INDEX) {
        /* TODO: We'll need this info->name once status line is done. */
        if(info->client != PA_INVALID_INDEX) {
            pa_context_get_client_info(c, info->client, _cb_client, NULL);
        }
    }
}

void _cb_event(pa_context *c, pa_subscription_event_type_t t, uint32_t idx, void *userdata) {
    printf("event\n");
}

int main() {
    context_t *context = backend_new();
    if(backend_init(context) != 0) {
        return -1;
    }
    int running = 1;
    while(running) {
        char c;
        scanf("%c", &c);
        if(c == 'e') {
            running = 0;
        }
    }
    backend_destroy(context);
    return 0;
}
