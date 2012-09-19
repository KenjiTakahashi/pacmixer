#import <Foundation/NSObject.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSAutoreleasePool.h>
#import "frontend.h"
#import "middleware.h"


@interface Dispatcher: NSObject {
    @private
        Middleware *middleware;
        TUI *tui;
        NSAutoreleasePool *pool;
}

-(Dispatcher*) init;
-(void) dealloc;
-(void) addWidget: (NSNotification*) notification;
-(void) removeWidget: (NSNotification*) notification;
-(void) run;
@end


int main(int argc, char const *argv[]);
