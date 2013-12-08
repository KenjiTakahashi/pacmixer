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

    callback_remove_func((void*)middleware, PA_VALID_INDEX, SINK);

    REQUIRE([results count] == 1);
    NSString *idx = [[[results objectAtIndex: 0] userInfo] objectForKey: @"id"];
    NSString *res = [NSString stringWithFormat: @"%d_%d", PA_VALID_INDEX, SINK];
    REQUIRE([idx isEqualToString: res]);

    [middleware release];
}

backend_data_t TEST_PREPARE_backend_data_t_part1() {
    backend_data_t data;
    //Those values are not really realistic, but work for testing purposes.
    data.channels = (backend_channel_t*)malloc(2 * sizeof(backend_channel_t));
    data.channels[0].maxLevel = 150;
    data.channels[0].normLevel = 120;
    data.channels[0].isMutable = 1;
    data.channels[1].maxLevel = 130;
    data.channels[1].normLevel = 90;
    data.channels[1].isMutable = 0;
    data.volumes = (backend_volume_t*)malloc(2 * sizeof(backend_volume_t));
    data.volumes[0].level = 120;
    data.volumes[0].mute = 0;
    data.volumes[1].level = 90;
    data.volumes[1].mute = 1;
    data.channels_num = 2;
    data.option = NULL;
    data.internalName = (char*)"iname";
    return data;
}

void TEST_PREPARE_backend_data_t_part2(backend_data_t *data) {
    //Crapload of data to prepare :C.
    data->option = (backend_option_t*)malloc(sizeof(backend_option_t));
    data->option->names = (char**)malloc(2 * sizeof(char*));
    data->option->names[0] = (char*)malloc(STRING_SIZE * sizeof(char));
    data->option->names[1] = (char*)malloc(STRING_SIZE * sizeof(char));
    data->option->descriptions = (char**)malloc(2 * sizeof(char*));
    data->option->descriptions[0] = (char*)malloc(STRING_SIZE * sizeof(char));
    data->option->descriptions[1] = (char*)malloc(STRING_SIZE * sizeof(char));
    data->option->active = (char*)malloc(STRING_SIZE * sizeof(char));
    strcpy(data->option->names[0], "test_name1");
    strcpy(data->option->names[1], "test_name2");
    strcpy(data->option->descriptions[0], "test_desc1");
    strcpy(data->option->descriptions[1], "test_desc2");
    strcpy(data->option->active, "test_desc2");
    data->option->size = 2;
}

void TEST_PREPARE_backend_data_t_free(backend_data_t data) {
    free(data.option->active);
    free(data.option->descriptions[1]);
    free(data.option->descriptions[0]);
    free(data.option->descriptions);
    free(data.option->names[1]);
    free(data.option->names[0]);
    free(data.option->names);
    free(data.option);
    free(data.volumes);
    free(data.channels);
}

