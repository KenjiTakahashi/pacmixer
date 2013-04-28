/*
 This is a part of pacmixer @ http://github.com/KenjiTakahashi/pacmixer
 Karol "Kenji Takahashi" Woźniak © 2013

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


extern "C" {
#include "../src/backend.h"
#include "mock_variables.h"
}


TEST_CASE("backend_new/connect", "Should successfully return PA context") {
    s_instance = 1;
    state_callback_t *sc = (state_callback_t*)malloc(sizeof(state_callback_t));
    context_t *e = (context_t*)malloc(sizeof(context_t));
    e->loop = &s_instance;
    e->state = PA_CONTEXT_UNCONNECTED;
    e->context = &s_context;
    context_t *r = backend_new(sc);

    REQUIRE(r->loop == e->loop);
    REQUIRE(r->state == e->state);
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
        backend_volume_set(c, SINK, 1, 2, 10);

        REQUIRE(output_sink_info[0] == 1);
        REQUIRE(output_sink_info[1] == 2);
        REQUIRE(output_sink_info[2] == 10);
    }

    SECTION("sink input", "") {
        backend_volume_set(c, SINK_INPUT, 1, 2, 10);

        REQUIRE(output_sink_input_info[0] == 1);
        REQUIRE(output_sink_input_info[1] == 2);
        REQUIRE(output_sink_input_info[2] == 10);
    }

    SECTION("source", "") {
        backend_volume_set(c, SOURCE, 1, 2, 10);

        REQUIRE(output_source_info[0] == 1);
        REQUIRE(output_source_info[1] == 2);
        REQUIRE(output_source_info[2] == 10);
    }

    SECTION("source output", "") {
        backend_volume_set(c, SOURCE_OUTPUT, 1, 2, 10);

        REQUIRE(output_source_output_info[0] == 1);
        REQUIRE(output_source_output_info[1] == 2);
        REQUIRE(output_source_output_info[2] == 10);
    }

    reset_mock_variables();

    SECTION("other", "Should not do anything") {
        backend_volume_set(c, CARD, 1, 2, 10);

        REQUIRE(output_sink_info[0] == 0);
        REQUIRE(output_sink_info[1] == 0);
        REQUIRE(output_sink_info[2] == 0);
        REQUIRE(output_sink_input_info[0] == 0);
        REQUIRE(output_sink_input_info[1] == 0);
        REQUIRE(output_sink_input_info[2] == 0);
        REQUIRE(output_source_info[0] == 0);
        REQUIRE(output_source_info[1] == 0);
        REQUIRE(output_source_info[2] == 0);
        REQUIRE(output_source_output_info[0] == 0);
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
        backend_volume_setall(c, SINK, 0, e, 2);

        REQUIRE(output_sink_volume[0] == 10);
        REQUIRE(output_sink_volume[1] == 15);
    }

    SECTION("sink input", "") {
        backend_volume_setall(c, SINK_INPUT, 0, e, 2);

        REQUIRE(output_sink_input_volume[0] == 10);
        REQUIRE(output_sink_input_volume[1] == 15);
    }

    SECTION("source", "") {
        backend_volume_setall(c, SOURCE, 0, e, 2);

        REQUIRE(output_source_volume[0] == 10);
        REQUIRE(output_source_volume[1] == 15);
    }

    SECTION("source output", "") {
        backend_volume_setall(c, SOURCE_OUTPUT, 0, e, 2);

        REQUIRE(output_source_output_volume[0] == 10);
        REQUIRE(output_source_output_volume[1] == 15);
    }

    reset_mock_variables();

    SECTION("other", "Should not do anything") {
        backend_volume_setall(c, CARD, 0, e, 2);

        REQUIRE(output_sink_volume[0] == 0);
        REQUIRE(output_sink_volume[1] == 0);
        REQUIRE(output_sink_input_volume[0] == 0);
        REQUIRE(output_sink_input_volume[1] == 0);
        REQUIRE(output_source_volume[0] == 0);
        REQUIRE(output_source_volume[1] == 0);
        REQUIRE(output_source_output_volume[0] == 0);
        REQUIRE(output_source_output_volume[1] == 0);
    }

    free(c);
}

TEST_CASE("backend_mute_set", "Should set mute state for control") {
    context_t *c = (context_t*)malloc(sizeof(context_t));

    SECTION("sink", "") {
        backend_mute_set(c, SINK, 1, 1);

        REQUIRE(output_sink_mute[0] == 1);
        REQUIRE(output_sink_mute[1] == 1);
    }

    SECTION("sink input", "") {
        backend_mute_set(c, SINK_INPUT, 1, 1);

        REQUIRE(output_sink_input_mute[0] == 1);
        REQUIRE(output_sink_input_mute[1] == 1);
    }

    SECTION("source", "") {
        backend_mute_set(c, SOURCE, 1, 1);

        REQUIRE(output_source_mute[0] == 1);
        REQUIRE(output_source_mute[1] == 1);
    }

    SECTION("source output", "") {
        backend_mute_set(c, SOURCE_OUTPUT, 1, 1);

        REQUIRE(output_source_output_mute[0] == 1);
        REQUIRE(output_source_output_mute[1] == 1);
    }

    reset_mock_variables();

    SECTION("other", "Should not do anything") {
        backend_mute_set(c, CARD, 1, 1);

        REQUIRE(output_sink_mute[0] == 0);
        REQUIRE(output_sink_mute[1] == 0);
        REQUIRE(output_sink_input_mute[0] == 0);
        REQUIRE(output_sink_input_mute[1] == 0);
        REQUIRE(output_source_mute[0] == 0);
        REQUIRE(output_source_mute[1] == 0);
        REQUIRE(output_source_output_mute[0] == 0);
        REQUIRE(output_source_output_mute[1] == 0);
    }

    free(c);
}
