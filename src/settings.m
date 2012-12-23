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
    NSString *name = @"SettingChanged";
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(setValueN:)
                                                 name: name
                                               object: nil];
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

-(void) setValueN: (NSNotification*) notification {
    NSDictionary *info = [notification userInfo];
    NSArray *keys = [info allKeys];
    for(int i = 0; i < [keys count]; ++i) {
        NSString *key = [keys objectAtIndex: i];
        [self setValue: [info objectForKey: key] forKey: key];
    }
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
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [storage synchronize];
    [super dealloc];
}
@end
