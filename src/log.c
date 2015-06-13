// pacmixer
// Copyright (C) 2012, 2015 Karol 'Kenji Takahashi' Woźniak
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
// OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#include "log.h"


struct Logger pacmixer_logger = { NULL };

void pacmixer_log_set_path(const char *path) {
    if(path == NULL || strcmp(path, "") == 0) {
        return;
    }
    char *home = path[0] != '/' ? getenv("HOME") : "";
    char *dir = malloc((strlen(home) + strlen(path) + 11) * sizeof(char));
    sprintf(dir, "%s/%s/pacmixer", home, path);
    pacmixer_logger.path = malloc((strlen(dir) + 15) * sizeof(char));
    sprintf(pacmixer_logger.path, "%s/pacmixer.log", dir);
    mkdirp(dir);
    free(dir);
}

void pacmixer_log_free() {
    if(pacmixer_logger.path != NULL) {
        free(pacmixer_logger.path);
    }
}

void pacmixer_log_push(const char* file, int line, const char* fmt, ...) {
    if(pacmixer_logger.path == NULL) {
        return;
    }
    time_t t = time(NULL);
    struct tm* utc = gmtime(&t);
    char stamp[20];
    strftime(stamp, 20, "%F %T", utc);
    va_list args;
    va_start(args, fmt);
    FILE *f = fopen(pacmixer_logger.path, "a");
    fprintf(f, "[%s](%s:%d):", stamp, file, line);
    vfprintf(f, fmt, args);
    fprintf(f, "\n");
    fclose(f);
    va_end(args);
}
