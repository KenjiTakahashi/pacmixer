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


extern "C" {
#import "../src/middleware.h"
}
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
        //Using SINK type, it scales to other types as well.
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

TEST_CASE("Block", "") {
    //Using SINK, it scales to other types as well.
    context_t c;
    Block *block = [[Block alloc] initWithContext: &c
                                            andId: PA_VALID_INDEX
                                         andIndex: 2
                                          andType: SINK];

    SECTION("setVolume", "Should set volume for specific channel") {
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt: 70], @"volume", nil];
        NSNotification *n = [NSNotification notificationWithName: @"N"
                                                          object: nil
                                                        userInfo: info];

        [block setVolume: n];

        REQUIRE(output_sink_info[0] == PA_VALID_INDEX);
        REQUIRE(output_sink_info[1] == 2);
        REQUIRE(output_sink_info[2] == 70);
    }

    SECTION("setVolumes", "Should set volume for all channels") {
        NSArray *volumes = [NSArray arrayWithObjects:
            [NSNumber numberWithInt: 70], [NSNumber numberWithInt: 45], nil];
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
            volumes, @"volume", nil];
        NSNotification *n = [NSNotification notificationWithName: @"N"
                                                          object: nil
                                                        userInfo: info];

        [block setVolumes: n];

        REQUIRE(output_sink_volume[0] == PA_VALID_INDEX);
        REQUIRE(output_sink_volume[1] == 70);
        REQUIRE(output_sink_volume[2] == 45);
    }

    SECTION("setMute", "Should set mute state for given control") {
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool: YES], @"mute", nil];
        NSNotification *n = [NSNotification notificationWithName: @"N"
                                                          object: nil
                                                        userInfo: info];

        [block setMute: n];

        REQUIRE(output_sink_mute[0] == PA_VALID_INDEX);
        REQUIRE(output_sink_mute[1] == 1);
    }

    char **keys = (char**)malloc(2 * sizeof(char*));
    keys[0] = (char*)malloc(STRING_SIZE * sizeof(char));
    keys[1] = (char*)malloc(STRING_SIZE * sizeof(char));
    strcpy(keys[0], "test_name1");
    strcpy(keys[1], "test_name2");
    char **values = (char**)malloc(2 * sizeof(char*));
    values[0] = (char*)malloc(STRING_SIZE * sizeof(char));
    values[1] = (char*)malloc(STRING_SIZE * sizeof(char));
    strcpy(values[0], "test_desc1");
    strcpy(values[1], "test_desc2");

    [block addDataByCArray: 2
                withValues: values
                   andKeys: keys];

    SECTION("setCardActiveProfile", "Should set active profile for a card") {
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
            @"test_name2", @"option", nil];
        NSNotification *n = [NSNotification notificationWithName: @"N"
                                                          object: nil
                                                        userInfo: info];

        [block setCardActiveProfile: n];

        REQUIRE(output_card_profile.index == PA_VALID_INDEX);
        REQUIRE(strcmp(output_card_profile.active, "test_desc2") == 0);
    }

    SECTION("setActivePort", "Should set active port for given control") {
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
            @"test_name1", @"option", nil];
        NSNotification *n = [NSNotification notificationWithName: @"N"
                                                          object: nil
                                                        userInfo: info];

        [block setActivePort: n];

        REQUIRE(output_sink_port.index == PA_VALID_INDEX);
        REQUIRE(strcmp(output_sink_port.active, "test_desc1") == 0);
    }

    free(values[1]);
    free(values[0]);
    free(values);
    free(keys[1]);
    free(keys[0]);
    free(keys);
    [block release];
}

TEST_CASE("callback_state_func", "Should fire 'backendGone' notification") {
    Middleware *middleware = [[Middleware alloc] init];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity: 0];
    [center addObserver: results
               selector: @selector(addObject:)
                   name: @"backendGone"
                 object: middleware];

    callback_state_func((void*)middleware);

    REQUIRE([results count] == 1);

    [middleware release];
}

TEST_CASE("callback_remove_func", "Should fire 'controlDisappeared' notification") {
    //It passes disappearing control internal index along with notification.
    Middleware *middleware = [[Middleware alloc] init];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity: 0];
    [center addObserver: results
               selector: @selector(addObject:)
                   name: @"controlDisappeared"
                 object: middleware];

    callback_remove_func((void*)middleware, PA_VALID_INDEX);

    REQUIRE([results count] == 1);
    NSNumber *idx = [[[results objectAtIndex: 0] userInfo] objectForKey: @"id"];
    REQUIRE([idx isEqualToNumber: [NSNumber numberWithInt: PA_VALID_INDEX]]);

    [middleware release];
}