TEST_CASE("callback_update_func", "Should fire appropriate update notification") {
    Middleware *middleware = [[Middleware alloc] init];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity: 0];

    backend_data_t data = TEST_PREPARE_backend_data_t_part1();

    SECTION("control without options", "controlChanged{idx}_{type}, !ports") {
        [center addObserver: results
                   selector: @selector(addObject:)
                       name: [NSString stringWithFormat:
                              @"controlChanged%d_%d", PA_VALID_INDEX, SINK] 
                     object: middleware];

        callback_update_func(middleware, SINK, PA_VALID_INDEX, &data);

        REQUIRE([results count] == 1);
        NSMutableArray *p = [[[results objectAtIndex: 0] userInfo] objectForKey: @"volumes"];
        REQUIRE([p count] == 2);
        volume_t *v1 = [p objectAtIndex: 0];
        volume_t *v2 = [p objectAtIndex: 1];
        REQUIRE([[v1 level] isEqualToNumber: [NSNumber numberWithInt: 120]]);
        REQUIRE([[v2 level] isEqualToNumber: [NSNumber numberWithInt: 90]]);
        REQUIRE([v1 mute] == NO);
        REQUIRE([v2 mute] == YES);
    }

    TEST_PREPARE_backend_data_t_part2(&data);

    [results removeAllObjects];

    SECTION("control with options", "controlChanged{idx}_{type}, ports") {
        //We'll check only options here.
        [center addObserver: results
                   selector: @selector(addObject:)
                       name: [NSString stringWithFormat:
                              @"controlChanged%d_%d", PA_VALID_INDEX, SINK] 
                     object: middleware];

        callback_update_func(middleware, SINK, PA_VALID_INDEX, &data);

        REQUIRE([results count] == 1);
        option_t *p = [[[results objectAtIndex: 0] userInfo] objectForKey: @"ports"];
        REQUIRE([[[p options] objectAtIndex: 0] isEqualToString: @"test_desc1"]);
        REQUIRE([[[p options] objectAtIndex: 1] isEqualToString: @"test_desc2"]);
        REQUIRE([[p active] isEqualToString: @"test_desc2"]);
    }

    [results removeAllObjects];

    SECTION("card", "cardProfileChanged{internal index}_{CARD}") {
        [center addObserver: results
                   selector: @selector(addObject:)
                       name: [NSString stringWithFormat:
                              @"cardProfileChanged%d_%d",
                              PA_VALID_INDEX, CARD]
                     object: middleware];

        callback_update_func(middleware, CARD, PA_VALID_INDEX, &data);

        REQUIRE([results count] == 1);
        option_t *p = [[[results objectAtIndex: 0] userInfo] objectForKey: @"profile"];
        REQUIRE([[[p options] objectAtIndex: 0] isEqualToString: @"test_desc1"]);
        REQUIRE([[[p options] objectAtIndex: 1] isEqualToString: @"test_desc2"]);
        REQUIRE([[p active] isEqualToString: @"test_desc2"]);
    }

    [center removeObserver: results];

    TEST_PREPARE_backend_data_t_free(data);

    [results release];
    [middleware release];
}

