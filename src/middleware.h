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


#import <Foundation/NSObject.h>
#import <Foundation/NSDecimalNumber.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSAutoreleasePool.h>
#import "types.h"
#import "backend.h"


void callback_add_func(void*, const char*, uint32_t, const backend_channel_t*, uint8_t);
void callback_update_func(void*, uint32_t, const backend_volume_t*, uint8_t);
void callback_remove_func(void*, uint32_t);

@interface Middleware: NSObject {
    context_t *context;
    callback_t *callback;
}

-(Middleware*) init;
-(void) dealloc;
@end
