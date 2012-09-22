#import <Foundation/NSObject.h>
#import <Foundation/NSDecimalNumber.h>


@interface channel_t: NSObject {
    @private
        NSNumber *maxLevel;
        NSNumber *normLevel;
        BOOL mutable;
}

-(channel_t*) initWithMaxLevel: (NSNumber*) maxLevel_
                  andNormLevel: (NSNumber*) normLevel_
              andMutable: (BOOL) mutable_;
-(NSNumber*) maxLevel;
-(NSNumber*) normLevel;
-(BOOL) mutable;
@end


@interface volume_t: NSObject {
    @private
        NSNumber *level;
        BOOL mute;
}

-(volume_t*) initWithLevel: (NSNumber*) level_
                   andMute: (BOOL) mute_;
-(NSNumber*) level;
-(BOOL) mute;
@end
