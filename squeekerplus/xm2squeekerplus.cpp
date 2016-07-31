
#include <iostream>
#include <string>
#include <fstream>

#include "xmkit.h"

using namespace std;


int main(int argc, char *argv[]){

	const long noiseInstr = 0x9500;
	const long slideInstr = 0xa00;

	cout << "XM 2 SQUEEKER PLUS CONVERTER\n";

	bool verbose = false;
	string infile = "music.xm";

	for (int i = 1; i < argc; i++) {
	
		string arg = argv[i];
		if (arg == "-v") verbose = true;
		if (arg == "-i" && i < argc-1) infile = argv[i+1];
	}
	
	xmod xm;

	if (!xm.read(infile, 6, verbose)) return -1;
	
	const unsigned notetab[85] = { 0,
		0x100, 0x10F, 0x11F, 0x130, 0x142, 0x155, 0x16A, 0x17F, 0x196, 0x1AE, 0x1C8, 0x1E3,
		0x200, 0x21E, 0x23F, 0x261, 0x285, 0x2AB, 0x2D4, 0x2FF, 0x32D, 0x35D, 0x390, 0x3C7,
		0x400, 0x43D, 0x47D, 0x4C2, 0x50A, 0x557, 0x5A8, 0x5FE, 0x65A, 0x6BA, 0x721, 0x78D,
		0x800, 0x87A, 0x8FB, 0x984, 0xA14, 0xAAE, 0xB50, 0xBFD, 0xCB3, 0xD74, 0xE41, 0xF1A,
		0x1000, 0x10F4, 0x11F6, 0x1307, 0x1429, 0x155C, 0x16A1, 0x17F9, 0x1966, 0x1AE9, 0x1C82, 0x1E34,
		0x2000, 0x21E7, 0x23EB, 0x260E, 0x2851, 0x2AB7, 0x2D41, 0x2FF2, 0x32CC, 0x35D1, 0x3905, 0x3C68,
		0x4000, 0x43CE, 0x47D6, 0x4C1C, 0x50A3, 0x556E, 0x5A83, 0x5FE4, 0x6598, 0x6BA3, 0x7209, 0x78D1 };
	

	ofstream ASMFILE;
	ASMFILE.open ("music.asm", ios::out | ios::trunc);
	if (!ASMFILE.is_open()) {
		cout << "Error: Could not create music.asm - need to set write permission?\n";
		return -1;
	}
	
	ofstream ENVFILE;
	ENVFILE.open ("envelopes.asm", ios::out | ios::trunc);
	if (!ASMFILE.is_open()) {
		cout << "Error: Could not create envelopes.asm - need to set write permission?\n";
		return -1;
	}
	
	xm.extractPatterns();
	xm.extractInstruments(verbose);
	
	bool isVolUsed[0x41] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
				 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
				 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
				 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 };
				 
	for (int ptn = 0; ptn < xm.uniquePtns; ptn++) {
		for (int ch = 0; ch < 4; ch++) {
			for (int row = 1; row <= xm.ptnLengths[ptn]; row++) {
				if (xm.ptnVolumes[ptn][ch][row] >= 0x10 && xm.ptnVolumes[ptn][ch][row] <= 0x50) 
				     isVolUsed[xm.ptnVolumes[ptn][ch][row] - 0x10] = true;
			}
		}
	}
	
	ASMFILE << "\n\t\t\t;sequence\n";
	
	for (int i = 0; i < xm.seqLength; i++) {
		
		if (i == xm.loopPoint) ASMFILE << "loop\n";
		ASMFILE << hex << "\tdw ptn" << +xm.sequence[i] << endl;
	}
	
	ASMFILE << "\tdw 0\n\n\t\t\t;patterns\n";
	
	for (int ptn = 0; ptn < xm.uniquePtns; ptn++) {
	
		if (xm.isPtnUsed(ptn)) {
		
			ASMFILE << "ptn" << ptn << endl;
		
			for (int row = 1; row <= xm.ptnLengths[ptn]; row++) {
			
				unsigned char ctrlA = 0;
				unsigned char ctrlB = 0;
				bool noise1 = false;
				bool noise2 = false;
				
				//TODO: fix volumes!
				if (xm.ptnTriggers[ptn][0][row]) xm.ptnVolumes[ptn][0][row] = xm.ptnVolumes[ptn][0][row-1];
				if (xm.ptnTriggers[ptn][1][row]) xm.ptnVolumes[ptn][1][row] = xm.ptnVolumes[ptn][1][row-1];
				if (xm.ptnTriggers[ptn][2][row]) xm.ptnVolumes[ptn][2][row] = xm.ptnVolumes[ptn][2][row-1];
				if (xm.ptnTriggers[ptn][3][row]) xm.ptnVolumes[ptn][3][row] = xm.ptnVolumes[ptn][3][row-1];
				
				if (xm.ptnInstruments[ptn][0][row] == xm.ptnInstruments[ptn][0][row-1] && xm.ptnNotes[ptn][0][row] == xm.ptnNotes[ptn][0][row-1]
				     && (xm.ptnVolumes[ptn][0][row] == xm.ptnVolumes[ptn][0][row-1] || xm.instrVolEnvUsed[xm.ptnInstruments[ptn][0][row]]) && !xm.ptnTriggers[ptn][0][row])
				       ctrlA |= 1;
				if (xm.ptnInstruments[ptn][1][row] == xm.ptnInstruments[ptn][1][row-1] && xm.ptnNotes[ptn][1][row] == xm.ptnNotes[ptn][1][row-1]
				     && (xm.ptnVolumes[ptn][1][row] == xm.ptnVolumes[ptn][1][row-1] || xm.instrVolEnvUsed[xm.ptnInstruments[ptn][1][row]]) && !xm.ptnTriggers[ptn][1][row])
				       ctrlA |= 4;
				if (xm.ptnInstruments[ptn][2][row] == xm.ptnInstruments[ptn][2][row-1] && xm.ptnNotes[ptn][2][row] == xm.ptnNotes[ptn][2][row-1]
				     && (xm.ptnVolumes[ptn][2][row] == xm.ptnVolumes[ptn][2][row-1] || xm.instrVolEnvUsed[xm.ptnInstruments[ptn][2][row]]) && !xm.ptnTriggers[ptn][2][row])
				       ctrlA |= 0x80;
				
				if (xm.ptnInstruments[ptn][3][row] == xm.ptnInstruments[ptn][3][row-1] && xm.ptnNotes[ptn][3][row] == xm.ptnNotes[ptn][3][row-1]
				     && (xm.ptnVolumes[ptn][3][row] == xm.ptnVolumes[ptn][3][row-1] || xm.instrVolEnvUsed[xm.ptnInstruments[ptn][3][row]]) && !xm.ptnTriggers[ptn][3][row])
				       ctrlB |= 0x40;
				       
				if ((xm.ptnInstruments[ptn][4][row] == 1 && xm.ptnTriggers[ptn][4][row]) || (xm.ptnInstruments[ptn][5][row] == 1 && xm.ptnTriggers[ptn][5][row])) ctrlB |= 4;
				if ((xm.ptnInstruments[ptn][4][row] == 2 && xm.ptnTriggers[ptn][4][row]) || (xm.ptnInstruments[ptn][5][row] == 2 && xm.ptnTriggers[ptn][5][row])) ctrlB |= 0x80;

				
				if (xm.ptnInstruments[ptn][0][row] && xm.instrSmpLengths[xm.ptnInstruments[ptn][0][row]][0] == noiseInstr) noise1 = true;
				if (xm.ptnInstruments[ptn][1][row] && xm.instrSmpLengths[xm.ptnInstruments[ptn][1][row]][0] == noiseInstr) noise2 = true;
				if (xm.ptnInstruments[ptn][2][row] && xm.instrSmpLengths[xm.ptnInstruments[ptn][2][row]][0] == noiseInstr) 
				   cout << "WARNING: Noise instrument used in wrong channel at pattern " << +ptn << ", row " << +row << ", channel 3\n";
				if (xm.ptnInstruments[ptn][3][row] && xm.instrSmpLengths[xm.ptnInstruments[ptn][3][row]][0] == noiseInstr)
				   cout << "WARNING: Noise instrument used in wrong channel at pattern " << +ptn << ", row " << +row << ", channel 4\n";
				if (xm.ptnInstruments[ptn][3][row] && xm.instrSmpLengths[xm.ptnInstruments[ptn][3][row]][0] == slideInstr) ctrlB |= 1;
				if (xm.ptnInstruments[ptn][0][row] && xm.instrSmpLengths[xm.ptnInstruments[ptn][0][row]][0] == slideInstr)
				   cout << "WARNING: Slide instrument used in wrong channel at pattern " << +ptn << ", row " << +row << ", channel 1\n";
				if (xm.ptnInstruments[ptn][1][row] && xm.instrSmpLengths[xm.ptnInstruments[ptn][1][row]][0] == slideInstr)
				   cout << "WARNING: Slide instrument used in wrong channel at pattern " << +ptn << ", row " << +row << ", channel 2\n";
				if (xm.ptnInstruments[ptn][2][row] && xm.instrSmpLengths[xm.ptnInstruments[ptn][2][row]][0] == slideInstr)
				   cout << "WARNING: Slide instrument used in wrong channel at pattern " << +ptn << ", row " << +row << ", channel 3\n";
				
				if (row == 1) {
					ctrlA = 0;
					ctrlB = ctrlB & 0xbf;
				}
				
				
				ASMFILE << hex << "\tdw #" << xm.ptnRowSpeeds[ptn][row] * 256 + ctrlA << ",#";
				
				if (noise1) ASMFILE << "cb";
				else ASMFILE << "00";
				if (noise2) ASMFILE << "cb,#";
				else ASMFILE << "00,#";
				
				if (!(ctrlA & 1)) {
					
					if (noise1) ASMFILE << "2175";
					else ASMFILE << notetab[xm.ptnNotes[ptn][0][row]];
					
					ASMFILE << ",env";
					if (!xm.ptnNotes[ptn][0][row]) ASMFILE << "0";
					else if (xm.ptnInstruments[ptn][0][row] && xm.instrVolEnvUsed[xm.ptnInstruments[ptn][0][row]]) ASMFILE << +xm.ptnInstruments[ptn][0][row];
					else if (xm.ptnVolumes[ptn][0][row] >= 0x10 && xm.ptnVolumes[ptn][0][row] <= 0x40) ASMFILE << "S_" << +xm.ptnVolumes[ptn][0][row] - 0x10;
					else ASMFILE << "S_40";
					ASMFILE << ",#";
				}
				
				if (!(ctrlA & 4)) {
					
					if (noise2) ASMFILE << "2175";
					else ASMFILE << notetab[xm.ptnNotes[ptn][1][row]];
					
					ASMFILE << ",env";
					if (!xm.ptnNotes[ptn][1][row]) ASMFILE << "0";
					else if (xm.ptnInstruments[ptn][1][row] && xm.instrVolEnvUsed[xm.ptnInstruments[ptn][1][row]]) ASMFILE << +xm.ptnInstruments[ptn][1][row];
					else if (xm.ptnVolumes[ptn][1][row] >= 0x10 && xm.ptnVolumes[ptn][1][row] <= 0x40) ASMFILE << "S_" << +xm.ptnVolumes[ptn][1][row] - 0x10;
					else ASMFILE << "S_40";
					ASMFILE << ",#";
				}
				
				if (!(ctrlA & 0x80)) {
				
					ASMFILE << notetab[xm.ptnNotes[ptn][2][row]];
					ASMFILE << ",env";
					if (!xm.ptnNotes[ptn][2][row]) ASMFILE << "0";
					else if (xm.ptnInstruments[ptn][2][row] && xm.instrVolEnvUsed[xm.ptnInstruments[ptn][2][row]]) ASMFILE << +xm.ptnInstruments[ptn][2][row];
					else if (xm.ptnVolumes[ptn][2][row] >= 0x10 && xm.ptnVolumes[ptn][2][row] <= 0x40) ASMFILE << "S_" << +xm.ptnVolumes[ptn][2][row] - 0x10;
					else ASMFILE << "S_40";
					ASMFILE << ",#";
				}
				
				ASMFILE << +ctrlB;
				
				if (!(ctrlB & 0x40)) {
					ASMFILE << ",#" << notetab[xm.ptnNotes[ptn][3][row]] << ",env";
					if (!xm.ptnNotes[ptn][3][row]) ASMFILE << "0";
					else if (xm.ptnInstruments[ptn][3][row] && xm.instrVolEnvUsed[xm.ptnInstruments[ptn][3][row]]) ASMFILE << +xm.ptnInstruments[ptn][3][row];
					else if (xm.ptnVolumes[ptn][3][row] >= 0x10 && xm.ptnVolumes[ptn][3][row] <= 0x40) ASMFILE << "S_" << +xm.ptnVolumes[ptn][3][row] - 0x10;
					else ASMFILE << "S_40";
				}
				
				ASMFILE << endl;	
			}
			
			ASMFILE << "\tdb #40\n\n";
		}
	}
	
	ASMFILE << "envelopes\n\tinclude \"envelopes.asm\"\n";
	
	//construct envelopes.asm
	for (int i = 1; i <= 0x40; i++) {
		if (isVolUsed[i]) ENVFILE << hex << "envS_" << i << "\tdb #" << i << ",#80\n";
	}
	
	ENVFILE << endl;
	
	for (int i = 1; i <= xm.uniqueInstruments; i++) {
		if (xm.isInstrumentUsed(i) && xm.instrVolEnvUsed[i]) {
			
			ENVFILE << hex << "env" << i;
			for (int j = 0; j < static_cast<int>(xm.instrVolEnvLength[i]/4) - 1; j++) {
				  
				 long steplength = (xm.instrVolEnvPoints[i][j*4+4] + xm.instrVolEnvPoints[i][j*4+5]*0x100)
							- (xm.instrVolEnvPoints[i][j*4] + xm.instrVolEnvPoints[i][j*4+1]*0x100);
				 float stepchange = static_cast<float>(xm.instrVolEnvPoints[i][j*4+6] - xm.instrVolEnvPoints[i][j*4+2]) / static_cast<float>(steplength-1);
				 unsigned char startval = xm.instrVolEnvPoints[i][j*4+2];
				 float startvalF = startval;
				 
				 for (long k = 0; k < steplength; k++) {
				 
					if (!(k & 0x1f)) ENVFILE << "\n\tdb ";
					ENVFILE << hex << "#" << +startval;
					startvalF += stepchange;
					startval = static_cast<unsigned char>(startvalF);
					if ((k & 0x1f) != 0x1f && k+1 != steplength) ENVFILE << ",";
				 }
			}
			
			ENVFILE << ",#80\n\n";
		}
	}

	cout << "Success!\n";
	ASMFILE.close();
	ENVFILE.close();
	return 0;
}