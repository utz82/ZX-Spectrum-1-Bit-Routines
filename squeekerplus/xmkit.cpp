
#include <iostream>
#include <string>

#include "xmkit.h"

using namespace std;

bool xmod::read(string filename, const char useChannels, bool verbose) {

	const char xmheader[16] = { "Extended Module" };
	chUsed = useChannels;
	//initialize();

	XMFILE.open (filename.data(), ios::in | ios::binary);
	
	if (!XMFILE.is_open()) {
	
		cout << "Error: Could not open " << filename << endl;
		return false;	
	}

	
	//read XM file into array and convert data to unsigned char
	XMFILE.seekg(0,ios_base::end);
	filesize = XMFILE.tellg();
	
	xmdata = new unsigned char[filesize];
	char *cp = new char[filesize];
	
	XMFILE.seekg(0, ios::beg);
	XMFILE.read(cp, filesize);
	
	for (long i = 0; i < filesize; i++) xmdata[i] = static_cast<unsigned char>(cp[i]);	
	
	delete[] cp;
	cp = NULL;
	XMFILE.close();
	
	
	//verify xm parameters
	for (int i = 0; i < 15; i++) {
	
		if (xmdata[i] != xmheader[i]) {
		
			cout << "Error: Not a valid XM file.\n";
			return false;	
		}	
	}
	
	if (xmdata[58] != 4) {
	
		cout << "Error: Obsolete XM version 1.0" << +xmdata[58] << ", v1.04 required" << endl;
		return false;
	}
	
	if (xmdata[68] < chUsed) {
	
		cout << "Error: XM must have at least " << +chUsed << " channels, but has only " << +xmdata[68] << endl;
		return false;	
	}
	
	if (verbose) cout << "channels in module: \t" << +xmdata[68] << endl;
	channels = xmdata[68];
	
	
	//read global song parameters
	seqLength = xmdata[64];
	uniquePtns = xmdata[70];
	uniqueInstruments = xmdata[72];
	globalSpd = xmdata[76];
	globalBpm = xmdata[78];
	
	if (verbose) cout << dec << "sequence length: \t" << +seqLength << "\nunique patterns: \t" << +uniquePtns << "\nglobal speed: \t\t" << +globalSpd 
	   << "\nglobal BPM: \t\t" << +globalBpm << "\nunique instruments: \t" << uniqueInstruments << endl;
	
	
	//extract pattern offsets and pattern lengths
	xmHeaderLength = (xmdata[61]<<8) + xmdata[60];
	long fileOffset = xmHeaderLength + 60;
	
	ptnLengths = new long[uniquePtns];
	ptnOffsetList = new long[uniquePtns+1];
	ptnOffsetList[0] = fileOffset;
	
	if (verbose) cout << "ptn#\tstart\tlength\n";
	for (int i = 0; i < uniquePtns; i++) {
		
 		ptnLengths[i] = xmdata[fileOffset+5];
		ptnOffsetList[i+1] = ptnOffsetList[i] + xmdata[fileOffset] + xmdata[fileOffset+7] + (xmdata[fileOffset+8]<<8);
		fileOffset = fileOffset + xmdata[fileOffset+7] + (xmdata[fileOffset+8]<<8) + 9;
		
		//if (verbose) cout << hex << "pattern 0x" << +i << " starts at 0x" << +ptnOffsetList[i] << ", length 0x" << ptnLengths[i] << " rows\n";
		if (verbose) cout << hex << "0x" << +i << "\t0x" << +ptnOffsetList[i] << "\t0x" << ptnLengths[i] << endl;
	}
	
	//cout << "instrument block start: " << ptnOffsetList[uniquePtns] << endl;
	
	//extract song sequence
	sequence = new unsigned char[seqLength];
	
	if (verbose) cout << "song sequence: ";
	
	for (fileOffset = 80; fileOffset < static_cast<unsigned char>(seqLength+80); fileOffset++) {
		
		sequence[fileOffset-80] = xmdata[fileOffset];
		if (verbose) cout << " - " << +sequence[fileOffset-80];
	}
	
	if (verbose) cout << endl;
	loopPoint = 0;

	return true;
}



