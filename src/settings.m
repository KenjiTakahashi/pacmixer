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

-(void) dealloc {
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
    return self;
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


@implementation SettingsWidget
-(SettingsWidget*) initWithSettings: (Settings*) settings_
                          andParent: (WINDOW*) parent {
    self = [super init];
    settings = [settings_ retain];
    widgets = [[NSMutableArray alloc] init];
    Values *filters = [[Values alloc] initWithType: [CheckBox class]
                                             andValues: @"PulseAudio internals",
                                                        @"Monitors"];
    values = [NSDictionary dictionaryWithObjectsAndKeys:
        filters, @"Filter",
        nil];
    int my;
    int mx;
    getmaxyx(stdscr, my, mx);
    win = derwin(parent, my - 2, mx, 1, 0); // FIXME (Kenji): Maybe subwin?
    [self print];
    return self;
}

-(void) print {
    NSArray *keys = [values allKeys];
    for(int i = 0; i < [keys count]; ++i) {
        NSString *key = [keys objectAtIndex: i];
        Values *value = [values objectForKey: key];
        id widget = [[[value type] alloc] init];
        [widgets addObject: widget];
    }
}

-(void) dealloc {
    [widgets release];
    [settings release];
    delwin(win);
    [super dealloc];
}
@end
