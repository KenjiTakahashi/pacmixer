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


#include "catch.hpp"
extern "C" {
#include "mock_variables.h"
#include "../src/backend.c"
}


TEST_CASE("backend_new/connect", "Should successfully return PA context") {
    s_instance = 1;
    callback_t *sc = (callback_t*)malloc(sizeof(callback_t));
    context_t *e = (context_t*)malloc(sizeof(context_t));
    e->loop = &s_instance;
    e->context = &s_context;
    context_t *r = backend_new(sc);

    REQUIRE(r->loop == e->loop);
    REQUIRE(r->context == e->context);

    free(r);
    free(e);
    free(sc);
}

TEST_CASE("backend_volume_set", "Should set volume for a single channel") {
    // "Single" really means "not all".
    // To do so, it needs to get current volumes
    // and that is what we really test here.
    // Callbacks are tested elsewhere.
    context_t *c = (context_t*)malloc(sizeof(context_t));

    SECTION("sink", "") {
        backend_volume_set(c, SINK, PA_VALID_INDEX, 2, 10);

        REQUIRE(output_sink_info[0] == PA_VALID_INDEX);
        REQUIRE(output_sink_info[1] == 2);
        REQUIRE(output_sink_info[2] == 10);
    }

    SECTION("sink input", "") {
        backend_volume_set(c, SINK_INPUT, PA_VALID_INDEX, 2, 10);

        REQUIRE(output_sink_input_info[0] == PA_VALID_INDEX);
        REQUIRE(output_sink_input_info[1] == 2);
        REQUIRE(output_sink_input_info[2] == 10);
    }

    SECTION("source", "") {
        backend_volume_set(c, SOURCE, PA_VALID_INDEX, 2, 10);

        REQUIRE(output_source_info[0] == PA_VALID_INDEX);
        REQUIRE(output_source_info[1] == 2);
        REQUIRE(output_source_info[2] == 10);
    }

    SECTION("source output", "") {
        backend_volume_set(c, SOURCE_OUTPUT, PA_VALID_INDEX, 2, 10);

        REQUIRE(output_source_output_info[0] == PA_VALID_INDEX);
        REQUIRE(output_source_output_info[1] == 2);
        REQUIRE(output_source_output_info[2] == 10);
    }

    reset_mock_variables();

    SECTION("other", "Should not do anything") {
        backend_volume_set(c, CARD, PA_VALID_INDEX, 2, 10);

        REQUIRE(output_sink_info[0] == PA_INVALID_INDEX);
        REQUIRE(output_sink_info[1] == 0);
        REQUIRE(output_sink_info[2] == 0);
        REQUIRE(output_sink_input_info[0] == PA_INVALID_INDEX);
        REQUIRE(output_sink_input_info[1] == 0);
        REQUIRE(output_sink_input_info[2] == 0);
        REQUIRE(output_source_info[0] == PA_INVALID_INDEX);
        REQUIRE(output_source_info[1] == 0);
        REQUIRE(output_source_info[2] == 0);
        REQUIRE(output_source_output_info[0] == PA_INVALID_INDEX);
        REQUIRE(output_source_output_info[1] == 0);
        REQUIRE(output_source_output_info[2] == 0);
    }

    free(c);
}

TEST_CASE("backend_volume_setall", "Should set volume for all channels") {
    // We'll use two channels, but it scales by induction.
    context_t *c = (context_t*)malloc(sizeof(context_t));
    int e[2] = {10, 15};

    SECTION("sink", "") {
        backend_volume_setall(c, SINK, PA_VALID_INDEX, e, 2);

        REQUIRE(output_sink_volume[0] == PA_VALID_INDEX);
        REQUIRE(output_sink_volume[1] == 10);
        REQUIRE(output_sink_volume[2] == 15);
    }

    SECTION("sink input", "") {
        backend_volume_setall(c, SINK_INPUT, PA_VALID_INDEX, e, 2);

        REQUIRE(output_sink_input_volume[0] == PA_VALID_INDEX);
        REQUIRE(output_sink_input_volume[1] == 10);
        REQUIRE(output_sink_input_volume[2] == 15);
    }

    SECTION("source", "") {
        backend_volume_setall(c, SOURCE, PA_VALID_INDEX, e, 2);

        REQUIRE(output_source_volume[0] == PA_VALID_INDEX);
        REQUIRE(output_source_volume[1] == 10);
        REQUIRE(output_source_volume[2] == 15);
    }

    SECTION("source output", "") {
        backend_volume_setall(c, SOURCE_OUTPUT, PA_VALID_INDEX, e, 2);

        REQUIRE(output_source_output_volume[0] == PA_VALID_INDEX);
        REQUIRE(output_source_output_volume[1] == 10);
        REQUIRE(output_source_output_volume[2] == 15);
    }

    reset_mock_variables();

    SECTION("other", "Should not do anything") {
        backend_volume_setall(c, CARD, PA_VALID_INDEX, e, 2);

        REQUIRE(output_sink_volume[0] == PA_INVALID_INDEX);
        REQUIRE(output_sink_volume[1] == 0);
        REQUIRE(output_sink_volume[2] == 0);
        REQUIRE(output_sink_input_volume[0] == PA_INVALID_INDEX);
        REQUIRE(output_sink_input_volume[1] == 0);
        REQUIRE(output_sink_input_volume[2] == 0);
        REQUIRE(output_source_volume[0] == PA_INVALID_INDEX);
        REQUIRE(output_source_volume[1] == 0);
        REQUIRE(output_source_volume[2] == 0);
        REQUIRE(output_source_output_volume[0] == PA_INVALID_INDEX);
        REQUIRE(output_source_output_volume[1] == 0);
        REQUIRE(output_source_output_volume[2] == 0);
    }

    free(c);
}

