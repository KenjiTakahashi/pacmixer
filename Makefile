# This is a part of pacmixer @ http://github.com/KenjiTakahashi/pacmixer
# Karol "Kenji Takahashi" Woźniak © 2012 - 2013
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

PREFIX=/usr/local

CCC=gcc
CPP=g++
CFLAGS=-std=gnu99 -Wall
OFLAGS=`gnustep-config --objc-flags`
CPPFLAGS=-Wall -g -O2 -D TESTS=1 -fobjc-exceptions -D __STDC_LIMIT_MACROS
LIBS=-lgnustep-base -lobjc -lpanel -lcurses
PLIBS=-lpulse
SOURCES=$(wildcard src/*.m) $(wildcard src/widgets/*.m)
OBJECTS=$(SOURCES:.m=.o)
CSOURCES=src/backend.c
COBJECTS=$(CSOURCES:.c=.o)

TSOURCES=$(wildcard tests/*.mm)
TOBJECTS=$(TSOURCES:.mm=.o)
T2SOURCES=$(wildcard tests/*.cpp)
T2OBJECTS=$(T2SOURCES:.cpp=.o)
MSOURCES=$(wildcard tests/mock_*.c)
MOBJECTS=$(MSOURCES:.c=.o)

DEBUGSRC=src/debug.c
DEBUGOBJ=src/debug.o

EXEC=pacmixer
TEXEC=pacmixer_run_tests

all: CFLAGS += -O2
all: $(CSOURCES) $(SOURCES) $(EXEC)
debug: CFLAGS += -g -O0 -D DEBUG=1
debug: LIBS += -lrt
debug: $(OBJECTS) $(COBJECTS) $(DEBUGOBJ)
	$(CCC) $(CFLAGS) -c -o $(DEBUGOBJ) $(DEBUGSRC)
	$(CCC) -o $(EXEC) $(OBJECTS) $(COBJECTS) $(DEBUGOBJ) $(LIBS) $(PLIBS)

$(EXEC): $(OBJECTS) $(COBJECTS)
	$(CCC) -o $@ $(OBJECTS) $(COBJECTS) $(LIBS) $(PLIBS)

clean:
	rm -rf $(OBJECTS) $(COBJECTS) $(DEBUGOBJ) $(EXEC)

%.o: %.m
	$(CCC) $(CFLAGS) $(OFLAGS) -c -o $@ $^

%.o: %.c
	$(CCC) $(CFLAGS) -c -o $@ $^

install:
	@echo "installing executable file into $(DESTDIR)$(PREFIX)/bin"
	@mkdir -p $(DESTDIR)$(PREFIX)/bin
	@cp -f pacmixer $(DESTDIR)$(PREFIX)/bin/
	@chmod 755 $(DESTDIR)$(PREFIX)/bin/pacmixer

%.o: %.cpp
	$(CPP) $(CPPFLAGS) -c -o $@ $^

%.o: %.mm
	$(CPP) $(CPPFLAGS) $(OFLAGS) -c -o $@ $^

$(TEXEC): $(OBJECTS) $(TOBJECTS) $(T2OBJECTS) $(MOBJECTS) $(DEBUGOBJ)
	$(CPP) -o $@ $(OBJECTS) $(TOBJECTS) $(T2OBJECTS) $(MOBJECTS) $(DEBUGOBJ) $(LIBS)

tests: CFLAGS += -g -O2 -D TESTS=1
tests: SOURCES := $(filter-out src/main.m, $(SOURCES))
tests: OBJECTS := $(filter-out src/main.o, $(OBJECTS))
tests: $(SOURCES) $(TSOURCES) $(T2SOURCES) $(MSOURCES) $(DEBUGSRC) $(TEXEC)

clean_tests: clean
	rm -rf $(TOBJECTS) $(T2OBJECTS) $(MOBJECTS) $(TEXEC)
