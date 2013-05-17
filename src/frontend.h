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
#import <Foundation/NSString.h>
#import <Foundation/NSDecimalNumber.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSIndexSet.h>
#import <curses.h>
#import <panel.h>
#import "widgets/menu.h"
#import "widgets/widget.h"
#import "widgets/misc.h"
#import "widgets/notice.h"
#import "widgets/options.h"
#import "settings.h"
#ifdef DEBUG
#import "debug.h"
#endif


@interface TUI: NSObject <Controlling> {
    @private
        NSMutableArray *allWidgets;
        NSMutableArray *widgets;
        Settings *settings;
        Top *top;
        Bottom *bottom;
        NSMutableArray *xpaddingStates;
        NSMutableArray *ypaddingStates;
        int highlight;
        Notice *notice;
}

-(TUI*) init;
-(void) dealloc;
-(void) addWaiter: (NSNotification*) _;
-(void) removeWaiter: (NSNotification*) _;
-(void) reprint;
+(void) refresh;
-(void) clear;
-(BOOL) applySettings: (NSString*) name;
-(Widget*) addWidgetWithName: (NSString*) name
                     andType: (View) type
                       andId: (NSString*) id_;
-(void) removeWidget: (NSString*) id_;
-(void) addProfiles: (NSArray*) profiles
         withActive: (NSString*) active
            andName: (NSString*) name
              andId: (NSString*) id_;
-(void) setCurrent: (int) i;
-(void) setFirst;
-(void) setFilter: (View) type;
-(void) showSettings;
-(void) switchSetting;
-(void) previous;
-(void) next;
-(void) up;
-(void) down;
-(void) mute;
-(void) inside;
-(void) settings;
-(BOOL) outside;
@end