TEST_CASE("backend_mute_set", "Should set mute state for control") {
    context_t *c = (context_t*)malloc(sizeof(context_t));

    SECTION("sink", "") {
        backend_mute_set(c, SINK, PA_VALID_INDEX, 1);

        REQUIRE(output_sink_mute[0] == PA_VALID_INDEX);
        REQUIRE(output_sink_mute[1] == 1);
    }

    SECTION("sink input", "") {
        backend_mute_set(c, SINK_INPUT, PA_VALID_INDEX, 1);

        REQUIRE(output_sink_input_mute[0] == PA_VALID_INDEX);
        REQUIRE(output_sink_input_mute[1] == 1);
    }

    SECTION("source", "") {
        backend_mute_set(c, SOURCE, PA_VALID_INDEX, 1);

        REQUIRE(output_source_mute[0] == PA_VALID_INDEX);
        REQUIRE(output_source_mute[1] == 1);
    }

    SECTION("source output", "") {
        backend_mute_set(c, SOURCE_OUTPUT, PA_VALID_INDEX, 1);

        REQUIRE(output_source_output_mute[0] == PA_VALID_INDEX);
        REQUIRE(output_source_output_mute[1] == 1);
    }

    reset_mock_variables();

    SECTION("other", "Should not do anything") {
        backend_mute_set(c, CARD, PA_VALID_INDEX, 1);

        REQUIRE(output_sink_mute[0] == PA_INVALID_INDEX);
        REQUIRE(output_sink_mute[1] == 0);
        REQUIRE(output_sink_input_mute[0] == PA_INVALID_INDEX);
        REQUIRE(output_sink_input_mute[1] == 0);
        REQUIRE(output_source_mute[0] == PA_INVALID_INDEX);
        REQUIRE(output_source_mute[1] == 0);
        REQUIRE(output_source_output_mute[0] == PA_INVALID_INDEX);
        REQUIRE(output_source_output_mute[1] == 0);
    }

    free(c);
}

TEST_CASE("backend_card_profile_set", "Should set active card profile") {
    // The value of backend_entry_type is ignored.
    context_t *c = (context_t*)malloc(sizeof(context_t));

    backend_card_profile_set(c, CARD, PA_VALID_INDEX, "active_profile");

    REQUIRE(output_card_profile.index == PA_VALID_INDEX);
    REQUIRE(strcmp(output_card_profile.active, "active_profile") == 0);

    free(c);
}

TEST_CASE("backend_default_set", "Should set defaults") {
    context_t *c = (context_t*)malloc(sizeof(context_t));

    SECTION("sink", "") {
        backend_default_set(c, SINK, "sink.1");

        REQUIRE(strcmp(default_sink, "sink.1") == 0);
    }

    SECTION("source", "") {
        backend_default_set(c, SOURCE, "source.1");

        REQUIRE(strcmp(default_source, "source.1") == 0);
    }

    reset_mock_variables();

    SECTION("other", "Should not do anything") {
        backend_default_set(c, SINK_INPUT, "other");
        backend_default_set(c, SOURCE_OUTPUT, "other");
        backend_default_set(c, CARD, "other");

        REQUIRE(strcmp(default_sink, "") == 0);
        REQUIRE(strcmp(default_source, "") == 0);
    }

    free(c);
}

