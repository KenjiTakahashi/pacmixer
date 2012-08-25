#import <Foundation/NSObject.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSString.h>
#import <Foundation/NSDecimalNumber.h>
#import <curses.h>


@interface channel_t: NSObject {
    @private
        int maxLevel;
        BOOL mutable;
}

-(channel_t*) initWithMaxLevel: (int) maxLevel_
              andMutable: (BOOL) mutable_;
-(int) maxLevel;
-(BOOL) mutable;
@end


@interface Channel: NSObject {
    @private
        int my;
        WINDOW *win;
        int currentLevel;
        int maxLevel;
        BOOL mute;
        BOOL mutable;
}

-(Channel*) initWithIndex: (int) i
              andMaxLevel: (NSNumber*) mlevel_
                  andMute: (NSNumber*) mute_ // it's BOOL, but we need a pointer
                andParent: (WINDOW*) parent;
-(void) dealloc;
-(void) setMute: (BOOL) mute_;
-(void) setLevel: (int) level_;
@end


@interface Channels: NSObject {
    @private
        WINDOW *win;
        NSMutableArray *channels;
}

-(Channels*) initWithChannels: (NSArray*) channels_
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
                    andName: (NSString*) name_;
-(void) dealloc;
-(void) addChannels: (NSArray*) channels;
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
-(Widget*) addWidgetWithName: (NSString*) name;
@end
