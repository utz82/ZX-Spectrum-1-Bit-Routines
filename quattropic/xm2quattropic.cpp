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

	cout << "XM 2 QUATTROPIC CONVERTER\n";
	
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
	
	INFILE.seekg(76, ios::beg);		//read global tempo
	INFILE.read((&cp), 1);
	speed = static_cast<unsigned char>(cp);
	if (arg == "-v") cout << "global tempo:    " << +cp << endl;
	OUTFILE << "\n\tdb #" << hex << +cp << "\t\t;speed" << endl;	//write it to music.asm as hex
	
	
	//locate the pattern headers and read pattern lengths
	unsigned ptnoffsetlist[256];
	unsigned ptnlengths[256];
	unsigned headlength, packedlength;
	unsigned char pp;
	int i;
	
	ptnoffsetlist[0] = 336;
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
	OUTFILE << "\n;sequence\nloop\n";
	
	for (fileoffset = 80; fileoffset < ((unsigned)songlength+80); fileoffset++) {
		
		INFILE.seekg(fileoffset, ios::beg);
		INFILE.read((&cp), 1);
		OUTFILE << "\tdw ptn" << hex << +cp << endl;
	
	}
	OUTFILE << "\tdw 0\n\n;pattern data\n";

	//define note value arrays
	const unsigned notetab[97] = { 0,
		0xC0, 0xCB, 0xD8, 0xE4, 0xF2, 0x100, 0x110, 0x120, 0x131, 0x143, 0x156, 0x16A,
		0x180, 0x197, 0x1AF, 0x1C9, 0x1E4, 0x201, 0x21F, 0x23F, 0x262, 0x286, 0x2AC, 0x2D5,
		0x300, 0x32E, 0x35E, 0x391, 0x3C8, 0x401, 0x43E, 0x47F, 0x4C3, 0x50C, 0x558, 0x5AA,
		0x600, 0x65B, 0x6BC, 0x723, 0x78F, 0x802, 0x87C, 0x8FD, 0x986, 0xA17, 0xAB1, 0xB54,
		0xC00, 0xCB7, 0xD78, 0xE45, 0xF1E, 0x1005, 0x10F8, 0x11FB, 0x130D, 0x142E, 0x1562, 0x16A7,
		0x1800, 0x196D, 0x1AF0, 0x1C8A, 0x1E3D, 0x2009, 0x21F1, 0x23F6, 0x2619, 0x285D, 0x2AC3, 0x2D4E,
		0x3000, 0x32DB, 0x35E1, 0x3915, 0x3C7A, 0x4013, 0x43E2, 0x47EB, 0x4C32, 0x50BA, 0x5587, 0x5A9D,
		0x6000, 0x65B5, 0x6BC2, 0x722A, 0x78F4, 0x8025, 0x87C4, 0x8FD6, 0x9864, 0xA174, 0xAB0E, 0xB539 };
	 
	const unsigned noisetab[97] = { 
		0xcd44, 0x0cba, 0x0744, 0x099a, 0x188b, 0x18bb, 0xdd55, 0xed66, 0xc400, 0xb400, 0x0143, 0xc111,
		0xcd44, 0x0cba, 0x0744, 0x099a, 0x188b, 0x18bb, 0xdd55, 0xed66, 0xc400, 0xb400, 0x0143, 0xc111,
		0xcd44, 0x0cba, 0x0744, 0x099a, 0x188b, 0x18bb, 0xdd55, 0xed66, 0xc400, 0xb400, 0x0143, 0xc111,
		0xcd44, 0x0cba, 0x0744, 0x099a, 0x188b, 0x18bb, 0xdd55, 0xed66, 0xc400, 0xb400, 0x0143, 0xc111,
		0xcd44, 0x0cba, 0x0744, 0x099a, 0x188b, 0x18bb, 0xdd55, 0xed66, 0xc400, 0xb400, 0x0143, 0xc111,
		0xcd44, 0x0cba, 0x0744, 0x099a, 0x188b, 0x18bb, 0xdd55, 0xed66, 0xc400, 0xb400, 0x0143, 0xc111,
		0xcd44, 0x0cba, 0x0744, 0x099a, 0x188b, 0x18bb, 0xdd55, 0xed66, 0xc400, 0xb400, 0x0143, 0xc111,
		0xcd44, 0x0cba, 0x0744, 0x099a, 0x188b, 0x18bb, 0xdd55, 0xed66, 0xc400, 0xb400, 0x0143, 0xc111, 0 };


	//convert pattern data	
	int m, note, temp3;
	unsigned char rows, noteval;
	char temp;
	//int temp;
	unsigned duty12, duty34, modlen;
	int detune1 = 0;
	int detune2 = 0;
	int detune3 = 0;
	int detune4 = 0;
	int debug = 0;	
	unsigned ch1[256], ch2[256], ch3[256], ch4[256];
	unsigned char duty1[256], duty2[256], duty3[256], duty4[256], mode[256], nlength[256];
	
	for (i = 0; i <= (uniqueptns)-1; i++) {
	
		if (isPatternUsed(i)) {
		
			OUTFILE << "ptn" << i << endl;
			ch1[0] = 0;
			ch2[0] = 0;
			ch3[0] = 0;		//tone/slide
			ch4[0] = 0;		//tone/noise
			duty1[0] = 0x80;
			duty2[0] = 0x80;
			duty3[0] = 0x80;
			duty4[0] = 0x80;
			mode[0] = 0;
			nlength[0] = 0xff;
			
			fileoffset = ptnoffsetlist[i] + 9;
			
			for (rows = 1; rows <= ptnlengths[i]; rows++) {
			
				ch1[rows] = ch1[rows-1];
				ch2[rows] = ch2[rows-1];
				ch3[rows] = ch3[rows-1];
				ch4[rows] = ch4[rows-1];
				
				duty1[rows] = duty1[rows-1];
				duty2[rows] = duty2[rows-1];
				duty3[rows] = duty3[rows-1];
				duty4[rows] = duty4[rows-1];
				
				if ((mode[rows-1] == 1 || mode[rows-1] == 0x80) && ch4[rows-1] != 0) {
					mode[rows] = 1;
				} else {
					mode[rows] = 0;
				}
				
				nlength[rows] = 0xff;
				
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
											
								if (temp == 97) temp = 0;		//silence
								noteval = temp;
								
								note = notetab[static_cast<int>(temp)];
								if (m == 0) ch1[rows] = note;
								if (m == 1) ch2[rows] = note;
								if (m == 2) ch3[rows] = note;
								if (m == 3) ch4[rows] = note;
								
								fileoffset++;
								INFILE.seekg(fileoffset, ios::beg);	//read next byte
								INFILE.read((&temp), 1);
								temp = static_cast<unsigned char>(temp);
							}
							
							if ((pp&2) == 2) {				//if bit 1 is set, it's instrument
								if (temp == 1 || temp == 5 || temp == 9) {
									if (m == 0) duty1[rows] = 0x80;
									if (m == 1) duty2[rows] = 0x80;
									if (m == 2) duty3[rows] = 0x80;
									if (m == 3) duty4[rows] = 0x80;
								}
								if (temp == 2 || temp == 6 || temp == 10) {
									if (m == 0) duty1[rows] = 0x40;
									if (m == 1) duty2[rows] = 0x40;
									if (m == 2) duty3[rows] = 0x40;
									if (m == 3) duty4[rows] = 0x40;
								}
								if (temp == 3 || temp == 7) {
									if (m == 0) duty1[rows] = 0x20;
									if (m == 1) duty2[rows] = 0x20;
									if (m == 2) duty3[rows] = 0x20;
									if (m == 3) duty4[rows] = 0x20;
								}
								if (temp == 4 || temp == 8) {
									if (m == 0) duty1[rows] = 0x10;
									if (m == 1) duty2[rows] = 0x10;
									if (m == 2) duty3[rows] = 0x10;
									if (m == 3) duty4[rows] = 0x10;
								}
								if (temp < 5 && m == 3 && mode[rows] == 0x80) mode[rows] = 4;
								if (temp < 5 && m == 3 && mode[rows] != 4) mode[rows] = 0;
								if (temp >= 5 && temp <= 8 && m != 3) cout << "WARNING: Noise instrument used on wrong channel at ptn " << i << endl;
								if (temp >= 9 && temp <= 10 && m != 2) cout << "WARNING: Slide instrument used on wrong channel\n";
								if (mode[rows] == 0 && temp >= 5 && temp <= 8) mode[rows] = 1;
								if (mode[rows] == 0 && temp >= 9) mode[rows] = 4;
								if (mode[rows] > 0 && temp >= 9) mode[rows] = 0x80;
							
								if ((mode[rows] == 1 || mode[rows] == 0x80) && ch4[rows] > 0) {
									ch4[rows] = noisetab[noteval];
								}
							
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
							
							
							if ((pp&8) == 8 && temp == 14) {		//if bit 3 is set and value is $e
							
								fileoffset++;
								INFILE.seekg(fileoffset, ios::beg);	//read next byte
								INFILE.read((&temp), 1);
								temp = static_cast<unsigned char>(temp);
								
								if ((cp&16) == 16 && (temp&0xf0) == 0x50) {	//if upper nibble = 5, it's detune
									temp3 = 8 - (temp&15);			//ignore upper nibble
									
									switch(m) {				//setting detune if bit 4 is set
										case 0: detune1 = static_cast<int>(ch1[rows]*temp3/100);
											ch1[rows] = ch1[rows] - detune1;
											break;
										case 1: detune2 = static_cast<int>(ch2[rows]*temp3/100);
											ch2[rows] = ch2[rows] - detune2;
											break;
										case 2: detune3 = static_cast<int>(ch3[rows]*temp3/100);
											ch3[rows] = ch3[rows] - detune3;
											break;
										default: detune4 = static_cast<int>(ch4[rows]*temp3/100);
											ch4[rows] = ch4[rows] - detune4;
											
									}
								}
								
								if ((pp&16) == 16 && (temp&0xf0) == 0xc0) {	//if upper nibble = #c, it's note cut
									if (speed > (temp&15)) nlength[rows] = speed - (temp&15);	//ignore upper nibble and multiply lower by 2
								}
								
								fileoffset++;
							}
						
						} 
						
					} else {			//uncompressed pattern data
						
						//read notes
						temp = pp;
						if (temp == 97) temp = 0;		//silence
						noteval = temp;
							
						note = notetab[static_cast<int>(temp)];
						if (m == 0) ch1[rows] = note;
						if (m == 1) ch2[rows] = note;
						if (m == 2) ch3[rows] = note;
						if (m == 3) ch4[rows] = note;
							
						fileoffset++;
						INFILE.seekg(fileoffset, ios::beg);	//read next byte
						INFILE.read((&temp), 1);
						temp = static_cast<unsigned char>(temp);
						
						
						//read instruments
						if (temp == 1 || temp == 5 || temp == 9) {
							if (m == 0) duty1[rows] = 0x80;
							if (m == 1) duty2[rows] = 0x80;
							if (m == 2) duty3[rows] = 0x80;
							if (m == 3) duty4[rows] = 0x80;
						}
						if (temp == 2 || temp == 6 || temp == 10) {
							if (m == 0) duty1[rows] = 0x40;
							if (m == 1) duty2[rows] = 0x40;
							if (m == 2) duty3[rows] = 0x40;
							if (m == 3) duty4[rows] = 0x40;
						}
						if (temp == 3 || temp == 7) {
							if (m == 0) duty1[rows] = 0x20;
							if (m == 1) duty2[rows] = 0x20;
							if (m == 2) duty3[rows] = 0x20;
							if (m == 3) duty4[rows] = 0x20;
						}
						if (temp == 4 || temp == 8) {
							if (m == 0) duty1[rows] = 0x10;
							if (m == 1) duty2[rows] = 0x10;
							if (m == 2) duty3[rows] = 0x10;
							if (m == 3) duty4[rows] = 0x10;
						}
						if (temp < 5 && m == 3 && mode[rows] == 0x80) mode[rows] = 4;
						if (temp < 5 && m == 3 && mode[rows] != 4) mode[rows] = 0;
						if (temp >= 5 && temp <= 8 && m != 3) cout << "WARNING: Noise instrument used on wrong channel at ptn " << i << endl;
						if (temp >= 9 && temp <= 10 && m != 2) cout << "WARNING: Slide instrument used on wrong channel\n";
						if (mode[rows] == 0 && temp >= 5 && temp <= 8) mode[rows] = 1;
						if (mode[rows] == 0 && temp >= 9) mode[rows] = 4;
						if (mode[rows] > 0 && temp >= 9) mode[rows] = 0x80;
						
						if ((mode[rows] == 1 || mode[rows] == 0x80) && ch4[rows] > 0) {
							ch4[rows] = noisetab[noteval];
						}
						
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
						if ((cp&16) == 16 && (temp&0xf0) == 0x50) {	//if upper nibble = 5, it's detune
							temp3 = 8 - (temp&15);			//ignore upper nibble
								
							switch(m) {				//setting detune if bit 4 is set
								case 0: detune1 = static_cast<int>(ch1[rows]*temp3/100);
									ch1[rows] = ch1[rows] - detune1;
									break;
								case 1: detune2 = static_cast<int>(ch2[rows]*temp3/100);
									ch2[rows] = ch2[rows] - detune2;
									break;
								case 2: detune3 = static_cast<int>(ch3[rows]*temp3/100);
									ch3[rows] = ch3[rows] - detune3;
									break;
								default: detune4 = static_cast<int>(ch4[rows]*temp3/100);
									ch4[rows] = ch4[rows] - detune4;
									
							}
						}
							
						if ((pp&16) == 16 && (temp&0xf0) == 0xc0) {	//if upper nibble = #c, it's note cut
							if (speed > (temp&15)) nlength[rows] = speed - (temp&15);	//ignore upper nibble and multiply lower by 2
						}
								
						//advance file pointer
						fileoffset++;
															
					}
				}
				
				modlen = (nlength[rows]*256)+mode[rows];
				duty12 = duty1[rows]*256 + duty2[rows];
				duty34 = duty3[rows]*256 + duty4[rows];
		
				OUTFILE << "\tdw #" << hex << modlen << ",#" << hex << duty12 << ",#" << hex << duty34;
				OUTFILE << ",#" << hex << ch1[rows] << ",#" << hex << ch2[rows] << ",#" << hex << ch3[rows] << ",#" << hex << ch4[rows] << endl;
		
				ch1[rows] = ch1[rows] + detune1;
				detune1 = 0;
				ch2[rows] = ch2[rows] + detune2;
				detune2 = 0;
				ch3[rows] = ch3[rows] + detune3;
				detune3 = 0;
				ch4[rows] = ch4[rows] + detune4;
				detune4 = 0;
			}
			
		OUTFILE << "\tdb #40\n\n";
		
		}
	
	}


	//if (isPatternUsed(3)) cout << "pattern 3 is used!\n";

	if (debug >= 1) cout << "WARNING: " << debug << "out of range note(s) replaced with rests.\n";
	cout << "Success!\n";

	INFILE.close();
	OUTFILE.close();
	return 0;
}


//check if a pattern exists in sequence
bool isPatternUsed(int patnum) {

int usage = false;

	for (fileoffset = 80; fileoffset < ((unsigned)songlength+80); fileoffset++) {
		INFILE.seekg(fileoffset, ios::beg);
		INFILE.read((&cp), 1);
		if (patnum == static_cast<unsigned char>(cp)) usage = true;
	}

	return(usage);
}