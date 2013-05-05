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


#import <Foundation/NSObject.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDecimalNumber.h>


@interface channel_t: NSObject {
    @private
        NSNumber *maxLevel;
        NSNumber *normLevel;
        BOOL isMutable;
}

-(channel_t*) initWithMaxLevel: (int) maxLevel_
                  andNormLevel: (int) normLevel_
                    andMutable: (int) mutable_;
-(void) dealloc;
-(NSNumber*) maxLevel;
-(NSNumber*) normLevel;
-(BOOL) mutable;
@end


@interface volume_t: NSObject {
    @private
        NSNumber *level;
        BOOL mute;
}

-(volume_t*) initWithLevel: (int) level_
                   andMute: (int) mute_;
-(void) dealloc;
-(NSNumber*) level;
-(BOOL) mute;
@end


@interface option_t: NSObject {
    @private
        NSMutableArray *options;
        NSString *active;
}

-(option_t*) initWithOptions: (char**const) options_
                 andNOptions: (int) n_options
                   andActive: (const char*) active_;
-(void) dealloc;
-(NSArray*) options;
-(NSString*) active;
@end