bool xmod::extractPatterns(bool convertNoteStops) {

	ptnNotes = new unsigned char **[uniquePtns]();
	ptnTriggers = new unsigned char **[uniquePtns]();
	ptnVolumes = new unsigned char **[uniquePtns]();
	ptnInstruments = new unsigned char **[uniquePtns]();
	ptnFxCmds = new unsigned char **[uniquePtns]();
	ptnFxParams = new unsigned char **[uniquePtns]();
	ptnRowSpeeds = new unsigned char *[uniquePtns]();
	ptnRowBpms = new unsigned char *[uniquePtns]();
	ptnDetune = new unsigned char **[uniquePtns]();
	
	
	for (int i = 0; i < uniquePtns; i++) {
	
		ptnNotes[i] = new unsigned char *[channels]();
		ptnTriggers[i] = new unsigned char *[channels]();
		ptnVolumes[i] = new unsigned char *[channels]();
		ptnInstruments[i] = new unsigned char *[channels]();
		ptnFxCmds[i] = new unsigned char *[channels]();
		ptnFxParams[i] = new unsigned char *[channels]();
		ptnDetune[i] = new unsigned char *[channels]();
		ptnRowSpeeds[i] = new unsigned char [257]();
		for (int k = 0; k < 257; k++) ptnRowSpeeds[i][k] = globalSpd;
		ptnRowBpms[i] = new unsigned char [257]();
		for (int k = 0; k < 257; k++) ptnRowBpms[i][k] = globalBpm;
		
		
		for (int j = 0; j < channels; j++) {
		
			ptnNotes[i][j] = new unsigned char [257]();
			for (int k = 0; k < 257; k++) ptnNotes[i][j][k] = 0;
			ptnTriggers[i][j] = new unsigned char [257]();
			for (int k = 0; k < 257; k++) ptnTriggers[i][j][k] = 0;
			ptnVolumes[i][j] = new unsigned char [257]();
			for (int k = 0; k < 257; k++) ptnVolumes[i][j][k] = 0;
			ptnInstruments[i][j] = new unsigned char [257]();
			for (int k = 0; k < 257; k++) ptnInstruments[i][j][k] = 0;
			ptnFxCmds[i][j] = new unsigned char [257]();
			for (int k = 0; k < 257; k++) ptnFxCmds[i][j][k] = 0;
			ptnFxParams[i][j] = new unsigned char [257]();
			for (int k = 0; k < 257; k++) ptnFxParams[i][j][k] = 0;
			ptnDetune[i][j] = new unsigned char [257]();
			for (int k = 0; k < 257; k++) ptnDetune[i][j][k] = 8;
		}
	
	}

//	cout << "create vectors ok\n";
	
	for (int ptn = 0; ptn < uniquePtns; ptn++) {
		
		if (isPtnUsed(ptn)) {
		
//		cout << "read ptn " << +ptn << endl;
		
			long fileOffset = ptnOffsetList[ptn] + 9;
		
			for (int row = 1; row <= ptnLengths[ptn]; row++) {
				
				ptnRowSpeeds[ptn][row] = ptnRowSpeeds[ptn][row-1];
				ptnRowBpms[ptn][row] = ptnRowBpms[ptn][row-1];

			
				for (int ch = 0; ch < xmdata[68]; ch++) {
				
					ptnNotes[ptn][ch][row] = ptnNotes[ptn][ch][row-1];
					ptnInstruments[ptn][ch][row] = ptnInstruments[ptn][ch][row-1];
				
					unsigned char ctrlb = xmdata[fileOffset];
					unsigned char temp = 0;
					bool noteStop = false;
 					
 					if (ctrlb >= 0x80) {
					//compressed pattern data
					
						fileOffset++;
						
						if (ctrlb != 0x80) {
						
							if ((ctrlb & 1) == 1) {
							//note value
								if (convertNoteStops) {
								
									if (xmdata[fileOffset] != 97) {
									
										ptnTriggers[ptn][ch][row] = 1;	
										ptnNotes[ptn][ch][row] = xmdata[fileOffset];
									}
									else {
										ptnNotes[ptn][ch][row] = 0;
										ptnInstruments[ptn][ch][row] = 0;
										noteStop = true;
									}
								}
								else {
									
									ptnTriggers[ptn][ch][row] = 1;	
									ptnNotes[ptn][ch][row] = xmdata[fileOffset];
								}

								fileOffset++;
							}
							
							if ((ctrlb & 2) == 2) {
							//instrument
								ptnInstruments[ptn][ch][row] = xmdata[fileOffset];
								if (convertNoteStops && noteStop) ptnInstruments[ptn][ch][row] = 0;
								fileOffset++;
							}
							
							if ((ctrlb & 4) == 4) {
							//volume
								ptnVolumes[ptn][ch][row] = xmdata[fileOffset];
								fileOffset++;
							}
							
							if ((ctrlb & 8) == 8) {
							//fx command
 								ptnFxCmds[ptn][ch][row] = xmdata[fileOffset];
 								temp = xmdata[fileOffset];
								fileOffset++;
							}
							
							if ((ctrlb & 16) == 16) {
							//fx parameter
								ptnFxParams[ptn][ch][row] = xmdata[fileOffset];
								
								//Bxx
								if (temp == 0xb) loopPoint = xmdata[fileOffset];
								//E5x
								if ((temp == 0xe) && ((xmdata[fileOffset] & 0xf0) == 0x50)) ptnDetune[ptn][ch][row] = xmdata[fileOffset] & 0xf;
								//Fxx
								if ((temp == 0xf) && (xmdata[fileOffset] < 0x20)) ptnRowSpeeds[ptn][row] = xmdata[fileOffset];
								if ((temp == 0xf) && (xmdata[fileOffset] >= 0x20)) ptnRowBpms[ptn][row] = xmdata[fileOffset];
								
								fileOffset++;
								temp = 0;
							}
						
						}
					}
					
					else {
					//uncompressed pattern data
					
						//note value		
						if (convertNoteStops) {
								
							if (xmdata[fileOffset] != 97) {
									
								ptnTriggers[ptn][ch][row] = 1;	
								ptnNotes[ptn][ch][row] = xmdata[fileOffset];
							}
							else {
								ptnNotes[ptn][ch][row] = 0;
								ptnInstruments[ptn][ch][row] = 0;
								noteStop = true;
							}
						}
						else {
									
							ptnTriggers[ptn][ch][row] = 1;	
							ptnNotes[ptn][ch][row] = xmdata[fileOffset];
						}

						fileOffset++;
						
						//instrument
						ptnInstruments[ptn][ch][row] = xmdata[fileOffset];
						if (convertNoteStops && noteStop) ptnInstruments[ptn][ch][row] = 0;
						fileOffset++;
						
						//volume
						ptnVolumes[ptn][ch][row] = xmdata[fileOffset];
						fileOffset++;
						
						//fx command
						ptnFxCmds[ptn][ch][row] = xmdata[fileOffset];
						temp = xmdata[fileOffset];
						fileOffset++;
						
						//fx parameter
						ptnFxParams[ptn][ch][row] = xmdata[fileOffset];
								
						//Bxx
						if (temp == 0xb) loopPoint = xmdata[fileOffset];
						//E5x
						if ((temp == 0xe) && ((xmdata[fileOffset] & 0xf0) == 0x50)) ptnDetune[ptn][ch][row] = xmdata[fileOffset] & 0xf;
						//Fxx
						if ((temp == 0xf) && (xmdata[fileOffset] < 0x20)) ptnRowSpeeds[ptn][row] = xmdata[fileOffset];
						if ((temp == 0xf) && (xmdata[fileOffset] >= 0x20)) ptnRowBpms[ptn][row] = xmdata[fileOffset];
						
						fileOffset++;
						temp = 0;
					}
				}
			}
			
//			cout << "done.\n";
		}
	}	
	
	return true;
}



