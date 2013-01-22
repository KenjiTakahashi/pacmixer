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
#import <Foundation/NSNotification.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSAutoreleasePool.h>
#import "frontend.h"
#import "middleware.h"
#ifdef DEBUG
#import "debug.h"
#endif


@interface Dispatcher: NSObject {
    @private
        Middleware *middleware;
        TUI *tui;
        NSAutoreleasePool *pool;
}

-(Dispatcher*) init;
-(void) dealloc;
-(void) addWidget: (NSNotification*) notification;
-(void) removeWidget: (NSNotification*) notification;
-(void) run;
@end


int main(int argc, char const *argv[]);