TEST_CASE("backend_port_set", "Should set active port") {
    context_t *c = (context_t*)malloc(sizeof(context_t));

    SECTION("sink", "") {
        backend_port_set(c, SINK, PA_VALID_INDEX, "active_port");

        REQUIRE(output_sink_port.index == PA_VALID_INDEX);
        REQUIRE(strcmp(output_sink_port.active, "active_port") == 0);
    }

    SECTION("source", "") {
        backend_port_set(c, SOURCE, PA_VALID_INDEX, "active_port");

        REQUIRE(output_source_port.index == PA_VALID_INDEX);
        REQUIRE(strcmp(output_source_port.active, "active_port") == 0);
    }

    reset_mock_variables();

    SECTION("other", "Should not do anything") {
        backend_entry_type types[3] = {SINK_INPUT, SOURCE_OUTPUT, CARD};
        for(int i = 0; i < 3; ++i) {
            backend_port_set(c, types[i], PA_VALID_INDEX, "active_port");

            REQUIRE(output_sink_port.index == PA_INVALID_INDEX);
            REQUIRE(strcmp(output_sink_port.active, "") == 0);
            REQUIRE(output_source_port.index == PA_INVALID_INDEX);
            REQUIRE(strcmp(output_source_port.active, "") == 0);
        }
    }

    free(c);
}

int TEST_RETURN__cb_state_changed = 0;

void TEST_CALLBACK__cb_state_changed(void *s) {
    TEST_RETURN__cb_state_changed = 1;
}

TEST_CASE("_cb_state_changed", "Should fire a callback on state changes") {
    callback_t *sc = (callback_t*)malloc(sizeof(callback_t));
    sc->state = (void*)TEST_CALLBACK__cb_state_changed;

    SECTION("ready", "PA_CONTEXT_READY") {
        s_state = PA_CONTEXT_READY;
        _cb_state_changed(NULL, sc);

        REQUIRE(TEST_RETURN__cb_state_changed == 1);
    }

    SECTION("failed", "PA_CONTEXT_FAILED") {
        s_state = PA_CONTEXT_FAILED;
        _cb_state_changed(NULL, sc);

        REQUIRE(TEST_RETURN__cb_state_changed == 1);
    }

    TEST_RETURN__cb_state_changed = 0;

    SECTION("terminated", "PA_CONTEXT_TERMINATED") {
        s_state = PA_CONTEXT_TERMINATED;
        _cb_state_changed(NULL, sc);

        REQUIRE(TEST_RETURN__cb_state_changed == 1);
    }

    s_state = PA_CONTEXT_UNCONNECTED;
    free(sc);
}

char TEST_RETURN__cb_client_name[STRING_SIZE];
uint32_t TEST_RETURN__cb_client_idx = PA_INVALID_INDEX;
backend_data_t TEST_RETURN__cb_client_data;

void TEST_CALLBACK__cb_client(void *s, const char *name, backend_entry_type type, uint32_t idx, backend_data_t *data) {
    strcpy(TEST_RETURN__cb_client_name, name);
    TEST_RETURN__cb_client_idx = idx;
    TEST_RETURN__cb_client_data.channels_num = data->channels_num;
    *TEST_RETURN__cb_client_data.channels = *(data->channels);
    *TEST_RETURN__cb_client_data.volumes = *(data->volumes);
}

TEST_CASE("_cb_client", "Should fire 'add' callback with client data") {
    TEST_RETURN__cb_client_data.channels = (backend_channel_t*)malloc(sizeof(backend_channel_t));
    TEST_RETURN__cb_client_data.volumes = (backend_volume_t*)malloc(sizeof(backend_volume_t));

    pa_client_info info;
    info.index = PA_VALID_INDEX;
    strcpy(info.name, "test_name");
    callback_t *cb = (callback_t*)malloc(sizeof(callback_t));
    cb->add = (void*)TEST_CALLBACK__cb_client;
    client_callback_t *cc = (client_callback_t*)malloc(sizeof(client_callback_t));
    cc->callback = cb;
    cc->channels = (backend_channel_t*)malloc(sizeof(backend_channel_t));
    cc->channels[0].maxLevel = 120;
    cc->channels[0].normLevel = 90;
    cc->channels[0].isMutable = 1;
    cc->volumes = (backend_volume_t*)malloc(sizeof(backend_volume_t));
    cc->volumes[0].level = 50;
    cc->volumes[0].mute = 1;
    cc->chnum = 1;
    cc->index = PA_VALID_INDEX;

    _cb_client(NULL, &info, 0, (void*)cc);

    REQUIRE(strcmp(TEST_RETURN__cb_client_name, "test_name") == 0);
    REQUIRE(TEST_RETURN__cb_client_idx == PA_VALID_INDEX);
    REQUIRE(TEST_RETURN__cb_client_data.option == NULL);
    REQUIRE(TEST_RETURN__cb_client_data.channels_num == 1);
    REQUIRE(TEST_RETURN__cb_client_data.channels[0].maxLevel == 120);
    REQUIRE(TEST_RETURN__cb_client_data.channels[0].normLevel == 90);
    REQUIRE(TEST_RETURN__cb_client_data.channels[0].isMutable == 1);
    REQUIRE(TEST_RETURN__cb_client_data.volumes[0].level == 50);
    REQUIRE(TEST_RETURN__cb_client_data.volumes[0].mute == 1);

    free(cb);

    free(TEST_RETURN__cb_client_data.volumes);
    free(TEST_RETURN__cb_client_data.channels);
}