bool xmod::extractInstruments(bool verbose) {

	long fileOffset = ptnOffsetList[uniquePtns];
	
	instrSampleAmount = new unsigned char[uniqueInstruments+1];
	instrSmpLengths = new long *[uniqueInstruments+1];
	instrSmpMap = new unsigned char *[uniqueInstruments+1];
	instrSmpRelNotes = new char *[uniqueInstruments+1];
	instrSmp16Bit = new bool *[uniqueInstruments+1];
	instrSmpLoopType = new unsigned char *[uniqueInstruments+1];
	instrSmpLoopStart = new long *[uniqueInstruments+1];
	instrSmpLoopLength = new long *[uniqueInstruments+1];
	instrRawSamples = new char **[uniqueInstruments+1];
	instrSamples = new short **[uniqueInstruments+1];

	instrVolEnvUsed = new bool[uniqueInstruments+1];
	instrVolEnvLength = new unsigned[uniqueInstruments+1];
	instrVolEnvPoints = new unsigned char *[uniqueInstruments+1];
	
	//TODO: init all with 0
	
	if (verbose) cout << "instr#\tstart\tname\t\t\tsamples\tsmp name\t\tsmp length\toffset\t16-bit\tloop st.\tloop len\tlooping\n";
	
	for (int i = 1; i <= uniqueInstruments; i++) {
	
		long instrHeaderSize = xmdata[fileOffset] + xmdata[fileOffset+1]*256 + xmdata[fileOffset+2]*256*256 + xmdata[fileOffset+3]*256*256*256;
		instrSampleAmount[i] = static_cast<unsigned char>(xmdata[fileOffset+27] + xmdata[fileOffset+28] * 256);
		
		if (instrSampleAmount[i]) {
		
			instrSmpMap[i] = new unsigned char[96];		
			for (int j = 33; j < 33+96; j++) instrSmpMap[i][j-33] = xmdata[fileOffset+j];
		}
		
		//TODO: volume and panning envs
		instrVolEnvUsed[i] = static_cast<bool>(xmdata[fileOffset+233] & 1);
		instrVolEnvLength[i] = xmdata[fileOffset+225]*4;
		
		instrVolEnvPoints[i] = NULL;
		if (instrVolEnvUsed[i]) {
			instrVolEnvPoints[i] = new unsigned char[instrVolEnvLength[i]];
			for (int j = 0; j < instrVolEnvLength[i]; j++) {
				instrVolEnvPoints[i][j] = xmdata[fileOffset + 129 + j];
//				cout << "file offset: " << fileOffset + 129 + j << " read: " << +instrVolEnvPoints[i][j] << endl;
			}
		}

		//print instrument name
		if (verbose) {
		
			cout << hex << "0x" << i << "\t0x" << fileOffset << "\t";
		
			for (int j = 4; j < 22+4; j++) {

					if (xmdata[fileOffset+j] != 0) cout << xmdata[fileOffset+j];
					else cout << " ";
			}
		}
		
		fileOffset += instrHeaderSize;

		
		if (!instrSampleAmount[i]) {
				
			if (verbose) cout << dec << "\t-\n";
		}
		else {
			if (verbose) cout << dec << "\t" << +instrSampleAmount[i] << "\t";
		
			instrSmpLengths[i] = new long[instrSampleAmount[i]];
			instrSmpRelNotes[i] = new char[instrSampleAmount[i]];
			instrSmp16Bit[i] = new bool[instrSampleAmount[i]];
			instrSmpLoopType[i] = new unsigned char[instrSampleAmount[i]];
			instrSmpLoopStart[i] = new long[instrSampleAmount[i]];
			instrSmpLoopLength[i] = new long[instrSampleAmount[i]];
			instrRawSamples[i] = new char *[instrSampleAmount[i]];
			instrSamples[i] = new short *[instrSampleAmount[i]];
			
			for (int j = 0; j < instrSampleAmount[i]; j++) {
			
				instrSmpLengths[i][j] = xmdata[fileOffset] + xmdata[fileOffset+1]*256 + xmdata[fileOffset+2]*256*256 + xmdata[fileOffset+3]*256*256*256;
				instrSmpLoopStart[i][j] = xmdata[fileOffset+4] + xmdata[fileOffset+5]*256 + xmdata[fileOffset+6]*256*256 + xmdata[fileOffset+7]*256*256*256;
				instrSmpLoopLength[i][j] = xmdata[fileOffset+8] + xmdata[fileOffset+9]*256 + xmdata[fileOffset+10]*256*256 + xmdata[fileOffset+11]*256*256*256;
				
				instrSmpLoopType[i][j] = xmdata[fileOffset+14] & 3;
				
				instrSmpRelNotes[i][j] = static_cast<char>(xmdata[fileOffset+16]);
				
				if (xmdata[fileOffset+14] & 16) instrSmp16Bit[i][j] = true;
				else instrSmp16Bit[i][j] = false;
				
				if (verbose) {
					
					//print sample name
					for (long k = 18; k < 40; k++) {
					
						if (xmdata[fileOffset+k] != 0) cout << xmdata[fileOffset+k];
 						else cout << " ";
					}
					
					cout << hex << "\t0x" << instrSmpLengths[i][j] << "\t\t";
					cout << dec << +instrSmpRelNotes[i][j] << hex << "\t";
					
					if (instrSmp16Bit[i][j]) cout << "yes\t";
					else cout << "no\t";
					
					cout << "0x" << instrSmpLoopStart[i][j] << "\t\t0x" << instrSmpLoopLength[i][j] << "\t\t";
					
					if (instrSmpLoopType[i][j] == 0) cout << "none";
					else if (instrSmpLoopType[i][j] == 1) cout << "forward";
					else if (instrSmpLoopType[i][j] == 2) cout << "ping-pong";
					
					if (j < instrSampleAmount[i]-1) cout << "\n\t\t\t\t\t\t";
					else cout << endl;
				}
			
				fileOffset += 40;				
			}
			
			
			
			for (int j = 0; j < instrSampleAmount[i]; j++) {
			
				instrRawSamples[i][j] = new char[instrSmpLengths[i][j]];

				if (instrSmp16Bit[i][j]) instrSamples[i][j] = new short[static_cast<long>(instrSmpLengths[i][j]/2)];
				else instrSamples[i][j] = new short[instrSmpLengths[i][j]];
				
				
				
				for (long k = 0; k < instrSmpLengths[i][j]; k++) {
				
					instrRawSamples[i][j][k] = static_cast<char>(xmdata[fileOffset]);
					fileOffset++;
				}				
			}
			
						
		}
	}
	
	convertToPCM();

	return true;
}



