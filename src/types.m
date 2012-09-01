#import "types.h"


@implementation channel_t
-(channel_t*) initWithMaxLevel: (NSNumber*) maxLevel_
                    andMutable: (BOOL) mutable_ {
    self = [super init];
    maxLevel = maxLevel_;
    mutable = mutable_;
    return self;
}

-(NSNumber*) maxLevel {
    return maxLevel;
}

-(BOOL) mutable {
    return mutable;
}
@end
