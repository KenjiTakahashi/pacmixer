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


#include "settings.h"
#include "../vendor/cpptoml.h"


pacmixer::Settings::Settings() {
    auto home = std::string(getenv("HOME"));
    auto dir = home + "/.config/pacmixer";
    this->fn = dir + "/settings.toml";

    try {
        this->g = std::make_shared<cpptoml::table>(cpptoml::parse_file(this->fn));
    } catch(const cpptoml::parse_exception &e) {
        std::cerr << "ERROR parsing config file: " << e.what() << std::endl;
        std::cerr << "Writing default config file" << std::endl;
        std::cerr << "Old file will be moved to settings.toml~" << std::endl;

        rename(this->fn.c_str(), (dir + "/settings.toml~").c_str());
        mkdir(dir.c_str(), 0777);

        std::ofstream defaults(this->fn);
        defaults << "[Filter]\n";
        defaults << "Monitors = false\n";
        defaults << "Internals = true\n";
        defaults.close();

        this->g = std::make_shared<cpptoml::table>(cpptoml::parse_file(this->fn));
    }
}

bool pacmixer::Settings::val() {
    return true;
}

template<typename T> T pacmixer::Settings::value(std::string key) const {
    return this->g->get_qualified(key)->as<T>()->get();
}

template bool pacmixer::Settings::value<bool>(std::string key) const;
