#import <Foundation/NSObject.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSString.h>
#import <curses.h>


@interface Channel: NSObject {
    @private
        int my;
        WINDOW *win;
        int level;
        bool mute;
}

-(Channel*) initWithIndex: (int) i
                andParent: (WINDOW*) parent;
-(Channel*) initWithIndex: (int) i
                  andMute: (bool) mute_
                andParent: (WINDOW*) parent;
-(void) dealloc;
-(void) setMute: (bool) mute_;
@end


@interface Widget: NSObject {
    @private
        WINDOW *win;
        int position;
        int height;
        int width;
        NSMutableArray *controls;
}

-(Widget*) initWithPosition: (int) p andChannels: (int) channels;
-(void) dealloc;
-(int) endPosition;
@end


@interface Top: NSObject {
    @private
        WINDOW *win;
        NSAutoreleasePool *pool;
}

-(Top*) init;
-(void) dealloc;
@end


@interface Bottom: NSObject {
    @private
        WINDOW *win;
        NSAutoreleasePool *pool;
}

-(Bottom*) init;
-(void) dealloc;
@end


@interface TUI: NSObject {
    @private
        NSMutableArray *widgets;
        Top *top;
        Bottom *bottom;
}

-(TUI*) init;
-(void) dealloc;
-(void) addWidgetWithChannels: (int) channels;
@end
