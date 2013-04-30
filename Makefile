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
OFLAGS=-fconstant-string-class=NSConstantString
CPPFLAGS=-Wall -fpermissive -g -O2 -D TESTS=1
LIBS=-lgnustep-base -lobjc -lpanel -lcurses
PLIBS=-lpulse
SOURCES=$(wildcard src/*.m) $(wildcard src/widgets/*.m)
OBJECTS=$(SOURCES:.m=.o)
CSOURCES=src/backend.c
COBJECTS=$(CSOURCES:.c=.o)
TSOURCES=tests/test_main.cpp
TOBJECTS=$(TSOURCES:.cpp=.o)
MSOURCES=$(wildcard tests/mock_*.c)
MOBJECTS=$(MSOURCES:.c=.o)
EXEC=pacmixer
TEXEC=pacmixer_run_tests

all: CFLAGS += -O2
all: $(CSOURCES) $(SOURCES) $(EXEC)
debug: CFLAGS += -g -O0 -D DEBUG=1
debug: LIBS += -lrt
debug: $(OBJECTS) $(COBJECTS)
	$(CCC) $(CFLAGS) -c -o src/debug.o src/debug.c
	$(CCC) -o $(EXEC) $(OBJECTS) $(COBJECTS) src/debug.o $(LIBS)

$(EXEC): $(OBJECTS) $(COBJECTS)
	$(CCC) -o $@ $(OBJECTS) $(COBJECTS) $(LIBS) $(PLIBS)

clean:
	rm -rf $(OBJECTS) $(COBJECTS) src/debug.o $(EXEC)

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

$(TEXEC): $(OBJECTS) $(COBJECTS) $(TOBJECTS) $(MOBJECTS)
	$(CPP) -o $@ $(OBJECTS) $(COBJECTS) $(TOBJECTS) $(MOBJECTS) $(LIBS)

tests: CFLAGS += -g -O2 -D TESTS=1
tests: SOURCES := $(filter-out src/main.m, $(SOURCES))
tests: OBJECTS := $(filter-out src/main.o, $(OBJECTS))
tests: $(CSOURCES) $(SOURCES) $(TSOURCES) $(MSOURCES) $(TEXEC)

clean_tests: clean
	rm -rf $(TOBJECTS) $(MOBJECTS) $(TEXEC)
