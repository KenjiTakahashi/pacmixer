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


@implementation Settings
-(Settings*) init {
    self = [super init];
    storage = [NSUserDefaults standardUserDefaults];
    defaults = [NSDictionary dictionaryWithObjectsAndKeys:
        nil
    ];
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
    int my;
    int mx;
    getmaxyx(stdscr, my, mx);
    win = derwin(parent, my - 2, mx, 1, 0); // FIXME (Kenji): Maybe subwin?
    return self;
}

-(void) dealloc {
    [widgets release];
    [settings release];
    delwin(win);
    [super dealloc];
}
@end