backend_option_t TEST_RETURN__CB1__CB_U;

void TEST_FUNC__CB1__CB_U(const pa_sink_info *idx, backend_entry_type type, backend_option_t *options, void *userdata) {
    strcpy(TEST_RETURN__CB1__CB_U.names[0], options->names[0]);
    strcpy(TEST_RETURN__CB1__CB_U.descriptions[0], options->descriptions[0]);
    strcpy(TEST_RETURN__CB1__CB_U.active, options->active);
    TEST_RETURN__CB1__CB_U.size = options->size;
}

_CB_DEVICE(_TEST_cb_sink, pa_sink_info, TEST_FUNC__CB1__CB_U, SINK);
TEST_CASE("_CB_DEVICE", "Should generate device adding/updating function") {
    // We'll use pa_sink_info here, but it scales to other pa_source_info
    // structures as well.
    TEST_RETURN__CB1__CB_U.names = (char**)malloc(sizeof(char*));
    TEST_RETURN__CB1__CB_U.names[0] = (char*)malloc(sizeof(char) * STRING_SIZE);
    TEST_RETURN__CB1__CB_U.descriptions = (char**)malloc(sizeof(char*));
    TEST_RETURN__CB1__CB_U.descriptions[0] = (char*)malloc(sizeof(char) * STRING_SIZE);
    TEST_RETURN__CB1__CB_U.active = (char*)malloc(sizeof(char) * STRING_SIZE);

    pa_sink_info *info = (pa_sink_info*)malloc(sizeof(pa_sink_info));
    info->index = PA_VALID_INDEX;
    info->volume.channels = 2;
    info->volume.values[0] = 90;
    info->volume.values[1] = 120;
    info->mute = 1;
    strcpy(info->description, "test_desc");
    info->n_ports = 1;
    info->ports = (pa_sink_port_info**)malloc(sizeof(pa_sink_port_info*));
    info->ports[0] = (pa_sink_port_info*)malloc(sizeof(pa_sink_port_info));
    strcpy(info->ports[0]->name, "test_port_name");
    strcpy(info->ports[0]->description, "test_port_desc");
    info->active_port = (pa_sink_port_info*)malloc(sizeof(pa_sink_port_info));
    strcpy(info->active_port->name, "test_active_port_name");
    strcpy(info->active_port->description, "test_active_port_desc");

    _TEST_cb_sink(NULL, info, 0, NULL);

    REQUIRE(TEST_RETURN__CB1__CB_U.size == 1);
    REQUIRE(strcmp(TEST_RETURN__CB1__CB_U.names[0], "test_port_name") == 0);
    REQUIRE(strcmp(TEST_RETURN__CB1__CB_U.descriptions[0], "test_port_desc") == 0);
    REQUIRE(strcmp(TEST_RETURN__CB1__CB_U.active, "test_active_port_desc") == 0);

    free(info->active_port);
    free(info->ports[0]);
    free(info->ports);
    free(info);

    free(TEST_RETURN__CB1__CB_U.descriptions[0]);
    free(TEST_RETURN__CB1__CB_U.descriptions);
}

backend_entry_type TEST_RETURN__CB_STREAM_U_type = CARD;
int TEST_RETURN__CB_STREAM_U_idx = PA_INVALID_INDEX;

void TEST_CALLBACK__CB_STREAM_U(void *s, backend_entry_type type, uint32_t idx, void *data) {
    TEST_RETURN__CB_STREAM_U_type = type;
    TEST_RETURN__CB_STREAM_U_idx = idx;
}

