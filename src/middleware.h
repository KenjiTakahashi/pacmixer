// This is a part of pacmixer @ http://github.com/KenjiTakahashi/pacmixer
// Karol "Kenji Takahashi" Woźniak © 2012
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


#import <curses.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDecimalNumber.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSAutoreleasePool.h>
#import "types.h"
#import "backend.h"


void callback_add_func(void*, const char*, backend_entry_type, uint32_t, const backend_channel_t*, uint8_t);
void callback_update_func(void*, uint32_t, const backend_volume_t*, uint8_t);
void callback_remove_func(void*, uint32_t);

@interface Block: NSObject {
    @private
        context_t *context;
        uint32_t idx;
        int i;
        backend_entry_type type;
}

-(Block*) initWithContext: (context_t*) context_
                    andId: (uint32_t) idx_
                 andIndex: (int) i_
                  andType: (backend_entry_type) type_;
-(void) setVolume: (NSNotification*) notification;
-(void) setVolumes: (NSNotification*) notification;
-(void) setMute: (NSNotification*) notification;
@end

@interface Middleware: NSObject {
    @private
        context_t *context;
        callback_t *callback;
        NSMutableArray *blocks;
}

-(Middleware*) init;
-(void) dealloc;
-(Block*) addBlockWithId: (uint32_t) idx
                andIndex: (int) i
                 andType: (backend_entry_type) type;
@end
