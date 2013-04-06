/*
 This is a part of pacmixer @ http://gtihub.com/KenjiTakahashi/pacmixer
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
