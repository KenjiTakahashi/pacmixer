/*
 This is a part of pacmixer @ http://github.com/KenjiTakahashi/pacmixer
 Karol "Kenji Takahashi" Woźniak © 2012

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


#include "debug.h"


void debug_fprintf(const char *func, const char *fmt, ...) {
    char debug_filename[255];
    sprintf(debug_filename, "%s%s", getenv("HOME"), "/.pacmixer.log");
    struct timespec time;
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &time);
    va_list args;
    va_start(args, fmt);
    FILE *f = fopen(debug_filename, "a");
    fprintf(f, "%d:%ld(%s):", (int)time.tv_sec, time.tv_nsec, func);
    vfprintf(f, fmt, args);
    fprintf(f, "\n");
    fclose(f);
    va_end(args);
}