bool xmod::convertToPCM() {

	for (int instr = 1; instr <= uniqueInstruments; instr++) {
	
		for (int sample = 0; sample < instrSampleAmount[instr]; sample++) {
		
			short prev = 0;
			
			if (!instrSmp16Bit[instr][sample]) {
			
				for (long i = 0; i < instrSmpLengths[instr][sample]; i++) {
				
					instrSamples[instr][sample][i] = static_cast<int>(instrRawSamples[instr][sample][i] + prev);
					prev = instrSamples[instr][sample][i];
				}
			}
			else {

				for (long i = 0; i < instrSmpLengths[instr][sample]; i+=2)
					instrSamples[instr][sample][static_cast<long>(i/2)] = (static_cast<short int>(instrRawSamples[instr][sample][i+1])<<8) 
												| (instrRawSamples[instr][sample][i] & 0xff);

				instrSmpLengths[instr][sample] = static_cast<long>(instrSmpLengths[instr][sample]/2);
				
				for (long i = 0; i < instrSmpLengths[instr][sample]; i++) {
					
					//TODO: loosing precision, add overflow?
					instrSamples[instr][sample][i] = instrSamples[instr][sample][i] + prev;
					prev = instrSamples[instr][sample][i];
				}
				
				instrSmpLoopStart[instr][sample] = static_cast<long>(instrSmpLoopStart[instr][sample]/2);
				instrSmpLoopLength[instr][sample] = static_cast<long>(instrSmpLoopLength[instr][sample]/2);				
			}			
		}	
	}

	return true;
}



