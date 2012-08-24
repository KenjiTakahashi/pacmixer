CCC=gcc -std=c99
CCFLAGS=-lgnustep-base -lobjc -lcurses
OFLAGS=-fconstant-string-class=NSConstantString
SOURCES=$(wildcard src/*.m)
OBJECTS=$(SOURCES:.m=.o)
EXEC=pacmixer

all: $(SOURCES) $(EXEC)

$(EXEC): $(OBJECTS)
	$(CCC) -o $@ $(OBJECTS) $(CCFLAGS)

clean:
	rm -rf $(OBJECTS) $(EXEC)

%.o: %.m
	$(CCC) $(OFLAGS) -c -o $@ $^
