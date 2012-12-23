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


#import <Foundation/NSUserDefaults.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDecimalNumber.h>
#import <Foundation/NSNotification.h>
#import <curses.h>
#import "widgets/checkbox.h"


@interface Values: NSObject {
    @private
        NSMutableArray *values;
        Class type;
}

-(Values*) initWithType: (Class) type_
              andValues: (NSString*) firstString, ...;
-(int) count;
-(id) objectAtIndex: (int) i;
-(Class) type;
-(NSArray*) values;
-(void) dealloc;
@end


@interface Settings: NSObject {
    @private
        NSUserDefaults *storage;
        NSDictionary *defaults;
        NSDictionary *names;
}

-(Settings*) init;
-(int) count;
-(id) objectForKey: (NSString*) key;
-(NSArray*) allKeys;
-(void) setValueN: (NSNotification*) notification;
-(void) setValue: (id) value
          forKey: (NSString*) key;
-(id) getValue: (NSString*) key;
-(void) dealloc;
@end
