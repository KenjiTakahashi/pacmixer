PREFIX=/usr/local

CCC=gcc
CPP=g++
CFLAGS=-std=gnu99 -Wall
OFLAGS=-fconstant-string-class=NSConstantString
CPPFLAGS=-Wall -O2
LIBS=-lgnustep-base -lobjc -lpanel -lcurses
PLIBS=-lpulse
SOURCES=$(wildcard src/*.m) $(wildcard src/widgets/*.m)
OBJECTS=$(SOURCES:.m=.o)
CSOURCES=src/backend.c
COBJECTS=$(CSOURCES:.c=.o)
TSOURCES=tests/test_main.cpp
TOBJECTS=$(TSOURCES:.cpp=.o)
EXEC=pacmixer
TEXEC=test_pacmixer

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

$(TEXEC): $(TOBJECTS)
	$(CPP) -o $@ $(OBJECTS) $(COBJECTS) $(TOBJECTS) $(LIBS)

tests: CFLAGS += -O2
tests: OBJECTS := $(filter-out src/main.o, $(OBJECTS))
tests: $(OBJECTS) $(COBJECTS) $(TOBJECTS) $(TEXEC)

clean_tests: clean
	rm -rf $(TOBJECTS) $(TEXEC)
