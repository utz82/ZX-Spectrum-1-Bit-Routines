#include <iostream>
#include <fstream>
#include <string>

using namespace std;

unsigned fileoffset;
unsigned char songlength;
char cp;	//read value
ifstream INFILE;


bool isPatternUsed(int patnum);

int main(int argc, char *argv[]){

	cout << "XM 2 ZBMOD CONVERTER\n";
	
	//check for "-v" flag
	string arg = "";
	if (argc > 1) arg = argv[1];
	
	//open music.xm
	INFILE.open ("music.xm", ios::in | ios::binary);
	//ifstream INFILE;
	if (!INFILE.is_open()) {
		cout << "Error: Could not open music.xm\n";
		return -1;
	}
	
	//create music.asm
	ofstream OUTFILE;
	OUTFILE.open ("music.asm", ios::out | ios::trunc);
	
	if (!OUTFILE.is_open()) {
		cout << "Error: Could not create music.asm - need to set write permission?\n";
		return -1;
	}
	
	
	
	
	//verify xm parameters
	INFILE.seekg(58, ios::beg);		//read version
	INFILE.read((&cp), 1);
	if (cp != 4) {
		cout << "Error: Obsolete XM version 1.0" << +cp << ", v1.04 required" << endl;
		return -1;
	}
	
	INFILE.seekg(68, ios::beg);		//read # of channels
	INFILE.read((&cp), 1);
	if (cp != 4) {
		cout << "Error: XM has " << +cp << " channels instead of 4" << endl;
		return -1;
	}

	//read global song parameters
	unsigned char uniqueptns;
	unsigned char speed;
	
	INFILE.seekg(64, ios::beg);		//read song length
	INFILE.read((&cp), 1);
	songlength = static_cast<unsigned char>(cp);
	if (arg == "-v") cout << "song length:     " << +songlength << endl;
	
	INFILE.seekg(70, ios::beg);		//read # of unique patterns
	INFILE.read((&cp), 1);
	uniqueptns = static_cast<unsigned char>(cp);
	if (arg == "-v") cout << "unique patterns: " << +uniqueptns << endl;
	
	INFILE.seekg(76, ios::beg);		//read global speed
	INFILE.read((&cp), 1);
	speed = static_cast<unsigned>(cp);
	if (arg == "-v") cout << "global Spd:    " << +speed << endl;
	
	//locate the pattern headers and read pattern lengths
	unsigned ptnoffsetlist[256];
	unsigned ptnlengths[256];
	unsigned headlength, packedlength, xmhead;
	unsigned char pp;
	int i;
	
	//determine XM header length
	INFILE.seekg(61, ios::beg);
	INFILE.read((&cp), 1);
	pp = static_cast<unsigned char>(cp);
	xmhead = pp*256;
	INFILE.seekg(60, ios::beg);
	INFILE.read((&cp), 1);
	pp = static_cast<unsigned char>(cp);
	xmhead+=pp;
	
	ptnoffsetlist[0] = xmhead+60;
	fileoffset = ptnoffsetlist[0];
	
	for (i=0; i < uniqueptns; i++) {
		
		INFILE.seekg(fileoffset, ios::beg);
		INFILE.read((&cp), 1);
		pp = static_cast<unsigned char>(cp);
		headlength = static_cast<unsigned>(pp);
		
		fileoffset += 5;
		INFILE.seekg(fileoffset, ios::beg);
		INFILE.read((&cp), 1);
		pp = static_cast<unsigned char>(cp);
		ptnlengths[i] = static_cast<unsigned>(pp);
		
		fileoffset += 2;
		INFILE.seekg(fileoffset, ios::beg);
		INFILE.read((&cp), 1);
		pp = static_cast<unsigned char>(cp);
		packedlength = static_cast<unsigned>(pp);
		
		fileoffset++;
		INFILE.seekg(fileoffset, ios::beg);
		INFILE.read((&cp), 1);
		pp = static_cast<unsigned char>(cp);
		packedlength += (static_cast<unsigned>(pp))*256;
		
		ptnoffsetlist[i+1] = ptnoffsetlist[i] + headlength + packedlength;
		fileoffset = fileoffset + packedlength + 1;
		
		if (arg == "-v") cout << "pattern " << i << " starts at " << ptnoffsetlist[i] << ", length " << ptnlengths[i] << " rows\n";		
	}
	

	//generate pattern sequence
	OUTFILE << "\nsequence\n";
	unsigned char looppoint = 0;
	
	for (fileoffset = 80; fileoffset < ((unsigned)songlength+80); fileoffset++) {
		
		INFILE.seekg(fileoffset, ios::beg);
		INFILE.read((&cp), 1);
		OUTFILE << "\tdw ptn" << hex << +cp << endl;
	
	}
	OUTFILE << "\tdw 0\n\n;pattern data\n";

	//define note value arrays
	const unsigned char notetab[49] = { 0,
		0x11, 0x12, 0x13, 0x14, 0x15, 0x17, 0x18, 0x19, 0x1B, 0x1C, 0x1E, 0x20,
		0x22, 0x24, 0x26, 0x28, 0x2B, 0x2D, 0x30, 0x33, 0x36, 0x39, 0x3C, 0x40,
		0x44, 0x48, 0x4C, 0x50, 0x55, 0x5A, 0x60, 0x65, 0x6B, 0x72, 0x78, 0x80,
		0x87, 0x8F, 0x98, 0xA1, 0xAA, 0xB4, 0xBF, 0xCA, 0xD6, 0xE3, 0xF1, 0xFF };
	 
	//convert pattern data	
	int m;
	unsigned char rows, ctrlb, note, notech1, notech2, notech3;
	bool retrig1,retrig2,retrig3;
	unsigned char maxinstr = 0;
	char temp;
	char detune1 = 0;
	char detune2 = 0;
	char detune3 = 0;	
	unsigned char ch1[257], ch2[257], ch3[257];	//was unsigned
	unsigned char instr1[257], instr2[257], instr3[257], rspeed[257];	//, instruments[257];

	
	for (i = 0; i <= (uniqueptns)-1; i++) {
	
		if (isPatternUsed(i)) {
		
			OUTFILE << "ptn" << i << endl;
			ch1[0] = 0;
			ch2[0] = 0;
			ch3[0] = 0;
			instr1[0] = 0;
			instr2[0] = 0;
			instr3[0] = 0;
			rspeed[0] = speed;
			
			fileoffset = ptnoffsetlist[i] + 9;
			
			for (rows = 1; rows <= ptnlengths[i]; rows++) {
			
				ch1[rows] = ch1[rows-1];
				ch2[rows] = ch2[rows-1];
				ch3[rows] = ch3[rows-1];
				
				instr1[rows] = instr1[rows-1];
				instr2[rows] = instr2[rows-1];
				instr3[rows] = instr3[rows-1];
				
				retrig1 = false;
				retrig2 = false;
				retrig3 = false;
				
				rspeed[rows] = rspeed[rows-1];
				
				for (m = 0; m <= 3; m++) {
				
					INFILE.seekg(fileoffset, ios::beg);
					INFILE.read((&cp), 1);
					pp = static_cast<unsigned char>(cp);
					
					if (pp >= 128) {		//have compressed pattern data
					
						fileoffset++;
						
						if (pp != 128) {
						
							INFILE.seekg(fileoffset, ios::beg);
							INFILE.read((&temp), 1);
							temp = static_cast<unsigned char>(temp);
							
							if ((pp&1) == 1) {	//if bit 0 is set, it's note -> counter val.		
											
								if ((temp < 2) || (temp > 49)) {
									if (temp != 97) cout << "Note out of range in pattern " << +i << " row " << +rows << ", replaced with a rest\n";
									temp = 0;		//silence
								}
								
								note = notetab[static_cast<unsigned char>(temp-1)];
								if (m == 0) {
									ch1[rows] = note;
									retrig1 = true;
								}
								if (m == 1) {
									ch2[rows] = note;
									retrig2 = true;
								}
								if (m == 2) {
									ch3[rows] = note;
									retrig3 = true;
								}
								
								fileoffset++;
								INFILE.seekg(fileoffset, ios::beg);	//read next byte
								INFILE.read((&temp), 1);
								temp = static_cast<unsigned char>(temp);
							}
							
							if ((pp&2) == 2) {				//if bit 1 is set, it's instrument
								
								if (temp > maxinstr) maxinstr = temp;
								if (m == 0) instr1[rows] = temp;
								if (m == 1) instr2[rows] = temp;
								if (m == 2) instr3[rows] = temp;
								
								fileoffset++;
								INFILE.seekg(fileoffset, ios::beg);	//read next byte
								INFILE.read((&temp), 1);
								temp = static_cast<unsigned char>(temp);
							}
							
							if ((pp&4) == 4) {				//if bit 2 is set, it's volume -> ignore
								fileoffset++;
								INFILE.seekg(fileoffset, ios::beg);	//read next byte
								INFILE.read((&temp), 1);
								temp = static_cast<unsigned char>(temp);
							}
							
							if ((pp&8) == 8 && temp == 0xb) {		//if bit 3 is set and value is $b (jump to order)
								fileoffset++;
								INFILE.seekg(fileoffset, ios::beg);	//read next byte
								INFILE.read((&temp), 1);
								temp = static_cast<unsigned char>(temp);
								looppoint = temp*2;
								fileoffset++;
							
							}
							else if ((pp&8) == 8 && temp == 0xf) {		//if bit 3 is set and value is $f (set speed)
								fileoffset++;
								INFILE.seekg(fileoffset, ios::beg);	//read next byte
								INFILE.read((&temp), 1);
								temp = static_cast<unsigned char>(temp);
								if (temp < 0x20) rspeed[rows] = temp;
								fileoffset++;
							
							}
							else if ((pp&8) == 8 && temp == 0xe) {		//if bit 3 is set and value is $e5x (finetune)
							
								fileoffset++;
								INFILE.seekg(fileoffset, ios::beg);	//read next byte
								INFILE.read((&temp), 1);
								temp = static_cast<unsigned char>(temp);
								
								if ((temp & 0xf0) == 0x50) {
									temp = (temp & 0xf) - 8;
									if (m == 0) detune1 = temp;
									if (m == 0) detune2 = temp;
									if (m == 0) detune3 = temp;
								}
																
								fileoffset++;
							}
							else {						//skip bytes for other fx
								if ((pp&8) == 8) fileoffset++;
								if ((pp&16) == 16) fileoffset++;
							}
						} 
						
					} else {			//uncompressed pattern data
						
						//read notes
						temp = pp;
						if ((temp < 2) || (temp > 49)) {
							if (temp != 97) cout << "Note out of range in pattern " << +i << " row " << +rows << ", replaced with a rest\n";
							temp = 0;		//silence
						}
							
						note = notetab[static_cast<unsigned char>(temp-1)];
						if (m == 0) {
							ch1[rows] = note;
							retrig1 = true;
						}
						if (m == 1) {
							ch2[rows] = note;
							retrig2 = true;
						}
						if (m == 2) {
							ch3[rows] = note;
							retrig3 = true;
						}
							
						fileoffset++;
						INFILE.seekg(fileoffset, ios::beg);	//read next byte
						INFILE.read((&temp), 1);
						temp = static_cast<unsigned char>(temp);
						
						
						//read instruments
						if (temp > maxinstr) maxinstr = temp;
						if (m == 0) instr1[rows] = temp;
						if (m == 1) instr2[rows] = temp;
						if (m == 2) instr3[rows] = temp;

						
						//read and ignore volume
						fileoffset++;
						INFILE.seekg(fileoffset, ios::beg);	//read next byte
						INFILE.read((&temp), 1);
						temp = static_cast<unsigned char>(temp);
						
					
						//read fx command
						fileoffset++;
						INFILE.seekg(fileoffset, ios::beg);	//read next byte
						INFILE.read((&temp), 1);
						temp = static_cast<unsigned char>(temp);
						pp = temp;
						
						//read fx parameter
						fileoffset++;
						INFILE.seekg(fileoffset, ios::beg);	//read next byte
						INFILE.read((&temp), 1);
						temp = static_cast<unsigned char>(temp);
						
						//evaluate fx
						if (pp == 0xb) looppoint = temp*2;
 						if (pp == 0xf && temp < 0x20) rspeed[rows] = temp;
						if (pp == 0xe && (temp & 0xf) == 0x50) {
							temp = (temp & 0xf) - 8;
							if (m == 0) detune1 = temp;
							if (m == 0) detune2 = temp;
							if (m == 0) detune3 = temp;
						}
								
						//advance file pointer
						fileoffset++;
															
					}
				}
				
				if (ch1[rows] == 0) instr1[rows] = 0;
				if (ch2[rows] == 0) instr2[rows] = 0;
				if (ch3[rows] == 0) instr3[rows] = 0;
				
				notech1 = ch1[rows] + detune1;
				notech2 = ch2[rows] + detune2;
				notech3 = ch3[rows] + detune3;
				
				ctrlb = 0;
				if ((ch3[rows] == ch3[rows-1]) && !retrig3) ctrlb = (ctrlb | 1);
				if ((ch2[rows] == ch2[rows-1]) && !retrig2) ctrlb = (ctrlb | 4);
				if ((ch1[rows] == ch1[rows-1]) && !retrig1) ctrlb = (ctrlb | 0x40);
				if (rows == 1) ctrlb = 0;
				
				OUTFILE << "\tdb #" << hex<< +ctrlb << ",#" << +rspeed[rows] << "\n";
				
				if ((ctrlb & 0x40) != 0x40) OUTFILE << hex << "\tdb #" << +notech1 << ",#" << +instr1[rows]*4 << endl;
				if ((ctrlb & 4) != 4) OUTFILE << hex << "\tdb #" << +notech2 << ",#" << +instr2[rows]*4 << endl;
				if ((ctrlb & 1) != 1) OUTFILE << hex << "\tdb #" << +notech3 << ",#" << +instr3[rows]*4 << "\n\tdw smp" << +instr3[rows] << endl;

				OUTFILE << "\tdw core0\n";								
				
				detune1 = 0;
				detune2 = 0;
				detune3 = 0;

			}	
		OUTFILE << "\tdb #80\n\n";
		
		}
	
	}
	
	//define sequence loop point
	OUTFILE << hex << "loop equ sequence+#" << +looppoint << "\n\n";
	
	OUTFILE.close();
	
	//create samples.asm
	ofstream SMPFILE;
	SMPFILE.open ("samples.asm", ios::out | ios::trunc);
	
	if (!SMPFILE.is_open()) {
		cout << "Error: Could not create samples.asm - need to set write permission?\n";
		return -1;
	}
	
	//create sampletab.asm
	ofstream SMPTAB;
	SMPTAB.open ("sampletab.asm", ios::out | ios::trunc);
	
	if (!SMPTAB.is_open()) {
		cout << "Error: Could not create sampletab.asm - need to set write permission?\n";
		return -1;
	}
	
	SMPTAB << "\tdw smp0,smp0\n";
	
	//extract and convert samples
	SMPFILE << "\nsmp0\n\tdb 1,0\n\n";
	
	unsigned iheadersize,samplesize,csmpsize,j,loopstart,looplen,temph;
	
	bool words, loop;
	char sraw[0xffff];
	unsigned char scon[0x4000];
	int debugh;
	
	fileoffset = ptnoffsetlist[uniqueptns] + ptnlengths[uniqueptns];	//point to beginning of instrument block
	
	for (i=1; i <= maxinstr; i++) {
	
		unsigned char minvol = 7;
	
		words = false;					//assume 8-bit sample data
		loop = false;
	
		INFILE.seekg(fileoffset, ios::beg);		//read instrument header size
		INFILE.read((&temp), 1);
		iheadersize = static_cast<unsigned>(temp);
		fileoffset++;
		INFILE.seekg(fileoffset, ios::beg);
		INFILE.read((&temp), 1);
		temph = static_cast<unsigned>(temp);
		fileoffset += 3;				//skip upper word of header size
	
		iheadersize += (temph*256);
	
		if (arg == "-v") cout << hex << +fileoffset << "\t";
	
		for (j=0; j < 22; j++) {			//read instrument name
			INFILE.seekg(fileoffset, ios::beg);
			INFILE.read((&temp), 1);
			temp = static_cast<unsigned char>(temp);
			fileoffset++;
			if (arg == "-v") cout << temp;
		}
		if (arg == "-v") cout << "\t";

		fileoffset = fileoffset + iheadersize - 26;
		
		INFILE.seekg(fileoffset, ios::beg);		//read sample length
		INFILE.read((&temp), 1);
		samplesize = static_cast<unsigned char>(temp);
		fileoffset++;
		INFILE.seekg(fileoffset, ios::beg);
		INFILE.read((&temp), 1);
		temph = static_cast<unsigned char>(temp);
		fileoffset++;
		samplesize += (temph*256);
		
		INFILE.seekg(fileoffset, ios::beg);		//read sample length upper word, should be 0
		INFILE.read((&temp), 1);
		temp = static_cast<unsigned char>(temp);
		if (temp != 0) cout << "Error: sample size > 64k\n";
		fileoffset++;
		INFILE.seekg(fileoffset, ios::beg);		//read sample length upper word, should be 0
		INFILE.read((&temp), 1);
		temp = static_cast<unsigned char>(temp);
		if (temp != 0) cout << "Error: sample size > 64k\n";
		fileoffset++;
		
		INFILE.seekg(fileoffset, ios::beg);		//read loop start
		INFILE.read((&temp), 1);
		loopstart = static_cast<unsigned char>(temp);
		fileoffset++;
		INFILE.seekg(fileoffset, ios::beg);
		INFILE.read((&temp), 1);
		temph = static_cast<unsigned char>(temp);
		fileoffset += 3;
		loopstart += (temph*256);
		
		INFILE.seekg(fileoffset, ios::beg);		//read loop length
		INFILE.read((&temp), 1);
		looplen = static_cast<unsigned char>(temp);
		fileoffset++;
		INFILE.seekg(fileoffset, ios::beg);
		INFILE.read((&temp), 1);
		temph = static_cast<unsigned char>(temp);
		fileoffset += 5;				//skip loop length hi-word, volume, finetune
		looplen += (temph*256);
		
		INFILE.seekg(fileoffset, ios::beg);		//read loop length
		INFILE.read((&temp), 1);
		temph = static_cast<unsigned char>(temp);
		
		if ((temph & 1) == 1) loop = true;		//detect looping
//		if ((temph & 0x10) == 0x10) words = true;	//detect sample bit depth
		if ((temph & 0x10) == 0x10) {			//exit if 16-bit sample found, because 16-bit conversion doesn't work yet.
			cout << "Error: 16-bit sample data found.\n";
			return -1;
		}
		
		fileoffset += 4;				//skip irrelevant stuff
		
		if (arg == "-v") cout << hex << +fileoffset << "\t";
		for (j=0; j < 22; j++) {			//read sample name
			INFILE.seekg(fileoffset, ios::beg);
			INFILE.read((&temp), 1);
			temp = static_cast<unsigned char>(temp);
			fileoffset++;
			if (arg == "-v") cout <<	temp;
		}
		
		if (arg == "-v") cout << hex << "\t\tsample size 0x" << +samplesize << " bytes\n";
		unsigned char temp2,temp3;
		
		if (!words) {					//read in sample data			
			for (j=0; j < samplesize; j++) {	//8-bit
				INFILE.seekg(fileoffset, ios::beg);
				INFILE.read((&temp), 1);
				sraw[j] = static_cast<char>(temp);
				fileoffset++;
				//if (i==2) cout << +j << " ";
			}
		} else {
			for (j=0; j < samplesize; j+=2) {	//16-bit
				INFILE.seekg(fileoffset, ios::beg);
				INFILE.read((&temp), 1);
				temp2 = static_cast<char>(temp);
				fileoffset++;
				INFILE.seekg(fileoffset, ios::beg);
				INFILE.read((&temp), 1);
				temp3 = static_cast<char>(temp);
				
				debugh = (temp3*256)|temp2;
				cout << hex << +temp2 << "\t" << +temp3 <<  "\t" << +debugh << endl;
				
				sraw[j] = char((((temp3&0xff)*256)|temp2)/256)&0xff;
				fileoffset++;	
			}
			samplesize = unsigned(samplesize/2);
		}
		
		temp = 0;					//convert delta-based sample data to raw pcm
		for (j=0; j < samplesize; j++) {
			sraw[j] += temp;
			temp = sraw[j];
			if ((sraw[j] & 0x80) == 0x80) {		//convert to unsigned
				sraw[j] = (sraw[j] & 0x7f);
			} else {
				sraw[j] = (sraw[j] | 0x80);
			}  
		}
		
		if ((samplesize & 3) == 1) samplesize--;	//pad/truncate sample size so there's a multiple of 4 samples
		else if ((samplesize & 3) == 2) samplesize = samplesize -2;
		else if ((samplesize & 3) == 3) {
			samplesize++;
			sraw[samplesize-1] = sraw[samplesize-2];
		}
		csmpsize = unsigned(samplesize/5);		//downsample and convert raw pcm to zmod format (9khz, 7-level volume)
// 		for (j=0; j < csmpsize; j++) {
// 			k = j*4;
// 			//(((s+(s+1)+(s+2)+(s+3))/4)/32)*4
// 			temph = reinterpret_cast<unsigned char&>(sraw[k]) + reinterpret_cast<unsigned char&>(sraw[k+1]) + reinterpret_cast<unsigned char&>(sraw[k+2]) + reinterpret_cast<unsigned char&>(sraw[k+3]);
// 			temph = unsigned((temph/4)/37);
// 			scon[j] = (unsigned char)temph;
// 		}
		for (j=0; j < samplesize; j=j+5) {
			//k = unsigned(j/5);
			temph = reinterpret_cast<unsigned char&>(sraw[j]);
			temph = unsigned(temph/37);
			scon[unsigned(j/5)] = (unsigned char)temph;
		}
//		if ((csmpsize&1) == 0) csmpsize--;		//if converted sample size is even, make it odd

		for (j=0; j < csmpsize; j++) {			//minimize sample volume
			if (scon[j] < minvol) minvol = scon[j];
		}

		for (j=0; j < csmpsize; j++) {
			scon[j] = scon[j] - minvol + 1;
		}
		
		SMPFILE << "smp" << +i;				//output sample to file
				
		unsigned n,pblk;
		pblk = unsigned(csmpsize/32);
		j = 0;
		for (n=0; n < pblk; n++) {
			SMPFILE << "\n\tdb ";
			for (m=0; m<32; m++) {
				SMPFILE << hex << "#" << +scon[j];
				j++;
				if (m != 31) SMPFILE << ",";
			}			
		}
		SMPFILE << "\n\tdb ";
		for (; j < csmpsize; j++) {
			SMPFILE << hex << "#" << +scon[j] << ",";
		}
		
		SMPFILE << "0\n";
		loopstart = unsigned(loopstart/5);
		
		if (!loop) SMPTAB << "\tdw smp0,smp" << +i << "\n";
		else SMPTAB << hex << "\tdw smp" << +i << "+#" << +loopstart << ",smp" << +i << "\n";	
		
	}

	cout << "Success!\n";

	INFILE.close();
	SMPFILE.close();
	SMPTAB.close();
	return 0;
}


//check if a pattern exists in sequence
bool isPatternUsed(int patnum) {

bool usage = false;

	for (fileoffset = 80; fileoffset < ((unsigned)songlength+80); fileoffset++) {
		INFILE.seekg(fileoffset, ios::beg);
		INFILE.read((&cp), 1);
		if (patnum == static_cast<unsigned char>(cp)) usage = true;
	}

	return(usage);
}