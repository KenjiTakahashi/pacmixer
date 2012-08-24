#import "frontend.h"


int main(int argc, char const *argv[]) {
    TUI *tui = [[TUI alloc] init];
    [tui addWidgetWithChannels: 2];
    [tui addWidgetWithChannels: 1];
    getch(); // TODO: remove this when event loop is in place
    [tui release];
    return 0;
}