_CB_STREAM(_TEST_cb_sink_input, pa_sink_input_info, _CB_STREAM_, SINK_INPUT);
_CB_STREAM(_TEST_cb_u_sink_input, pa_sink_input_info, _CB_STREAM_U, SINK_INPUT);
TEST_CASE("_CB_STREAM", "Should generate stream adding/updating function") {
    TEST_RETURN__cb_client_data.channels = (backend_channel_t*)malloc(sizeof(backend_channel_t));
    TEST_RETURN__cb_client_data.volumes = (backend_volume_t*)malloc(sizeof(backend_volume_t));

    pa_sink_input_info info;
    info.index = PA_VALID_INDEX;
    info.volume.channels = 1;
    info.volume.values[0] = 10;
    info.mute = 0;
    info.client = PA_CLIENT_INDEX;
    callback_t *cb = (callback_t*)malloc(sizeof(callback_t));
    cb->add = (void*)TEST_CALLBACK__cb_client;
    cb->update = (void*)TEST_CALLBACK__CB_STREAM_U;

    SECTION("new", "") {
        _TEST_cb_sink_input(NULL, &info, 0, (void*)cb);

        REQUIRE(output_client_info == (int)PA_CLIENT_INDEX);
        REQUIRE(strcmp(TEST_RETURN__cb_client_name, "client_name") == 0);
        REQUIRE(TEST_RETURN__cb_client_idx == PA_VALID_INDEX);
        REQUIRE(TEST_RETURN__cb_client_data.option == NULL);
        REQUIRE(TEST_RETURN__cb_client_data.channels_num == 1);
        REQUIRE(TEST_RETURN__cb_client_data.channels[0].maxLevel == 150);
        REQUIRE(TEST_RETURN__cb_client_data.channels[0].normLevel == 100);
        REQUIRE(TEST_RETURN__cb_client_data.channels[0].isMutable == 1);
        REQUIRE(TEST_RETURN__cb_client_data.volumes[0].level == 10);
        REQUIRE(TEST_RETURN__cb_client_data.volumes[0].mute == 0);
    }

    SECTION("updated", "") {
        _TEST_cb_u_sink_input(NULL, &info, 0, (void*)cb);

        REQUIRE(TEST_RETURN__CB_STREAM_U_type == SINK_INPUT);
        REQUIRE(TEST_RETURN__CB_STREAM_U_idx == PA_VALID_INDEX);
    }

    free(cb);

    free(TEST_RETURN__cb_client_data.volumes);
    free(TEST_RETURN__cb_client_data.channels);
}

_CB_SET_VOLUME(_TEST_cb_s_sink, pa_sink_info, sink, _by_index);
_CB_SET_VOLUME(_TEST_cb_s_sink_input, pa_sink_input_info, sink_input, );
_CB_SET_VOLUME(_TEST_cb_s_source, pa_source_info, source, _by_index);
_CB_SET_VOLUME(_TEST_cb_s_source_output, pa_source_output_info, source_output, );
TEST_CASE("_CB_SET_VOLUME", "Should generate volume setting function") {
    volume_callback_t *vc = (volume_callback_t*)malloc(sizeof(volume_callback_t));
    vc->index = 1;
    vc->value = 75;
    void *userdata = (void*)vc;

    SECTION("sink", "") {
        pa_sink_info *info = (pa_sink_info*)malloc(sizeof(pa_sink_info));
        info->index = PA_VALID_INDEX;
        info->volume.channels = 2;
        info->volume.values[0] = 90;
        info->volume.values[1] = 120;

        _TEST_cb_s_sink(NULL, info, 0, userdata);

        REQUIRE(output_sink_volume[0] == PA_VALID_INDEX);
        REQUIRE(output_sink_volume[1] == 90);
        REQUIRE(output_sink_volume[2] == 75);

        free(info);
    }

    SECTION("sink input", "") {
        pa_sink_input_info *info = (pa_sink_input_info*)malloc(sizeof(pa_sink_input_info));
        info->index = PA_VALID_INDEX;
        info->volume.channels = 2;
        info->volume.values[0] = 90;
        info->volume.values[1] = 120;

        _TEST_cb_s_sink_input(NULL, info, 0, userdata);

        REQUIRE(output_sink_input_volume[0] == PA_VALID_INDEX);
        REQUIRE(output_sink_input_volume[1] == 90);
        REQUIRE(output_sink_input_volume[2] == 75);

        free(info);
    }

    SECTION("source", "") {
        pa_source_info *info = (pa_source_info*)malloc(sizeof(pa_source_info));
        info->index = PA_VALID_INDEX;
        info->volume.channels = 2;
        info->volume.values[0] = 90;
        info->volume.values[1] = 120;

        _TEST_cb_s_source(NULL, info, 0, userdata);

        REQUIRE(output_source_volume[0] == PA_VALID_INDEX);
        REQUIRE(output_source_volume[1] == 90);
        REQUIRE(output_source_volume[2] == 75);

        free(info);
    }

    SECTION("source output", "") {
        pa_source_output_info *info = (pa_source_output_info*)malloc(sizeof(pa_source_output_info));
        info->index = PA_VALID_INDEX;
        info->volume.channels = 2;
        info->volume.values[0] = 90;
        info->volume.values[1] = 120;

        _TEST_cb_s_source_output(NULL, info, 0, userdata);

        REQUIRE(output_source_output_volume[0] == PA_VALID_INDEX);
        REQUIRE(output_source_output_volume[1] == 90);
        REQUIRE(output_source_output_volume[2] == 75);

        free(info);
    }

    reset_mock_variables();
}

char TEST_RETURN__cb_card_name[STRING_SIZE];
uint32_t TEST_RETURN__cb_card_idx = PA_INVALID_INDEX;

void TEST_CALLBACK__cb_card(void *s, const char *name, backend_entry_type type, uint32_t idx, backend_data_t *data) {
    strcpy(TEST_RETURN__cb_card_name, name);
    TEST_RETURN__cb_card_idx = idx;
}

