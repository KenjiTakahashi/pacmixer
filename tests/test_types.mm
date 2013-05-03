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


#import "../src/types.h"


TEST_CASE("channel_t", "") {
    SECTION("mutable", "") {
        NSNumber *max = [NSNumber numberWithInt: 120];
        NSNumber *norm = [NSNumber numberWithInt: 90];

        channel_t *channel_i = [[channel_t alloc] initWithMaxLevel: 120
                                                      andNormLevel: 90
                                                        andMutable: 1];

        REQUIRE([[channel_i maxLevel] isEqualToNumber: max]);
        REQUIRE([[channel_i normLevel] isEqualToNumber: norm]);
        REQUIRE([channel_i mutable] == YES);

        [channel_i release];
    }

    SECTION("not mutable", "") {
        NSNumber *max = [NSNumber numberWithInt: 90];
        NSNumber *norm = [NSNumber numberWithInt: 50];

        channel_t *channel_i = [[channel_t alloc] initWithMaxLevel: 90
                                                      andNormLevel: 50
                                                        andMutable: 0];

        REQUIRE([[channel_i maxLevel] isEqualToNumber: max]);
        REQUIRE([[channel_i normLevel] isEqualToNumber: norm]);
        REQUIRE([channel_i mutable] == NO);

        [channel_i release];
    }
}
