#import "frontend.h"


int main(int argc, char const *argv[]) {
    TUI *tui = [[TUI alloc] init];
    Widget *w1 = [tui addWidgetWithName: @"test1"];
    Widget *w2 = [tui addWidgetWithName: @"test2"];
    channel_t *ch1w1 = [[channel_t alloc] initWithMaxLevel: 130
                                                andMutable: YES];
    channel_t *ch2w1 = [[channel_t alloc] initWithMaxLevel: 130
                                                andMutable: YES];
    [w1 addChannels: [NSArray arrayWithObjects: ch1w1, ch2w1, nil]];
    channel_t *ch1w2 = [[channel_t alloc] initWithMaxLevel: 130
                                                andMutable: NO];
    [w2 addChannels: [NSArray arrayWithObjects: ch1w2, nil]];
    getch(); // TODO: remove this when event loop is in place
    [tui release];
    [w1 release];
    [w2 release]; // FIXME: get rid of those (make TUI maintain)
    return 0;
}