TEST_CASE("_cb_card", "Should fire 'add' callback with card data") {
    // We do 0 profiles here to avoid dealing with _do_card,
    // which is tested elsewhere.
    pa_card_info info;
    info.index = PA_VALID_INDEX;
    info.n_profiles = 0;
    strcpy(info.proplist, "test_profile_desc");
    callback_t cb;
    cb.add = (void*)TEST_CALLBACK__cb_card;

    _cb_card(NULL, &info, 0, (void*)&cb);

    REQUIRE(TEST_RETURN__cb_card_idx == PA_VALID_INDEX);
    REQUIRE(strcmp(TEST_RETURN__cb_card_name, "test_profile_desc") == 0);
}

uint32_t TEST_RETURN__cb_u_card_idx = PA_INVALID_INDEX;

void TEST_CALLBACK__cb_u_card(void *s, backend_entry_type type, uint32_t idx, backend_data_t data) {
    TEST_RETURN__cb_u_card_idx = idx;
}

TEST_CASE("_cb_u_card", "Should fire 'update' callback with new card data") {
    // We do 0 profiles here to avoid dealing with _do_card,
    // which is tested elsewhere.
    pa_card_info info;
    info.index = PA_VALID_INDEX;
    info.n_profiles = 0;
    callback_t cb;
    cb.self = NULL;
    cb.update = (void*)TEST_CALLBACK__cb_u_card;

    _cb_u_card(NULL, &info, 0, (void*)&cb);

    REQUIRE(TEST_RETURN__cb_u_card_idx == PA_VALID_INDEX);
}

char TEST_RETURN__cb_server_sink[STRING_SIZE];
char TEST_RETURN__cb_server_source[STRING_SIZE];

void TEST_CALLBACK__cb_server(void *s, backend_entry_type type, uint32_t idx, backend_data_t data) {
    strcpy(TEST_RETURN__cb_server_sink, data.defaults->sink);
    strcpy(TEST_RETURN__cb_server_source, data.defaults->source);
}

TEST_CASE("_cb_server", "Should fire 'update' callback with server defaults data") {
    pa_server_info info;
    info.default_sink_name = "sink.1";
    info.default_source_name = "source.1";
    callback_t cb;
    cb.update = (void*)TEST_CALLBACK__cb_server;

    _cb_server(NULL, &info, (void*)&cb);

    REQUIRE(strcmp(TEST_RETURN__cb_server_sink, "sink.1") == 0);
    REQUIRE(strcmp(TEST_RETURN__cb_server_source, "source.1") == 0);
}

int TEST_RETURN__CB_SINGLE_EVENT = 0;

void TEST_CALLBACK__CB_SINGLE_EVENT(void *s, uint32_t idx) {
    TEST_RETURN__CB_SINGLE_EVENT += 1;
}

