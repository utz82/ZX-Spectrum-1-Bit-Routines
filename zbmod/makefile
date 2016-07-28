CC		= g++
#CXXFLAGS	= -Wall -Os -s
CXXFLAGS	= -Wall -g -std=c++11
DEPS		= xmkit.h
OBJ		= xmkit.o xm2zbmod.o


xm2zbmod: $(OBJ)
	$(CC) $(CXXFLAGS) -o $@ $^ $(LDFLAGS)

%.o: %.cpp $(DEPS)
	$(CC) -c $(CXXFLAGS) -o $@ $< $(LDFLAGS)

.PHONY: clean
clean:
	rm *o
