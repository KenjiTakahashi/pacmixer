// This is a part of pacmixer @ http://github.com/KenjiTakahashi/pacmixer
// Karol "Kenji Takahashi" Woźniak © 2012
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


#import "middleware.h"


void callback_func(void *self_, const char *name, const backend_channel_t *channels, uint8_t chnum) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    Middleware *self = self_;
    NSMutableArray *ch = [NSMutableArray arrayWithCapacity: chnum];
    for(int i = 0; i < chnum; ++i) {
        NSNumber *lvl = [NSNumber numberWithInt: channels[i].maxLevel];
        NSNumber *nlvl = [NSNumber numberWithInt: channels[i].normLevel];
        BOOL mut = channels[i].mutable == 1 ? YES : NO;
        [ch addObject: [[channel_t alloc] initWithMaxLevel: lvl
                                              andNormLevel: nlvl
                                                andMutable: mut]];
    }
    NSDictionary *s = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSString stringWithUTF8String: name], @"name",
        ch, @"channels",  nil];
    NSString *nname = [NSString stringWithString: @"controlAppeared"];
    [[NSNotificationCenter defaultCenter] postNotificationName: nname
                                                        object: self
                                                      userInfo: s];
    [pool drain];
}

@implementation Middleware
-(Middleware*) init {
    self = [super init];
    context = backend_new();
    callback = malloc(sizeof(callback_t));
    callback->callback = callback_func;
    callback->self = self;
    backend_init(context, callback);
    return self;
}

-(void) dealloc {
    backend_destroy(context);
    free(callback);
    [super dealloc];
}

-(void) run {
    NSNumber *lvl = [NSNumber numberWithInt: 130];
    NSArray *ch1 = [NSArray arrayWithObjects:
        [[channel_t alloc] initWithMaxLevel: lvl andMutable: YES],
        [[channel_t alloc] initWithMaxLevel: lvl andMutable: YES],
        nil];
    NSDictionary *s1 = [NSDictionary dictionaryWithObjectsAndKeys:
        @"test1", @"name", ch1, @"channels", nil];
    NSString *name = [NSString stringWithString: @"controlAppeared"];
    [[NSNotificationCenter defaultCenter] postNotificationName: name
                                                        object: self
                                                      userInfo: s1];
    NSArray *ch2 = [NSArray arrayWithObjects:
        [[channel_t alloc] initWithMaxLevel: lvl
                                 andMutable: NO],
        nil];
    NSDictionary *s2 = [NSDictionary dictionaryWithObjectsAndKeys:
        @"test2", @"name", ch2, @"channels", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName: name
                                                        object: self
                                                      userInfo: s2];
    NSArray *ch3 = [NSArray arrayWithObjects:
        [[channel_t alloc] initWithMaxLevel: nil
                                 andMutable: YES],
        nil];
    NSDictionary *s3 = [NSDictionary dictionaryWithObjectsAndKeys:
        @"test3", @"name", ch3, @"channels", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName: name
                                                        object: self
                                                      userInfo: s3];
    NSArray *ch4 = [NSArray arrayWithObjects:
        [[channel_t alloc] initWithMaxLevel: lvl
                                 andMutable: YES],
        [[channel_t alloc] initWithMaxLevel: nil
                                 andMutable: YES],
        nil];
    NSDictionary *s4 = [NSDictionary dictionaryWithObjectsAndKeys:
        @"test4", @"name", ch4, @"channels", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName: name
                                                        object: self
                                                      userInfo: s4];
    NSArray *ch5 = [NSArray arrayWithObjects:
        [[channel_t alloc] initWithMaxLevel: lvl
                                 andMutable: NO],
        [[channel_t alloc] initWithMaxLevel: lvl
                                 andMutable: YES],
        nil];
    NSDictionary *s5 = [NSDictionary dictionaryWithObjectsAndKeys:
        @"test5", @"name", ch5, @"channels", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName: name
                                                        object: self
                                                      userInfo: s5];
    NSArray *ch6 = [NSArray arrayWithObjects:
        [[channel_t alloc] initWithMaxLevel: lvl
                                 andMutable: YES],
        [[channel_t alloc] initWithMaxLevel: lvl
                                 andMutable: YES],
        [[channel_t alloc] initWithMaxLevel: lvl
                                 andMutable: YES],
        [[channel_t alloc] initWithMaxLevel: lvl
                                 andMutable: YES],
        nil];
    NSDictionary *s6 = [NSDictionary dictionaryWithObjectsAndKeys:
        @"test6", @"name", ch6, @"channels", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName: name
                                                        object: self
                                                      userInfo: s6];
    NSArray *opt1 = [NSArray arrayWithObjects:
        @"op1", @"op2", nil];
    NSDictionary *s7 = [NSDictionary dictionaryWithObjectsAndKeys:
        @"opttest1", @"name", opt1, @"options", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName: name
                                                        object: self
                                                      userInfo: s7];
    NSArray *opt2 = [NSArray arrayWithObjects:
        @"op3", @"op4", @"opt5", nil];
    NSDictionary *s8 = [NSDictionary dictionaryWithObjectsAndKeys:
        @"longopt_test", @"name", opt2, @"options", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName: name
                                                        object: self
                                                      userInfo: s8];
    NSString *name2 = [NSString stringWithString: @"controlDisappeared"];
    NSDictionary *s9 = [NSDictionary dictionaryWithObjectsAndKeys:
        @"test4", @"name", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName: name2
                                                        object: self
                                                      userInfo: s9];
}
@end
