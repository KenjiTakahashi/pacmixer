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


#import "middleware.h"


void callback_add_func(void *self_, const char *name, uint32_t idx, const backend_channel_t *channels, uint8_t chnum) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    Middleware *self = self_;
    NSMutableArray *ch = [NSMutableArray arrayWithCapacity: chnum];
    for(int i = 0; i < chnum; ++i) {
        NSNumber *lvl = [NSNumber numberWithInt: channels[i].maxLevel];
        NSNumber *nlvl = [NSNumber numberWithInt: channels[i].normLevel];
        BOOL mut = channels[i].mutable == 1 ? YES : NO;
        [ch addObject: [[channel_t alloc] initWithMaxLevel: lvl
                                              andNormLevel: nlvl
                                                andMutable: mut]];
    }
    NSDictionary *s = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSString stringWithUTF8String: name], @"name",
        [NSNumber numberWithInt: idx], @"id",
        ch, @"channels",  nil];
    NSString *nname = [NSString stringWithString: @"controlAppeared"];
    [[NSNotificationCenter defaultCenter] postNotificationName: nname
                                                        object: self
                                                      userInfo: s];
    [pool drain];
}

void ucallback_func(void *self_, int i, const backend_channel_t *channels, uint8_t chnum) {
}

void callback_remove_func(void *self_, uint32_t idx) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    Middleware *self = self_;
    NSDictionary *s = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInt: idx], @"id", nil];
    NSString *nname = [NSString stringWithString: @"controlDisappeared"];
    [[NSNotificationCenter defaultCenter] postNotificationName: nname
                                                        object: self
                                                      userInfo: s];
    [pool drain];
}

@implementation Middleware
-(Middleware*) init {
    self = [super init];
    context = backend_new();
    callback = malloc(sizeof(callback_t));
    callback->add = callback_add_func;
    callback->remove = callback_remove_func;
    callback->self = self;
    backend_init(context, callback);
    return self;
}

-(void) dealloc {
    backend_destroy(context);
    free(callback);
    [super dealloc];
}
@end