TEST_CASE("_CB_SINGLE_EVENT", "Should fire appropriate callbacks for events") {
    pa_context *c = NULL;
    int idx = PA_VALID_INDEX;
    callback_t cb;
    cb.remove = (void*)TEST_CALLBACK__CB_SINGLE_EVENT;
    void *userdata = (void*)&cb;
    int t_;
    int t__;

    SECTION("card", "_by_index") {
        t__ = PA_SUBSCRIPTION_EVENT_CARD;

        SECTION("new", "") {
            t_ = PA_SUBSCRIPTION_EVENT_NEW;

            _CB_SINGLE_EVENT(CARD, card, _by_index);

            REQUIRE(output_card_info == PA_VALID_INDEX);
        }

        reset_mock_variables();

        SECTION("change", "") {
            t_ = PA_SUBSCRIPTION_EVENT_CHANGE;

            _CB_SINGLE_EVENT(CARD, card, _by_index);

            REQUIRE(output_card_info == PA_VALID_INDEX);
        }

        SECTION("remove", "") {
            t_ = PA_SUBSCRIPTION_EVENT_REMOVE;

            _CB_SINGLE_EVENT(CARD, card, _by_index);

            REQUIRE(TEST_RETURN__CB_SINGLE_EVENT == 1);
        }
    }

    SECTION("sink", "_by_index") {
        t__ = PA_SUBSCRIPTION_EVENT_SINK;

        SECTION("new", "") {
            t_ = PA_SUBSCRIPTION_EVENT_NEW;

            _CB_SINGLE_EVENT(SINK, sink, _by_index);

            REQUIRE(output_sink_info[0] == PA_VALID_INDEX);
        }

        reset_mock_variables();

        SECTION("change", "") {
            t_ = PA_SUBSCRIPTION_EVENT_CHANGE;

            _CB_SINGLE_EVENT(SINK, sink, _by_index);

            REQUIRE(output_sink_info[0] == PA_VALID_INDEX);
        }

        SECTION("remove", "") {
            t_ = PA_SUBSCRIPTION_EVENT_REMOVE;

            _CB_SINGLE_EVENT(SINK, sink, _by_index);

            REQUIRE(TEST_RETURN__CB_SINGLE_EVENT == 2);
        }
    }

    SECTION("sink input", "") {
        t__ = PA_SUBSCRIPTION_EVENT_SINK_INPUT;

        SECTION("new", "") {
            t_ = PA_SUBSCRIPTION_EVENT_NEW;

            _CB_SINGLE_EVENT(SINK_INPUT, sink_input, );

            REQUIRE(output_sink_input_info[0] == PA_VALID_INDEX);
        }

        reset_mock_variables();

        SECTION("change", "") {
            t_ = PA_SUBSCRIPTION_EVENT_CHANGE;

            _CB_SINGLE_EVENT(SINK_INPUT, sink_input, );

            REQUIRE(output_sink_input_info[0] == PA_VALID_INDEX);
        }

        SECTION("remove", "") {
            t_ = PA_SUBSCRIPTION_EVENT_REMOVE;

            _CB_SINGLE_EVENT(SINK_INPUT, sink_input, );

            REQUIRE(TEST_RETURN__CB_SINGLE_EVENT == 3);
        }
    }

    SECTION("source", "_by_index") {
        t__ = PA_SUBSCRIPTION_EVENT_SOURCE;

        SECTION("new", "") {
            t_ = PA_SUBSCRIPTION_EVENT_NEW;

            _CB_SINGLE_EVENT(SOURCE, source, _by_index);

            REQUIRE(output_source_info[0] == PA_VALID_INDEX);
        }

        reset_mock_variables();

        SECTION("change", "") {
            t_ = PA_SUBSCRIPTION_EVENT_CHANGE;

            _CB_SINGLE_EVENT(SOURCE, source, _by_index);

            REQUIRE(output_source_info[0] == PA_VALID_INDEX);
        }

        SECTION("remove", "") {
            t_ = PA_SUBSCRIPTION_EVENT_REMOVE;

            _CB_SINGLE_EVENT(SOURCE, source, _by_index);

            REQUIRE(TEST_RETURN__CB_SINGLE_EVENT == 4);
        }
    }

    SECTION("source output", "") {
        t__ = PA_SUBSCRIPTION_EVENT_SOURCE_OUTPUT;

        SECTION("new", "") {
            t_ = PA_SUBSCRIPTION_EVENT_NEW;

            _CB_SINGLE_EVENT(SOURCE_OUTPUT, source_output, );

            REQUIRE(output_source_output_info[0] == PA_VALID_INDEX);
        }

        SECTION("change", "") {
            t_ = PA_SUBSCRIPTION_EVENT_CHANGE;

            _CB_SINGLE_EVENT(SOURCE_OUTPUT, source_output, );

            REQUIRE(output_source_output_info[0] == PA_VALID_INDEX);
        }

        SECTION("remove", "") {
            t_ = PA_SUBSCRIPTION_EVENT_REMOVE;

            _CB_SINGLE_EVENT(SOURCE_OUTPUT, source_output, );

            REQUIRE(TEST_RETURN__CB_SINGLE_EVENT == 5);
        }
    }

    reset_mock_variables();
}

TEST_CASE("_do_channels", "Should compose backend_channel_t for given data") {
    // As usual: Use 2 channels, scale by induction.
    pa_cvolume cv;
    cv.channels = 2;
    cv.values[0] = 90;
    cv.values[1] = 120;

    backend_channel_t *result = _do_channels(cv, 2);

    REQUIRE(result != NULL);
    REQUIRE(result[0].maxLevel == PA_VOLUME_UI_MAX);
    REQUIRE(result[0].normLevel == PA_VOLUME_NORM);
    REQUIRE(result[0].isMutable == 1);
    REQUIRE(result[1].maxLevel == PA_VOLUME_UI_MAX);
    REQUIRE(result[1].normLevel == PA_VOLUME_NORM);
    REQUIRE(result[1].isMutable == 1);

    free(result);
}

TEST_CASE("_do_volumes", "Should compose backend_volume_t for given data") {
    // Use 2 channels, scale by induction.
    pa_cvolume cv;
    cv.channels = 2;
    cv.values[0] = 90;
    cv.values[1] = 120;

    SECTION("muted", "") {
        backend_volume_t *result = _do_volumes(cv, 2, 1);

        REQUIRE(result[0].level == 90);
        REQUIRE(result[0].mute == 1);
        REQUIRE(result[1].level == 120);
        REQUIRE(result[1].mute == 1);

        free(result);
    }

    SECTION("not muted", "") {
        backend_volume_t *result = _do_volumes(cv, 2, 0);

        REQUIRE(result[0].level == 90);
        REQUIRE(result[0].mute == 0);
        REQUIRE(result[1].level == 120);
        REQUIRE(result[1].mute == 0);

        free(result);
    }
}

