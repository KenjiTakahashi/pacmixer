#import "frontend.h"


int main(int argc, char const *argv[]) {
    TUI *tui = [[TUI alloc] init];
    Widget *w1 = [tui addWidgetWithName: @"test1"];
    NSNumber *lvl = [NSNumber numberWithInt: 130];
    channel_t *ch1w1 = [[channel_t alloc] initWithMaxLevel: lvl
                                                andMutable: YES];
    channel_t *ch2w1 = [[channel_t alloc] initWithMaxLevel: lvl
                                                andMutable: YES];
    Channels * ch1 = [w1 addChannels:
        [NSArray arrayWithObjects: ch1w1, ch2w1, nil]
    ];
    Widget *w2 = [tui addWidgetWithName: @"test2"];
    channel_t *ch1w2 = [[channel_t alloc] initWithMaxLevel: lvl
                                                andMutable: NO];
    Channels *ch2 = [w2 addChannels: [NSArray arrayWithObjects: ch1w2, nil]];
    Widget *w3 = [tui addWidgetWithName: @"test3"];
    channel_t *ch1w3 = [[channel_t alloc] initWithMaxLevel: nil
                                                andMutable: YES];
    Channels *ch3 = [w3 addChannels: [NSArray arrayWithObjects: ch1w3, nil]];
    Widget *w4 = [tui addWidgetWithName: @"test4"];
    channel_t *ch1w4 = [[channel_t alloc] initWithMaxLevel: lvl
                                                andMutable: YES];
    channel_t *ch2w4 = [[channel_t alloc] initWithMaxLevel: nil
                                                andMutable: YES];
    Channels *ch4 = [w4 addChannels:
        [NSArray arrayWithObjects: ch1w4, ch2w4, nil]
    ];
    Widget *w5 = [tui addWidgetWithName: @"test5"];
    channel_t *ch1w5 = [[channel_t alloc] initWithMaxLevel: lvl
                                                andMutable: NO];
    channel_t *ch2w5 = [[channel_t alloc] initWithMaxLevel: lvl
                                                andMutable: YES];
    Channels *ch5 = [w5 addChannels:
        [NSArray arrayWithObjects: ch1w5, ch2w5, nil]
    ];
    [ch5 setLevel: 110];
    Widget *w6 = [tui addWidgetWithName: @"test6"];
    channel_t *ch1w6 = [[channel_t alloc] initWithMaxLevel: lvl
                                                andMutable: YES];
    channel_t *ch2w6 = [[channel_t alloc] initWithMaxLevel: lvl
                                                andMutable: YES];
    channel_t *ch3w6 = [[channel_t alloc] initWithMaxLevel: lvl
                                                andMutable: YES];
    channel_t *ch4w6 = [[channel_t alloc] initWithMaxLevel: lvl
                                                andMutable: YES];
    Channels *ch6 = [w6 addChannels: [
        NSArray arrayWithObjects: ch1w6, ch2w6, ch3w6, ch4w6, nil]
    ];
    [ch6 setMute: NO forChannel: 0];
    [ch6 setLevel: 120 forChannel: 1];
    [ch6 setLevel: 80 forChannel: 2];
    Widget *w7 = [tui addWidgetWithName: @"opttest_long"];
    NSArray *optw7 = [NSArray arrayWithObjects: @"opt1", @"opt2", nil];
    Options *o1 = [w7 addOptions: optw7];
    Widget *w8 = [tui addWidgetWithName: @"opttest2"];
    NSArray *optw8 = [NSArray arrayWithObjects: @"opt3", @"opt4", nil];
    Options *o2 = [w8 addOptions: optw8];
    [o2 set: 1];
    getch(); // TODO: remove this when event loop is in place
    [tui release];
    return 0;
}