bool xmod::convertSamples(unsigned resolution, long rate, bool unsignedData) {

	return true;
}



int xmod::limitNoteRange(unsigned char lowerLimit, unsigned char upperLimit, unsigned char replaceValue) {

	int errorCount = 0;
	
	for (int ptn = 0; ptn < uniquePtns; ptn++) {
	
		for (int ch = 0; ch < channels; ch++) {
		
			for (int row = 1; row < ptnLengths[ptn]; row++) {
			
				if ((ptnNotes[ptn][ch][row] < lowerLimit) || (ptnNotes[ptn][ch][row] > upperLimit)) {
				
					ptnNotes[ptn][ch][row] = 0;
					if (ptnTriggers[ptn][ch][row] != 0) {
					
						errorCount++;
						cout << hex << "Warning: Out-of-range note in pattern 0x" << ptn << ", channel 0x" << ch+1 << ", row 0x" << row-1
						   << " replaced with a rest\n";
					}
				}
			}
		}
	}	
	
	return errorCount;
}



bool xmod::isPtnUsed(unsigned char ptn) {

	bool usage = false;
	
	for (int i = 0; i < seqLength; i++) {
	
		if (sequence[i] == ptn) usage = true;
	}

	return usage;
}



bool xmod::isInstrumentUsed(unsigned char instrument) {

	bool usage = false;
	
	for (int ptn = 0; ptn < uniquePtns; ptn++) {
	
		for (int ch = 0; ch < chUsed; ch++) {
		
			for (int row = 1; row <= ptnLengths[ptn]; row++) {
			
				if (ptnInstruments[ptn][ch][row] == instrument) usage = true;
			}
		}
	}

	return usage;
}