TEST_CASE("_do_card", "Should compose backend_option_t for given card data") {
    // Use 2 profiles, scale by induction.
    pa_card_info info;
    info.index = PA_VALID_INDEX;
    info.n_profiles = 2;
    info.profiles = (pa_card_profile_info*)malloc(2 * sizeof(pa_card_profile_info));
    info.active_profile = (pa_card_profile_info*)malloc(sizeof(pa_card_profile_info));
    strcpy(info.profiles[0].name, "test_p1_name");
    strcpy(info.profiles[0].description, "test_p1_desc");
    strcpy(info.profiles[1].name, "test_p2_name");
    strcpy(info.profiles[1].description, "test_p2_desc");
    strcpy(info.active_profile->name, "test_p2_name");
    strcpy(info.active_profile->description, "test_p2_desc");

    backend_option_t *result = _do_card(&info, 2);

    REQUIRE(result->size == 2);
    REQUIRE(strcmp(result->names[0], "test_p1_name") == 0);
    REQUIRE(strcmp(result->descriptions[0], "test_p1_desc") == 0);
    REQUIRE(strcmp(result->names[1], "test_p2_name") == 0);
    REQUIRE(strcmp(result->descriptions[1], "test_p2_desc") == 0);
    REQUIRE(strcmp(result->active, "test_p2_desc") == 0);

    for(int i = 0; i < result->size; ++i) {
        free(result->names[i]);
        free(result->descriptions[i]);
    }
    free(result->names);
    free(result->descriptions);
    free(result->active);
    free(result);

    free(info.active_profile);
    free(info.profiles);
}

backend_entry_type TEST_RETURN__CB_U_type = CARD;
int TEST_RETURN__CB_U_idx = PA_INVALID_INDEX;

void TEST_CALLBACK__CB_U(void *s, backend_entry_type type, uint32_t idx, void *data) {
    TEST_RETURN__CB_U_type = type;
    TEST_RETURN__CB_U_idx = idx;
}

TEST_CASE("_CB_U", "Should fire 'update' callback for given data") {
    //Using SINK, it scales to other types as well.
    //TODO: More thorough tests.
    pa_cvolume cv;
    cv.channels = 0;
    callback_t cb;
    cb.update = (void*)TEST_CALLBACK__CB_U;
    pa_sink_info *info = (pa_sink_info*)malloc(sizeof(pa_sink_info));
    info->index = PA_VALID_INDEX;
    info->volume = cv;
    info->mute = 0;

    _CB_U(info, SINK, NULL, (void*)&cb);

    REQUIRE(TEST_RETURN__CB_U_type == SINK);
    REQUIRE(TEST_RETURN__CB_U_idx == PA_VALID_INDEX);
}

backend_entry_type TEST_RETURN__CB1_type = CARD;
int TEST_RETURN__CB1_idx = PA_INVALID_INDEX;
char TEST_RETURN__CB1_desc[STRING_SIZE];
char TEST_RETURN__CB1_iname[STRING_SIZE];

void TEST_CALLBACK__CB1(void *s, const char *desc, backend_entry_type type, uint32_t idx, void *data) {
    backend_data_t *d = (backend_data_t*)data;
    TEST_RETURN__CB1_type = type;
    TEST_RETURN__CB1_idx = idx;
    strcpy(TEST_RETURN__CB1_desc, desc);
    strcpy(TEST_RETURN__CB1_iname, d->internalName);
}

TEST_CASE("_CB1", "Should fire 'add' callback for given data") {
    //Using SINK, it scales to other types as well.
    pa_cvolume cv;
    cv.channels = 0;
    callback_t cb;
    cb.add = (void*)TEST_CALLBACK__CB1;
    pa_sink_info *info = (pa_sink_info*)malloc(sizeof(pa_sink_info));
    info->index = PA_VALID_INDEX;
    info->volume = cv;
    info->mute = 1;
    strcpy(info->name, "test_iname");
    strcpy(info->description, "test_desc");

    _CB1(info, SINK, NULL, (void*)&cb);

    REQUIRE(TEST_RETURN__CB1_type == SINK);
    REQUIRE(TEST_RETURN__CB1_idx == PA_VALID_INDEX);
    REQUIRE(strcmp(TEST_RETURN__CB1_desc, "test_desc") == 0);
    REQUIRE(strcmp(TEST_RETURN__CB1_iname, "test_iname") == 0);
}


// Other details:
// 1: For _cb_sink/_cb_u_sink/_cb_source/_cb_u_source, see _CB_DEVICE.
// 2: For _cb_s_sink/_cb_s_sink_input/_cb_s_source/_cb_s_source_output, see _CB_SET_VOLUME.
// 3: For _cb_sink_input/_cb_source_output, see _CB_STREAM.
// 4: For _cb_u_sink_input/_cb_u_source_output, see _cb_u.
// 5: Testing _do_option_free does not make much sense.