TEST_CASE("callback_add_func", "Should fire appropriate add notification") {
    s_instance = 1;
    s_state = PA_CONTEXT_READY;
    Middleware *middleware = [[Middleware alloc] init];
    [middleware initContext];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity: 0];

    backend_data_t data = TEST_PREPARE_backend_data_t_part1();

    reset_mock_variables();

    SECTION("control without options", "controlAppeared, !ports") {
        //Also connects "volumeChanged{idx}_{type}_{index}" and
        //volumeChanged{idx}_{type}" and "muteChanged{idx}_{type}" signals.
        [center addObserver: results
                   selector: @selector(addObject:)
                       name: @"controlAppeared"
                     object: middleware];

        callback_add_func(middleware, "test_c1", SINK, PA_VALID_INDEX, &data);

        REQUIRE([results count] == 1);
        NSDictionary *p = [[results objectAtIndex: 0] userInfo];
        NSArray *channels = [p objectForKey: @"channels"];
        NSArray *volumes = [p objectForKey: @"volumes"];
        REQUIRE([[p objectForKey: @"name"] isEqualToString: @"test_c1"]);
        REQUIRE([[p objectForKey: @"id"] isEqualToNumber: [NSNumber numberWithInt: PA_VALID_INDEX]]);
        REQUIRE([[p objectForKey: @"type"] isEqualToNumber: [NSNumber numberWithInt: SINK]]);
        channel_t *c1 = [channels objectAtIndex: 0];
        channel_t *c2 = [channels objectAtIndex: 1];
        REQUIRE([[c1 maxLevel] isEqualToNumber: [NSNumber numberWithInt: 150]]);
        REQUIRE([[c1 normLevel] isEqualToNumber: [NSNumber numberWithInt: 120]]);
        REQUIRE([c1 mutable] == YES);
        REQUIRE([[c2 maxLevel] isEqualToNumber: [NSNumber numberWithInt: 130]]);
        REQUIRE([[c2 normLevel] isEqualToNumber: [NSNumber numberWithInt: 90]]);
        REQUIRE([c2 mutable] == NO);
        volume_t *v1 = [volumes objectAtIndex: 0];
        volume_t *v2 = [volumes objectAtIndex: 1];
        REQUIRE([[v1 level] isEqualToNumber: [NSNumber numberWithInt: 120]]);
        REQUIRE([v1 mute] == NO);
        REQUIRE([[v2 level] isEqualToNumber: [NSNumber numberWithInt: 90]]);
        REQUIRE([v2 mute] == YES);
        REQUIRE([p objectForKey: @"ports"] == NULL);

        SECTION("volumeChanged", "") {
            NSString *name = [NSString stringWithFormat:
                @"volumeChanged%d_%d_%d", PA_VALID_INDEX, SINK, 1];
            NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                [NSNumber numberWithInt: 90], @"volume", nil];
            [center postNotificationName: name
                                  object: nil
                                userInfo: info];

            REQUIRE(output_sink_info[0] == PA_VALID_INDEX);
            REQUIRE(output_sink_info[1] == 1);
            REQUIRE(output_sink_info[2] == 90);
        }

        SECTION("volumeChanged all", "") {
            NSString *name = [NSString stringWithFormat:
                @"volumeChanged%d_%d", PA_VALID_INDEX, SINK];
            NSArray *v = [NSArray arrayWithObjects:
                [NSNumber numberWithInt: 120],
                [NSNumber numberWithInt: 90], nil];
            NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                v, @"volume", nil];
            [center postNotificationName: name
                                  object: nil
                                userInfo: info];

            REQUIRE(output_sink_volume[0] == PA_VALID_INDEX);
            REQUIRE(output_sink_volume[1] == 120);
            REQUIRE(output_sink_volume[2] == 90);
        }

        SECTION("muteChanged", "") {
            NSString *name = [NSString stringWithFormat:
                @"muteChanged%d_%d", PA_VALID_INDEX, SINK];
            NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                [NSNumber numberWithBool: YES], @"mute", nil];
            [center postNotificationName: name
                                  object: nil
                                userInfo: info];

            REQUIRE(output_sink_mute[0] == PA_VALID_INDEX);
            REQUIRE(output_sink_mute[1] == 1);
        }
    }

    TEST_PREPARE_backend_data_t_part2(&data);

    [results removeAllObjects];

    SECTION("control with options", "controlAppeared, ports") {
        //Also connects "activeOptionChanged{idx}_{type}" signal.
        [center addObserver: results
                   selector: @selector(addObject:)
                       name: @"controlAppeared"
                     object: middleware];

        callback_add_func(middleware, "test_c1", SINK, PA_VALID_INDEX, &data);

        REQUIRE([results count] == 1);
        option_t *p = [[[results objectAtIndex: 0] userInfo] objectForKey: @"ports"];
        REQUIRE([[[p options] objectAtIndex: 0] isEqualToString: @"test_desc1"]);
        REQUIRE([[[p options] objectAtIndex: 1] isEqualToString: @"test_desc2"]);
        REQUIRE([[p active] isEqualToString: @"test_desc2"]);

        SECTION("activeOptionChanged", "") {
            NSString *name = [NSString stringWithFormat:
                @"activeOptionChanged%d_%d", PA_VALID_INDEX, SINK];
            NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                @"test_desc2", @"option", nil];
            [center postNotificationName: name
                                  object: nil
                                userInfo: info];

            REQUIRE(output_sink_port.index == PA_VALID_INDEX);
            REQUIRE(strcmp(output_sink_port.active, "test_name2") == 0);
        }
    }

    [results removeAllObjects];

    SECTION("card", "cardAppeared") {
        //Also connects "activeOptionChanged{idx}_{CARD}" signal.
        [center addObserver: results
                   selector: @selector(addObject:)
                       name: @"cardAppeared"
                     object: middleware];

        callback_add_func(middleware, "test_c1", CARD, PA_VALID_INDEX, &data);

        REQUIRE([results count] == 1);
        option_t *p = [[[results objectAtIndex: 0] userInfo] objectForKey: @"profile"];
        REQUIRE([[[p options] objectAtIndex: 0] isEqualToString: @"test_desc1"]);
        REQUIRE([[[p options] objectAtIndex: 1] isEqualToString: @"test_desc2"]);
        REQUIRE([[p active] isEqualToString: @"test_desc2"]);

        SECTION("activeOptionChanged", "") {
            NSString *name = [NSString stringWithFormat:
                @"activeOptionChanged%d_%d", PA_VALID_INDEX, CARD];
            NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                @"test_desc1", @"option", nil];
            [center postNotificationName: name
                                  object: nil
                                userInfo: info];

            REQUIRE(output_card_profile.index == PA_VALID_INDEX);
            REQUIRE(strcmp(output_card_profile.active, "test_name1") == 0);
        }
    }

    [center removeObserver: results];

    TEST_PREPARE_backend_data_t_free(data);

    [results release];
    [middleware release];
}
