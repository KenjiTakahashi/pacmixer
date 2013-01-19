// This is a part of pacmixer @ http://github.com/KenjiTakahashi/pacmixer
// Karol "Kenji Takahashi" Woźniak © 2012 - 2013
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.


#import "types.h"


@implementation channel_t
-(channel_t*) initWithMaxLevel: (int) maxLevel_
                  andNormLevel: (int) normLevel_
                    andMutable: (int) mutable_ {
    self = [super init];
    maxLevel = [NSNumber numberWithInt: maxLevel_];
    normLevel = [NSNumber numberWithInt: normLevel_];
    mutable = mutable_ ? YES : NO;
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
-(volume_t*) initWithLevel: (int) level_
                   andMute: (int) mute_ {
    self = [super init];
    level = [NSNumber numberWithInt: level_];
    mute = mute_ ? YES : NO;
    return self;
}

-(NSNumber*) level {
    return level;
}

-(BOOL) mute {
    return mute;
}
@end


@implementation card_profile_t
-(card_profile_t*) initWithProfiles: (const char**) profiles_
                       andNProfiles: (int) n_profiles
                   andActiveProfile: (const char*) active {
    self = [super init];
    profiles = [[NSMutableArray alloc] init];
    for(int i = 0; i < n_profiles; ++i) {
        [profiles addObject: [NSString stringWithUTF8String: profiles_[i]]];
    }
    activeProfile = [NSString stringWithUTF8String: active];
    return self;
}

-(NSString*) activeProfile {
    return activeProfile;
}

-(void) dealloc {
    [profiles release];
    [super dealloc];
}
@end
