CC		= g++
CXXFLAGS	= -Wall -Os -s -std=c++11
#CXXFLAGS	= -Wall -pedantic -g -std=c++11
DEPS		= xmkit.h
OBJ		= xmkit.o xm2squeekerplus.o


xm2squeekerplus: $(OBJ)
	$(CC) $(CXXFLAGS) -o $@ $^ $(LDFLAGS)

%.o: %.cpp $(DEPS)
	$(CC) -c $(CXXFLAGS) -o $@ $< $(LDFLAGS)

.PHONY: clean
clean:
	rm *o
