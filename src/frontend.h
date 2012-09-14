#import <Foundation/NSObject.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>
#import <Foundation/NSDecimalNumber.h>
#import <curses.h>
#import "types.h"


@interface Channel: NSObject {
    @private
        int my;
        WINDOW *win;
        int currentLevel;
        int maxLevel;
        BOOL mute;
        BOOL mutable;
        BOOL printMute;
        BOOL inside;
}

-(Channel*) initWithIndex: (int) i
              andMaxLevel: (NSNumber*) mlevel_
                  andMute: (NSNumber*) mute_ // it's BOOL, but we need a pointer
             andPrintMute: (BOOL) printMute_
                andParent: (WINDOW*) parent;
-(void) dealloc;
-(void) print;
-(void) setMute: (BOOL) mute_;
-(void) setLevel: (int) level_;
-(void) inside;
-(void) outside;
-(void) up;
-(void) down;
-(void) moveLeftBy: (int) p;
-(void) mute;
@end


@interface Channels: NSObject {
    @private
        WINDOW *win;
        NSMutableArray *channels;
        BOOL inside;
        int highlight;
}

-(Channels*) initWithChannels: (NSArray*) channels_
                  andPosition: (int) position
                    andParent: (WINDOW*) parent;
-(void) dealloc;
-(void) setMute: (BOOL) mute;
-(void) setLevel: (int) level;
-(void) setMute: (BOOL) mute forChannel: (int) channel;
-(void) setLevel: (int) level forChannel: (int) channel;
-(BOOL) previous;
-(BOOL) next;
-(void) up;
-(void) down;
-(void) inside;
-(void) outside;
-(void) moveLeftBy: (int) p;
-(void) mute;
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
-(void) setCurrent: (int) i;
-(void) up;
-(void) down;
-(void) moveLeftBy: (int) p;
@end


@interface Widget: NSObject {
    @private
        WINDOW *win;
        int position;
        int height;
        int width;
        NSString *name;
        NSMutableArray *controls;
        BOOL highlighted;
        int highlight;
        BOOL inside;
}

-(Widget*) initWithPosition: (int) p
                    andName: (NSString*) name_;
-(void) dealloc;
-(void) printWithWidth: (int) width_;
-(void) printName;
-(Channels*) addChannels: (NSArray*) channels;
-(Options*) addOptions: (NSArray*) options;
-(void) setHighlighted: (BOOL) active;
-(BOOL) canGoInside;
-(void) inside;
-(void) outside;
-(void) previous;
-(void) next;
-(void) up;
-(void) down;
-(void) moveLeftBy: (int) p;
-(int) height;
-(int) width;
-(int) endPosition;
-(NSString*) name;
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
        View view;
}

-(Top*) init;
-(void) dealloc;
-(void) print;
@end


typedef enum {
    INSIDE,
    OUTSIDE
} Mode;


@interface Bottom: NSObject {
    @private
        WINDOW *win;
        Mode mode;
}

-(Bottom*) init;
-(void) dealloc;
-(void) print;
-(void) inside;
-(BOOL) outside;
@end


@interface TUI: NSObject {
    @private
        NSMutableArray *widgets;
        Top *top;
        Bottom *bottom;
        int highlight;
        BOOL inside;
}

-(TUI*) init;
-(void) dealloc;
-(Widget*) addWidgetWithName: (NSString*) name;
-(void) removeWidget: (NSString*) name;
-(void) setCurrent: (int) i;
-(void) previous;
-(void) next;
-(void) up;
-(void) down;
-(void) mute;
-(void) inside;
-(BOOL) outside;
@end
