// This is a part of pacmixer @ http://github.com/KenjiTakahashi/pacmixer
// Karol "Kenji Takahashi" Woźniak © 2013
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.


#import "../src/middleware.h"
#import "mock_variables.h"


TEST_CASE("Middleware", "") {
    Middleware *middleware = [[Middleware alloc] init];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity: 0];

    SECTION("initContext", "Should fire a 'backendAppeared' notification") {
        s_instance = 1;
        s_state = PA_CONTEXT_READY;
        [center addObserver: results
                   selector: @selector(addObject:)
                       name: @"backendAppeared"
                     object: middleware];

        [middleware initContext];

        REQUIRE([results count] == 1);
    }

    SECTION("addBlock", "Should create and return a block for given data") {
        //Using SINK type, it scales to other as well.
        id block = [middleware addBlockWithId: PA_VALID_INDEX
                                     andIndex: 1
                                      andType: SINK];

        REQUIRE(block != NULL);
        REQUIRE([block isKindOfClass: [Block class]]);
    }

    [center removeObserver: results];

    [results release];
    [middleware release];
}
