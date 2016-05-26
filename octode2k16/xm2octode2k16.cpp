#include <iostream>
#include <fstream>
#include <string>
#include <cstdint>

using namespace std;

unsigned char songlength;
int16_t maxRows = -1;
bool verbose = false;
uint8_t *xmdata = NULL;
uint16_t notes[257][8];
uint16_t noteRows[1936][8];
ifstream XMFILE;
ofstream ASMFILE;

bool isPatternUsed(int patnum);
bool verifyXMParams(uint8_t numberOfChannels);
uint16_t assignNoteRow(int row);

int main(int argc, char *argv[]){

	cout << "XM 2 OCTODE2k16 CONVERTER\n";
	
	//check for "-v" flag
	string arg = "";
	if (argc > 1) arg = argv[1];
	if (arg == "-v") verbose = true;
	
	//create music.asm
	ASMFILE.open ("music.asm", ios::out | ios::trunc);
	if (!ASMFILE.is_open()) {
		cout << "Error: Could not create music.asm - need to set write permission?\n";
		return -1;
	}
	
	//open music.xm
	XMFILE.open ("music.xm", ios::in | ios::binary);
	if (!XMFILE.is_open()) {
		cout << "Error: Could not open music.xm\n";
		return -1;
	}
	
	//get filesize
	XMFILE.seekg(0,ios_base::end);
	int32_t filesize = XMFILE.tellg();
	
	//read XM file into array
	xmdata = new uint8_t[filesize];
	char cp;
	
	for (int32_t i = 0; i < filesize; i++) {
		XMFILE.seekg(i, ios::beg);
		XMFILE.read((&cp), 1);
		xmdata[i] = static_cast<uint8_t>(cp);
	}
	
	XMFILE.close();
	

	//verify XM parameters
	if (!verifyXMParams(10)) return -1;
	
	//read global song parameters
	uint8_t uniqueptns = xmdata[70];
	uint16_t xmHeaderLength = (xmdata[61]<<8) + xmdata[60];
	songlength = xmdata[64];
	
	if (verbose) {
		cout << "song length: " << +xmdata[64] << "\nunique patterns: " << +xmdata[70] << "\nglobal speed: " << +xmdata[76] << endl;
		cout << "XM header length: " << +xmHeaderLength << endl;
	}
	
	//locate the pattern headers and read pattern lengths
	uint16_t ptnOffsetList[256], ptnLengths[256];
	int32_t fileOffset = xmHeaderLength + 60;
	
	ptnOffsetList[0] = xmHeaderLength + 60;
	
	for (int i = 0; i < uniqueptns; i++) {
		
 		ptnLengths[i] = xmdata[fileOffset+5];
		ptnOffsetList[i+1] = ptnOffsetList[i] + xmdata[fileOffset] + xmdata[fileOffset+7] + (xmdata[fileOffset+8]<<8);
		fileOffset = fileOffset + xmdata[fileOffset+7] + (xmdata[fileOffset+8]<<8) + 9;
		
		if (verbose) cout << "pattern " << i << " starts at " << ptnOffsetList[i] << ", length " << ptnLengths[i] << " rows\n";
	
	}
	
	
	//generate pattern sequence
	uint8_t sequence[songlength];
	if (verbose) cout << "song sequence: ";
	for (fileOffset = 80; fileOffset < static_cast<uint8_t>(songlength+80); fileOffset++) {
		
		sequence[fileOffset-80] = xmdata[fileOffset];
		if (verbose) cout << " - " << +sequence[fileOffset-80];
	
	}
	if (verbose) cout << endl;
	
 	//define note value arrays
	const uint16_t notetab[85] = { 0,
		0x100, 0x10F, 0x11F, 0x130, 0x142, 0x155, 0x16A, 0x17F, 0x196, 0x1AE, 0x1C8, 0x1E3,
		0x200, 0x21E, 0x23F, 0x261, 0x285, 0x2AB, 0x2D4, 0x2FF, 0x32D, 0x35D, 0x390, 0x3C7,
		0x400, 0x43D, 0x47D, 0x4C2, 0x50A, 0x557, 0x5A8, 0x5FE, 0x65A, 0x6BA, 0x721, 0x78D,
		0x800, 0x87A, 0x8FB, 0x984, 0xA14, 0xAAE, 0xB50, 0xBFD, 0xCB3, 0xD74, 0xE41, 0xF1A,
		0x1000, 0x10F4, 0x11F6, 0x1307, 0x1429, 0x155C, 0x16A1, 0x17F9, 0x1966, 0x1AE9, 0x1C82, 0x1E34,
		0x2000, 0x21E7, 0x23EB, 0x260E, 0x2851, 0x2AB7, 0x2D41, 0x2FF2, 0x32CC, 0x35D1, 0x3905, 0x3C68,
		0x4000, 0x43CE, 0x47D6, 0x4C1C, 0x50A3, 0x556E, 0x5A83, 0x5FE4, 0x6598, 0x6BA3, 0x7209, 0x78D1 };


 	//convert pattern data
	uint8_t ctrlb, temp;
	int dch;
	uint8_t noteVals[257][8];
	int16_t loopPoint = 0;
	uint8_t pSpeeds[uniqueptns][257];
	uint8_t pDrums[uniqueptns][257];	//0 = no drum, 1..0x80 noise/vol, >0x80 = kick
	uint8_t pDrumTrigs[uniqueptns][257];
	uint16_t pRowPntr[uniqueptns][257];	//row pointers
	
	uint8_t detune[8] = { 8, 8, 8, 8, 8, 8, 8, 8 };
 	
 	for (int ptn = 0; ptn < uniqueptns; ptn++) {
	
		if (isPatternUsed(ptn)) {
		
			fileOffset = ptnOffsetList[ptn] + 9;
			
			noteVals[0][0] = 0;
			noteVals[0][1] = 0;
			noteVals[0][2] = 0;
			noteVals[0][3] = 0;
			noteVals[0][4] = 0;
			noteVals[0][5] = 0;
			noteVals[0][6] = 0;
			noteVals[0][7] = 0;
			
			notes[0][0] = 0;
			notes[0][1] = 0;
			notes[0][2] = 0;
			notes[0][3] = 0;
			notes[0][4] = 0;
			notes[0][5] = 0;
			notes[0][6] = 0;
			notes[0][7] = 0;
			
			pSpeeds[ptn][0] = xmdata[76];
			pDrums[ptn][0] = 0;
			pDrumTrigs[ptn][0] = 0;
			
 			for (int row = 1; row <= ptnLengths[ptn]; row++) {
			
				detune[0] = 8;
				detune[1] = 8;
				detune[2] = 8;
				detune[3] = 8;
				detune[4] = 8;
				detune[5] = 8;
				detune[6] = 8;
				detune[7] = 8;
			
				noteVals[row][0] = noteVals[row-1][0];
				noteVals[row][1] = noteVals[row-1][1];
				noteVals[row][2] = noteVals[row-1][2];
				noteVals[row][3] = noteVals[row-1][3];
				noteVals[row][4] = noteVals[row-1][4];
				noteVals[row][5] = noteVals[row-1][5];
				noteVals[row][6] = noteVals[row-1][6];
				noteVals[row][7] = noteVals[row-1][7];
				
				notes[row][0] = notetab[noteVals[row-1][0]];
				notes[row][1] = notetab[noteVals[row-1][1]];
				notes[row][2] = notetab[noteVals[row-1][2]];
				notes[row][3] = notetab[noteVals[row-1][3]];
				notes[row][4] = notetab[noteVals[row-1][4]];
				notes[row][5] = notetab[noteVals[row-1][5]];
				notes[row][6] = notetab[noteVals[row-1][6]];
				notes[row][7] = notetab[noteVals[row-1][7]];
				
				pSpeeds[ptn][row] = pSpeeds[ptn][row-1];
				pDrums[ptn][row] = 0;
				pDrumTrigs[ptn][row] = 0;
				dch = 0xff;
			
			 				
 				for (int ch = 0; ch < 10; ch++) {
				
					ctrlb = xmdata[fileOffset];
 					
 					if (ctrlb >= 0x80) {		//have compressed pattern data
 					
						fileOffset++;
 						
 						if (ctrlb != 128) {

							temp = xmdata[fileOffset];
 							
 							if ((ctrlb & 1) == 1) {		//if bit 0 is set, it's note -> counter val.		
 					
 								if (temp == 97) temp = 0;		//silence
								
								if ((ch < 8) && (temp > 84)) {
									cout << "Warning: Out-of-range note in pattern " << +ptn << ", channel " << +ch << " replaced with a rest.\n";
									temp = 0;
								}
								if (ch < 8) noteVals[row][ch] = temp;
								
								fileOffset++;
 							}
							
							temp = 0;
 							
 							if ((ctrlb&2) == 2) {				//if bit 1 is set, it's instrument

								if ((ch < 8) && (xmdata[fileOffset] > 1)) noteVals[row][ch] = 0;
								if ((pDrumTrigs[ptn][row]) && (xmdata[fileOffset] > 1)) cout << "Warning: More than one drum in pattern " << +ptn << ", channel " << +ch << endl;
								if (xmdata[fileOffset] == 2) pDrumTrigs[ptn][row] = 4;		//kick
								if (xmdata[fileOffset] == 3) pDrumTrigs[ptn][row] = 0x80;	//snare
								if (xmdata[fileOffset] == 4) pDrumTrigs[ptn][row] = 1;		//hihat
								
								if (xmdata[fileOffset] > 1) pDrums[ptn][row] = 0x80;
								dch = ch;
								
								fileOffset++;
 							}
 							
 							if ((ctrlb&4) == 4) {				//if bit 2 is set, it's volume (applies to noise drum only)
								
								if (dch == ch) {
									pDrums[ptn][row] = (xmdata[fileOffset]-0x10) * 2;
								}
								
 								fileOffset++;

 							}
							
							if ((ctrlb&8) == 8) {				//if bit 3 is set, it's an fx command
								
								temp = xmdata[fileOffset];
								
								fileOffset++;
							
							}
							
							if ((ctrlb&16) == 16) {				//if bit 4 is set, it's an fx parameter
							
								//Bxx
								if (temp == 0xb) loopPoint = xmdata[fileOffset];
								//E5x
								if ((temp == 0xe) && ((xmdata[fileOffset] & 0xf0) == 0x50) && (ch < 8)) detune[ch] = xmdata[fileOffset] & 0xf;
								//Fxx
								if ((temp == 0xf) && (xmdata[fileOffset] < 0x20)) pSpeeds[ptn][row] = xmdata[fileOffset];
								
								fileOffset++;
							
							}
 						}  						
 					} else {			//uncompressed pattern data
						
 						//read notes
 						temp = ctrlb;
 						if (temp == 97) temp = 0;		//silence
						
						if ((ch < 8) && (temp > 84)) {
							cout << "Warning: Out-of-range note in pattern " << +ptn << ", channel " << +ch << " replaced with a rest.\n";
							temp = 0;
						}
						
						if (ch < 8) noteVals[row][ch] = temp;
						
						fileOffset++;
						
						//read instruments
						if ((ch < 8) && (xmdata[fileOffset] > 1)) noteVals[row][ch] = 0;
						if ((pDrumTrigs[ptn][row]) && (xmdata[fileOffset] > 1)) cout << "Warning: More than one drum in pattern " << +ptn << ", channel " << +ch << endl;
						if (xmdata[fileOffset] == 2) pDrumTrigs[ptn][row] = 4;		//kick
						if (xmdata[fileOffset] == 3) pDrumTrigs[ptn][row] = 0x80;	//snare
						if (xmdata[fileOffset] == 4) pDrumTrigs[ptn][row] = 1;		//hihat
						
						if (xmdata[fileOffset] > 1) pDrums[ptn][row] = 0x80;
						dch = ch;
						
						fileOffset++;
						
						//read volume
						if (dch == ch) pDrums[ptn][row] = (xmdata[fileOffset]-0x10) * 2;
						
						fileOffset++;
					
						//read fx command
						temp = xmdata[fileOffset];
								
						fileOffset++;
						
						//read fx parameter
						//Bxx
						if (temp == 0xb) loopPoint = xmdata[fileOffset];
						//E5x
						if ((temp == 0xe) && ((xmdata[fileOffset] & 0xf0) == 0x50) && (ch < 8)) detune[ch] = xmdata[fileOffset] & 0xf;
						//Fxx
						if ((temp == 0xf) && (xmdata[fileOffset] < 0x20)) pSpeeds[ptn][row] = xmdata[fileOffset];
						
						fileOffset++; 															
 					}
 				}
				
				
				for (int ch = 0; ch < 8; ch++) {
					notes[row][ch] = notetab[noteVals[row][ch]];
					notes[row][ch] = notes[row][ch] - static_cast<uint16_t>(notes[row][ch]*(8-detune[ch])/100);
				}

				pRowPntr[ptn][row] = assignNoteRow(row);
				if (pRowPntr[ptn][row] > 1935) {
					cout << "Error: Song too large.\n";
					delete[] xmdata;
					xmdata = NULL;
					return -1;
				}			
 			}		
		}	
	}



	//construct music.asm
	ASMFILE << ";sequence\n";
	
	//print sequence
	for (int i = 0; i < songlength; i++) {
		if (i == loopPoint) ASMFILE << "loop\n";
		ASMFILE << "\tdw ptn" << hex << +sequence[i] << endl;
	}
	ASMFILE << "\tdw 0\n\n";
	
	//print patterns
	for (int i = 0; i < uniqueptns; i++) {
		
		if (isPatternUsed(i)) {
		
			ASMFILE << "ptn" << hex << +i << endl;
			
			for (int j = 1; j <= ptnLengths[i]; j++) {
			
				ASMFILE << "\tdw #" << +pSpeeds[i][j];
				if (pDrumTrigs[i][j] != 0x80) ASMFILE << "0";
				ASMFILE << +pDrumTrigs[i][j] << ",";
				if (pDrumTrigs[i][j]) ASMFILE << "#00" << hex << +pDrums[i][j] << ",";
				ASMFILE << "row" << hex << pRowPntr[i][j] << endl;
			}
			
			ASMFILE << "\tdb #40\n\n";		
		}	
	}
	
	
	//print row buffers
	ASMFILE << "\n\n;row buffers\n";
	for (int i = 0; i <= maxRows; i++) {
	
		ASMFILE << "row" << hex << +i << "\tdw ";
		for (int j = 0; j < 8; j++) {
		
			ASMFILE << "#" << +noteRows[i][j];
			if (j == 7) ASMFILE << endl;
			else ASMFILE << ",";
		}
	}



 	cout << "Success!\n";

	delete[] xmdata;
	xmdata = NULL;
	ASMFILE.close();
	return 0;
}


