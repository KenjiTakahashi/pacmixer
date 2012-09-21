CCC=gcc -std=c99 -g
CCFLAGS=-lpulse
OBJCFLAGS=-lgnustep-base -lobjc -lcurses
OFLAGS=-fconstant-string-class=NSConstantString
SOURCES=$(wildcard src/*.m)
OBJECTS=$(SOURCES:.m=.o)
CSOURCES=src/backend.c
COBJECTS=$(CSOURCES:.c=.o)
EXEC=pacmixer

all: $(CSOURCES) $(SOURCES) $(EXEC)

$(EXEC): $(OBJECTS) $(COBJECTS)
	$(CCC) -o $@ $(OBJECTS) $(COBJECTS) $(CCFLAGS) $(OBJCFLAGS)

clean:
	rm -rf $(OBJECTS) $(COBJECTS) $(EXEC)

%.o: %.m
	$(CCC) $(OFLAGS) -c -o $@ $^

%.o: %.c
	$(CCC) -c -o $@ $^
