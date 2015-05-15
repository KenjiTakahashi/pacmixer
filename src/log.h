// pacmixer
// Copyright (C) 2012 - 2013, 2015 Karol 'Kenji Takahashi' Woźniak
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


#ifndef __PACMIXER_LOG_H__
#define __PACMIXER_LOG_H__
#ifdef __cplusplus
extern "C" {
#endif


#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <sys/stat.h>


struct Logger {
    char *path;
};

extern struct Logger pacmixer_logger;

void pacmixer_log_set_path(const char *path);
void pacmixer_log_free();
void pacmixer_log_push(const char* file, int line, const char* fmt, ...);
#define PACMIXER_LOG(fmt, ...) pacmixer_log_push(__FILE__, __LINE__, fmt, ##__VA_ARGS__)


#ifdef __cplusplus
}
#endif
#endif // __PACMIXER_LOG_H__