//return the number of the row buffer that represents the current row of the current pattern, creating a new row buffer if necessary
uint16_t assignNoteRow(int row) {

	int assign = 0;
	bool matchFound = false;
	
	
	while (assign < maxRows && !matchFound) {
	
		assign++;
		if (assign > 1935) return assign;
		
		if (noteRows[assign][0] == notes[row][0] && noteRows[assign][1] == notes[row][1] && noteRows[assign][2] == notes[row][2]
		&& noteRows[assign][3] == notes[row][3] && noteRows[assign][4] == notes[row][4] && noteRows[assign][5] == notes[row][5]
		&& noteRows[assign][6] == notes[row][6] && noteRows[assign][7] == notes[row][7]) matchFound = true;	
	}
	
	if (!matchFound) {
		
		maxRows++;
		assign = maxRows;
		for (int i = 0; i < 8; i++) {
			noteRows[assign][i] = notes[row][i];
		}
	
	}

	return assign;
}

//verify XM parameters
bool verifyXMParams(uint8_t numberOfChannels) {

	char tbuf[16];
	const string xmheader = "Extended Module:";
	bool xmValid = true;
	
	xmheader.copy(tbuf, 16, 0);
	
	for (int i = 0; i < 16; i++) {	
		if (tbuf[i] != static_cast<char>(xmdata[i])) xmValid = false;	
	}
	
	if (!xmValid) {
		cout << "Error: Not a valid XM file.\n";
		delete[] xmdata;
		xmdata = NULL;
		return false;
	}
	
	if (xmdata[58] != 4) {
		cout << "Error: Obsolete XM version 1.0" << +xmdata[58] << ", v1.04 required." << endl;
		delete[] xmdata;
		xmdata = NULL;
		return false;
	}
	
	if (xmdata[68] != numberOfChannels) {
		cout << "Error: XM has " << +xmdata[68] << " channels instead of " << +numberOfChannels << ".\n";
		delete[] xmdata;
		xmdata = NULL;
		return false;
	}

	return true;
}


//check if a pattern exists in sequence
bool isPatternUsed(int patnum) {

bool usage = false;

	for (int32_t fileOffset = 80; fileOffset < static_cast<int32_t>(songlength + 80); fileOffset++) {
		if (patnum == xmdata[fileOffset]) usage = true;
	}

	return(usage);
}