//void xmod::initialize() {
xmod::xmod() {

	//cout << "default constructor called, yay!\n";
	xmdata = NULL;
	ptnOffsetList = NULL;
	ptnLengths = NULL;
	sequence = NULL;
	ptnNotes = NULL;
	ptnTriggers = NULL;
	ptnInstruments = NULL;
	ptnVolumes = NULL;
	ptnFxCmds = NULL;
	ptnFxParams = NULL;
	ptnRowSpeeds = NULL;
	ptnRowBpms = NULL;
	ptnDetune = NULL;
	
	instrOffsetList = NULL;
	instrSampleAmount = NULL;
	instrRawSamples = NULL;
	instrSamples = NULL;
	instrSmpLengths = NULL;
	instrSmpMap = NULL;
	instrSmpRelNotes = NULL;
	instrSmp16Bit = NULL;
	instrSmpLoopType = NULL;
	instrSmpLoopStart = NULL;
	instrSmpLoopLength = NULL;
	
	instrVolEnvUsed = NULL;
	instrVolEnvLength = NULL;
	instrVolEnvPoints = NULL;
}

//void xmod::cleanup() {
xmod::~xmod() {

	//cout << "default deconstructor called, yay!\n";

	delete[] xmdata;
	xmdata = NULL;
	delete[] ptnOffsetList;
	ptnOffsetList = NULL;
	delete[] ptnLengths;
	ptnLengths = NULL;
	delete[] sequence;
	sequence = NULL;
	
	for (int i = 0; i < uniquePtns; i++) {
	
		for (int j = 0; j < channels; j++) {		//TODO: must set all this crap to NULL as well
		
			delete[] ptnNotes[i][j];
			delete[] ptnTriggers[i][j];
			delete[] ptnInstruments[i][j];
			delete[] ptnVolumes[i][j];
			delete[] ptnFxCmds[i][j];
			delete[] ptnFxParams[i][j];
			delete[] ptnDetune[i][j];
			
			ptnNotes[i][j] = NULL;
			ptnTriggers[i][j] = NULL;
			ptnInstruments[i][j] = NULL;
			ptnVolumes[i][j] = NULL;
			ptnFxCmds[i][j] = NULL;
			ptnFxParams[i][j] = NULL;
			ptnDetune[i][j] = NULL;
			
		}
		
		delete[] ptnNotes[i];
		delete[] ptnTriggers[i];
		delete[] ptnInstruments[i];
		delete[] ptnVolumes[i];
		delete[] ptnFxCmds[i];
		delete[] ptnFxParams[i];
		delete[] ptnRowSpeeds[i];
		delete[] ptnRowBpms[i];
		delete[] ptnDetune[i];
		
		ptnNotes[i] = NULL;
		ptnTriggers[i] = NULL;
		ptnInstruments[i] = NULL;
		ptnVolumes[i] = NULL;
		ptnFxCmds[i] = NULL;
		ptnFxParams[i] = NULL;
		ptnRowSpeeds[i] = NULL;
		ptnRowBpms[i] = NULL;
		ptnDetune[i] = NULL;
	}
	
	
	
	delete[] instrOffsetList;
	instrOffsetList = NULL;
	delete[] instrSampleAmount;
	instrSampleAmount = NULL;
	delete[] instrRawSamples;
	instrRawSamples = NULL;
	delete[] instrSamples;
	instrSamples = NULL;
	delete[] instrSmpLengths;
	instrSmpLengths = NULL;
	delete[] instrSmpMap;
	instrSmpMap = NULL;
	delete[] instrSmpRelNotes;
	instrSmpRelNotes = NULL;
	delete[] instrSmp16Bit;
	instrSmp16Bit = NULL;
	delete[] instrSmpLoopType;
	instrSmpLoopType = NULL;
	delete[] instrSmpLoopStart;
	instrSmpLoopStart = NULL;
	delete[] instrSmpLoopLength;
	instrSmpLoopLength = NULL;
	
	for (int i = 1; i <= uniqueInstruments; i++) {
		if (instrVolEnvUsed[i]) {
			delete[] instrVolEnvPoints[i];
			instrVolEnvPoints[i] = NULL;
		}
	}
	delete[] instrVolEnvUsed;
	instrVolEnvUsed = NULL;
	delete[] instrVolEnvUsed;
	instrVolEnvLength = NULL;
	delete[] instrVolEnvPoints;
	instrVolEnvPoints = NULL;
	
	
	delete[] ptnNotes;
	delete[] ptnTriggers;
	delete[] ptnInstruments;
	delete[] ptnVolumes;
	delete[] ptnFxCmds;
	delete[] ptnFxParams;
	delete[] ptnRowSpeeds;
	delete[] ptnRowBpms;
	delete[] ptnDetune;
	
	ptnNotes = NULL;
	ptnTriggers = NULL;
	ptnInstruments = NULL;
	ptnVolumes = NULL;
	ptnFxCmds = NULL;
	ptnFxParams = NULL;
	ptnRowSpeeds = NULL;
	ptnRowBpms = NULL;
	ptnDetune = NULL;
}