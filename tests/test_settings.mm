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


#import "catch.hpp"
#import "../src/settings.h"
#import "mock_variables.h"


TEST_CASE("Values", "") {
    Values *v = [[Values alloc] initWithType: [NSString class]
                                   andValues: @"testv1", @"testv2", nil];

    SECTION("count", "Should return correct count of values") {
        REQUIRE([v count] == 2);
    }

    SECTION("objectAtIndex", "Should return correct object for given index") {
        REQUIRE([[v objectAtIndex: 0] isEqualToString: @"testv1"]);
        REQUIRE([[v objectAtIndex: 1] isEqualToString: @"testv2"]);
    }

    SECTION("type", "Should return correct type") {
        REQUIRE([v type] == [NSString class]);
    }

    SECTION("values", "Should return array with all values") {
        NSArray *a = [v values];
        NSArray *r = [NSArray arrayWithObjects: @"testv1", @"testv2", nil];

        REQUIRE([a isEqualToArray: r]);
    }

    [v release];
}
