#import <Foundation/NSObject.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSString.h>
#import <Foundation/NSDecimalNumber.h>
#import <curses.h>


@interface channel_t: NSObject {
    @private
        NSNumber* maxLevel;
        BOOL mutable;
}

-(channel_t*) initWithMaxLevel: (NSNumber*) maxLevel_
              andMutable: (BOOL) mutable_;
-(NSNumber*) maxLevel;
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
                  andPosition: (int) position
                    andParent: (WINDOW*) parent;
-(void) dealloc;
@end


@interface Options: NSObject {
    @private
        WINDOW *win;
        NSArray *options;
        int highlight;
}

-(Options*) initWithOptions: (NSArray*) options_
                   andParent: (WINDOW*) parent;
-(void) dealloc;
-(void) print;
-(void) set: (int) i;
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
-(void) printWithWidth: (int) width_;
-(void) addChannels: (NSArray*) channels;
-(Options*) addOptions: (NSArray*) options;
-(int) endPosition;
@end


typedef enum {
    PLAYBACK,
    RECORDING,
    OUTPUTS,
    INPUTS
} View;


@interface Top: NSObject {
    @private
        WINDOW *win;
        NSAutoreleasePool *pool;
        View view;
}

-(Top*) init;
-(void) dealloc;
-(void) print;
@end


typedef enum {
    INSIDE,
    OUTSIDE
} State;


@interface Bottom: NSObject {
    @private
        WINDOW *win;
        NSAutoreleasePool *pool;
        State state;
}

-(Bottom*) init;
-(void) dealloc;
-(void) print;
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
