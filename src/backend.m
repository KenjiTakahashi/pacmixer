#import "backend.h"

@implementation Backend
-(void) run {
    // TODO: FIXME: create channel objects here, or make it more general?
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
