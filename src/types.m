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
