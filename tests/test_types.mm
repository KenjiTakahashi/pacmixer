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
#import "../src/types.h"


#define STRING_SIZE 32

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

TEST_CASE("volume_t", "") {
    SECTION("mute", "") {
        NSNumber *lvl = [NSNumber numberWithInt: 90];

        volume_t *volume_i = [[volume_t alloc] initWithLevel: 90
                                                     andMute: 1];

        REQUIRE([[volume_i level] isEqualToNumber: lvl]);
        REQUIRE([volume_i mute] == YES);

        [volume_i release];
    }

    SECTION("do not mute", "") {
        NSNumber *lvl = [NSNumber numberWithInt: 50];

        volume_t *volume_i = [[volume_t alloc] initWithLevel: 50
                                                     andMute: 0];

        REQUIRE([[volume_i level] isEqualToNumber: lvl]);
        REQUIRE([volume_i mute] == NO);

        [volume_i release];
    }
}

TEST_CASE("option_t", "") {
    //Use 2 options, scale by induction.
    NSString *opt1 = [NSString stringWithUTF8String: "test_desc1"];
    NSString *opt2 = [NSString stringWithUTF8String: "test_desc2"];
    NSString *active = [NSString stringWithUTF8String: "test_desc3"];

    char **options = (char**)malloc(2 * sizeof(char*));
    options[0] = (char*)malloc(STRING_SIZE * sizeof(char));
    options[1] = (char*)malloc(STRING_SIZE * sizeof(char));
    strcpy(options[0], "test_desc1");
    strcpy(options[1], "test_desc2");

    option_t *option_i = [[option_t alloc] initWithOptions: options
                                               andNOptions: 2
                                                 andActive: "test_desc3"];
    NSArray *result_options = [option_i options];

    REQUIRE([result_options count] == 2);
    REQUIRE([[result_options objectAtIndex: 0] isEqualToString: opt1]);
    REQUIRE([[result_options objectAtIndex: 1] isEqualToString: opt2]);
    REQUIRE([[option_i active] isEqualToString: active]);

    [option_i release];

    free(options[1]);
    free(options[0]);
    free(options);
}
