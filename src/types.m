// This is a part of pacmixer @ http://github.com/KenjiTakahashi/pacmixer
// Karol "Kenji Takahashi" Woźniak © 2012 - 2014
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
    maxLevel = [[NSNumber alloc] initWithInt: maxLevel_];
    normLevel = [[NSNumber alloc] initWithInt: normLevel_];
    isMutable = mutable_ ? YES : NO;
    return self;
}

-(void) dealloc {
    [normLevel release];
    [maxLevel release];
    [super dealloc];
}

-(NSNumber*) maxLevel {
    return maxLevel;
}

-(NSNumber*) normLevel {
    return normLevel;
}

-(BOOL) mutable {
    return isMutable;
}
@end


@implementation volume_t
-(volume_t*) initWithLevel: (int) level_
                   andMute: (int) mute_ {
    self = [super init];
    level = [[NSNumber alloc] initWithInt: level_];
    mute = mute_ ? YES : NO;
    return self;
}

-(void) dealloc {
    [level release];
    [super dealloc];
}

-(NSNumber*) level {
    return level;
}

-(BOOL) mute {
    return mute;
}
@end
