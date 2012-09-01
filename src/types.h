#import <Foundation/NSObject.h>
#import <Foundation/NSDecimalNumber.h>


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
