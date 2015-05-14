// pacmixer
// Copyright (C) 2015 Karol 'Kenji Takahashi' Woźniak
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


#ifndef __PACMIXER_SETTINGS_H__
#define __PACMIXER_SETTINGS_H__


#include <iostream>
#include <memory>
#include <string>
#include <sys/stat.h>

// TODO: Use this "normally" when we move more code to CPP.
// Right now it produces compatibility problems between cpptoml
// code and ObjC++ compiler...
// This file should probably be header only, because templates...
namespace cpptoml {
    class table;
}

namespace pacmixer {
    class Settings {
        std::string fn;
        // TODO: We do not need pointer here,
        // but we do, because forward decl.
        std::shared_ptr<cpptoml::table> g;

    public:
        Settings();

        template<typename T> T value(std::string key) const;
    };
}


#endif // __PACMIXER_SETTINGS_H__
