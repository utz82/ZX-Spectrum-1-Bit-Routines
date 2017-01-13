CC		= g++
CXXFLAGS	= -Wall -O2 -s -std=c++11 -no-pie
#CXXFLAGS	= -Wall -g -std=c++11 -no-pie
DEPS		= xmkit.h
OBJ		= xmkit.o xm2zbmod.o


xm2zbmod: $(OBJ)
	$(CC) $(CXXFLAGS) -o $@ $^ $(LDFLAGS)

%.o: %.cpp $(DEPS)
	$(CC) -c $(CXXFLAGS) -o $@ $< $(LDFLAGS)

.PHONY: clean
clean:
	rm *o
