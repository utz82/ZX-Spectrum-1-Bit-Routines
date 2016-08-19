#ifndef XMKIT__H__
#define XMKIT__H__

#include <string>
#include <fstream>

using namespace std;


class xmod {

public:
	int seqLength, uniquePtns, uniqueInstruments, globalSpd, globalBpm;
	
	unsigned char loopPoint;
	unsigned char *sequence;
	
	long *ptnLengths;
	unsigned char **ptnRowSpeeds;
	unsigned char **ptnRowBpms;
	unsigned char ***ptnNotes;
	unsigned char ***ptnTriggers;
	unsigned char ***ptnInstruments;
	unsigned char ***ptnVolumes;
	unsigned char ***ptnFxCmds;
	unsigned char ***ptnFxParams;
	unsigned char ***ptnDetune;
	
	unsigned char *instrSampleAmount;
	long **instrSmpLengths;
	unsigned char **instrSmpMap;
	
	//TODO: hide this
	unsigned char **instrVolEnvPoints;
	unsigned *instrVolEnvLength;
// 	unsigned char *instrVolEnvSustainPoint;
// 	unsigned char *instrVolEnvLoopStart;
// 	unsigned char *instrVolEnvLoopEnd;
	bool *instrVolEnvUsed;
// 	bool *instrVolEnvSustainUsed;
// 	bool *instrVolEnvLoopUsed;
// 	unsigned char **instrVolEnv;
	
	char **instrSmpRelNotes;
	bool **instrSmp16Bit;
	unsigned char **instrSmpLoopType;
	long **instrSmpLoopStart;
	long **instrSmpLoopLength;
	short ***instrSamples;
	

	xmod();
	~xmod();		
	bool read(string filename, const char useChannels, bool verbose = false);
	bool extractPatterns(bool convertNoteStops = true);
	bool extractInstruments(bool verbose = false);
	bool isPtnUsed(unsigned char ptn);
	bool isInstrumentUsed(unsigned char instrument);
	int limitNoteRange(unsigned char lowerLimit, unsigned char upperLimit, unsigned char replaceValue = 0);
	bool convertSamples(unsigned resolution = 256, long rate = 8000, bool unsignedData = true);

private:
	ifstream XMFILE;
	unsigned char *xmdata;
	long *ptnOffsetList;
	long *instrOffsetList;
	int xmHeaderLength;
	long filesize;
	bool verbose;
	int channels, chUsed;
	char ***instrRawSamples;
	
	bool convertToPCM();
};

#endif