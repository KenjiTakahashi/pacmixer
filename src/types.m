#import "types.h"


@implementation channel_t
-(channel_t*) initWithMaxLevel: (NSNumber*) maxLevel_
                  andNormLevel: (NSNumber*) normLevel_
                    andMutable: (BOOL) mutable_ {
    self = [super init];
    maxLevel = maxLevel_;
    normLevel = normLevel_;
    mutable = mutable_;
    return self;
}

-(NSNumber*) maxLevel {
    return maxLevel;
}

-(NSNumber*) normLevel {
    return normLevel;
}

-(BOOL) mutable {
    return mutable;
}
@end


@implementation volume_t
-(volume_t*) initWithLevel: (NSNumber*) level_
                  andMute: (BOOL) mute_ {
    self = [super init];
    level = level_;
    mute = mute_;
    return self;
}

-(NSNumber*) level {
    return level;
}

-(BOOL) mute {
    return mute;
}
@end
