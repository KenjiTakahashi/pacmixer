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


#import "settings.h"


@implementation Values
-(Values*) initWithType: (Class) type_
              andValues: (NSString*) firstString, ... {
    self = [super init];
    values = [[NSMutableArray alloc] init];
    va_list args;
    va_start(args, firstString);
    for(NSString *str = firstString; str != nil; str = va_arg(args, NSString*)) {
        [values addObject: str];
    }
    type = type_;
    va_end(args);
    return self;
}

-(int) count {
    return [values count];
}

-(id) objectAtIndex: (int) i {
    return [values objectAtIndex: i];
}

-(Class) type {
    return type;
}

-(NSArray*) values {
    return values;
}

-(void) dealloc {
    [values release];
    [super dealloc];
}
@end


@implementation Settings
-(Settings*) init {
    self = [super init];
    storage = [NSUserDefaults standardUserDefaults];
    defaults = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInt: 1], @"Filter/PulseAudio internals",
        [NSNumber numberWithInt: 0], @"Filter/Monitors",
        nil];
    Values *filters = [[Values alloc] initWithType: [CheckBox class]
                                         andValues: @"PulseAudio internals",
                                                    @"Monitors",
                                                    nil];
    names = [NSDictionary dictionaryWithObjectsAndKeys:
        filters, @"Filter",
        nil];
    [filters release];
    return self;
}

-(int) count {
    return [names count];
}

-(id) objectForKey: (NSString*) key {
    return [names objectForKey: key];
}

-(NSArray*) allKeys {
    return [names allKeys];
}

-(void) setValue: (id) value
          forKey: (NSString*) key {
    [storage setObject: value forKey: key];
}

-(id) getValue: (NSString*) key {
    id value = [storage objectForKey: key];
    if(value != nil) {
        return value;
    }
    value = [defaults objectForKey: key];
    if(value == nil) {
        return nil;  // FIXME (Kenji): Do something nasty, this shouldn't happen
    }
    return value;
}

-(void) dealloc {
    [storage synchronize];
    [super dealloc];
}
@end
