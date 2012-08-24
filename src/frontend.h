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
                 andLevel: (int) level_
                andParent: (WINDOW*) parent;
-(Channel*) initWithIndex: (int) i
                 andLevel: (int) level_
                  andMute: (bool) mute_
                andParent: (WINDOW*) parent;
-(void) dealloc;
-(void) setMute: (bool) mute_;
-(void) setLevel: (int) level_;
@end


@interface Channels: NSObject {
    @private
        WINDOW *win;
        NSMutableArray *channels;
}

-(Channels*) initWithChannels: (int) channels_
                    andParent: (WINDOW*) parent;
-(void) dealloc;
@end


@interface Widget: NSObject {
    @private
        WINDOW *win;
        int position;
        int height;
        int width;
        NSString *name;
        NSMutableArray *controls;
}

-(Widget*) initWithPosition: (int) p
                    andName: (NSString*) name_
                andChannels: (int) channels;
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
