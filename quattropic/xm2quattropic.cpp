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
	 
	const unsigned noisetab[98] = { 0,
		0xcd44, 0x0cba, 0x0744, 0x099a, 0x188b, 0x18bb, 0xdd55, 0xed66, 0xc400, 0xb400, 0x0143, 0xc111,
		0xcd44, 0x0cba, 0x0744, 0x099a, 0x188b, 0x18bb, 0xdd55, 0xed66, 0xc400, 0xb400, 0x0143, 0xc111,
		0xcd44, 0x0cba, 0x0744, 0x099a, 0x188b, 0x18bb, 0xdd55, 0xed66, 0xc400, 0xb400, 0x0143, 0xc111,
		0xcd44, 0x0cba, 0x0744, 0x099a, 0x188b, 0x18bb, 0xdd55, 0xed66, 0xc400, 0xb400, 0x0143, 0xc111,
		0xcd44, 0x0cba, 0x0744, 0x099a, 0x188b, 0x18bb, 0xdd55, 0xed66, 0xc400, 0xb400, 0x0143, 0xc111,
		0xcd44, 0x0cba, 0x0744, 0x099a, 0x188b, 0x18bb, 0xdd55, 0xed66, 0xc400, 0xb400, 0x0143, 0xc111,
		0xcd44, 0x0cba, 0x0744, 0x099a, 0x188b, 0x18bb, 0xdd55, 0xed66, 0xc400, 0xb400, 0x0143, 0xc111,
		0xcd44, 0x0cba, 0x0744, 0x099a, 0x188b, 0x18bb, 0xdd55, 0xed66, 0xc400, 0xb400, 0x0143, 0xc111, 0xcd44 };


	//convert pattern data	
	int m, note1, note2, note3, note4;
	unsigned char rows;
	char temp;
	//int temp;
	unsigned duty12, duty34, mode, modlen;
	int detune1 = 8;
	int detune2 = 8;
	int detune3 = 8;
	int detune4 = 8;
	int debug = 0;	
	unsigned ch1[256], ch2[256], ch3[256], ch4[256];
	unsigned char instr1[256], instr2[256], instr3[256], instr4[256], nlength[256];
	
	for (i = 0; i <= (uniqueptns)-1; i++) {
	
		if (isPatternUsed(i)) {
		
			OUTFILE << "ptn" << i << endl;
			ch1[0] = 0;
			ch2[0] = 0;
			ch3[0] = 0;		//tone/slide
			ch4[0] = 0;		//tone/noise
			instr1[0] = 0;
			instr2[0] = 0;
			instr3[0] = 0;
			instr4[0] = 0;
			nlength[0] = 0xff;
			
			fileoffset = ptnoffsetlist[i] + 9;
			
			for (rows = 1; rows <= ptnlengths[i]; rows++) {
			
				ch1[rows] = ch1[rows-1];
				ch2[rows] = ch2[rows-1];
				ch3[rows] = ch3[rows-1];
				ch4[rows] = ch4[rows-1];
				
				instr1[rows] = instr1[rows-1];
				instr2[rows] = instr2[rows-1];
				instr3[rows] = instr3[rows-1];
				instr4[rows] = instr4[rows-1];
				
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
								
								//note = notetab[static_cast<int>(temp)];
								if (m == 0) {
									ch1[rows] = temp;
									if (temp == 0) instr1[rows] = 0;
								}
								if (m == 1) {
									ch2[rows] = temp;
									if (temp == 0) instr2[rows] = 0;
								}
								if (m == 2) {
									ch3[rows] = temp;
									if (temp == 0) instr3[rows] = 0;
								}
								if (m == 3) {
									ch4[rows] = temp;
									if (temp == 0) instr4[rows] = 0;
								}
								
								fileoffset++;
								INFILE.seekg(fileoffset, ios::beg);	//read next byte
								INFILE.read((&temp), 1);
								temp = static_cast<unsigned char>(temp);
							}
							
							if ((pp&2) == 2) {				//if bit 1 is set, it's instrument
								if (m == 0 && ch1[rows] != 0) instr1[rows] = temp;
								if (m == 1 && ch2[rows] != 0) instr2[rows] = temp;
								if (m == 2 && ch3[rows] != 0) instr3[rows] = temp;
								if (m == 3 && ch4[rows] != 0) instr4[rows] = temp;

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
									if (m == 0) detune1 = temp & 0xf;
									if (m == 1) detune2 = temp & 0xf;
									if (m == 2) detune3 = temp & 0xf;
									if (m == 3) detune4 = temp & 0xf;
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
						
						if (m == 0) {
							ch1[rows] = temp;
							if (temp == 0) instr1[rows] = 0;
						}
						if (m == 1) {
							ch2[rows] = temp;
							if (temp == 0) instr2[rows] = 0;
						}
						if (m == 2) {
							ch3[rows] = temp;
							if (temp == 0) instr3[rows] = 0;
						}
						if (m == 3) {
							ch4[rows] = temp;
							if (temp == 0) instr4[rows] = 0;
						}
						
				
						fileoffset++;
						INFILE.seekg(fileoffset, ios::beg);	//read next byte
						INFILE.read((&temp), 1);
						temp = static_cast<unsigned char>(temp);
						
						
						//read instruments
						if (m == 0 && ch1[rows] != 0) instr1[rows] = temp;
						if (m == 1 && ch2[rows] != 0) instr2[rows] = temp;
						if (m == 2 && ch3[rows] != 0) instr3[rows] = temp;
						if (m == 3 && ch4[rows] != 0) instr4[rows] = temp;
						
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
							if (m == 0) detune1 = temp & 0xf;
							if (m == 1) detune2 = temp & 0xf;
							if (m == 2) detune3 = temp & 0xf;
							if (m == 3) detune4 = temp & 0xf;
						}
							
						if ((pp&16) == 16 && (temp&0xf0) == 0xc0) {	//if upper nibble = #c, it's note cut
							if (speed > (temp&15)) nlength[rows] = speed - (temp&15);	//ignore upper nibble and multiply lower by 2
						}
								
						//advance file pointer
						fileoffset++;
															
					}
				}
				
				duty12 = 0;
				duty34 = 0;
				mode = 0;
				if (instr1[rows] > 4 || instr2[rows] > 4 || instr4[rows] > 8 || (instr3[rows] > 4 && instr3[rows] < 9) ) cout << "Wrong instrument used in pattern " << +i << " row " << +rows << endl;
				if (instr1[rows] == 1) duty12 = 0x80 * 256;
				if (instr1[rows] == 2) duty12 = 0x40 * 256;
				if (instr1[rows] == 3) duty12 = 0x20 * 256;
				if (instr1[rows] == 4) duty12 = 0x10 * 256;
				if (instr2[rows] == 1) duty12 += 0x80;
				if (instr2[rows] == 2) duty12 += 0x40;
				if (instr2[rows] == 3) duty12 += 0x20;
				if (instr2[rows] == 4) duty12 += 0x10;
				if (instr3[rows] == 1 || instr3[rows] == 9) duty34 = 0x80 * 256;
				if (instr3[rows] == 2 || instr3[rows] == 0xa) duty34 = 0x40 * 256;
				if (instr3[rows] == 3) duty34 = 0x20 * 256;
				if (instr3[rows] == 4) duty34 = 0x10 * 256;
				if (instr4[rows] == 1 || instr4[rows] == 5) duty34 += 0x80;
				if (instr4[rows] == 2 || instr4[rows] == 6) duty34 += 0x40;
				if (instr4[rows] == 3 || instr4[rows] == 7) duty34 += 0x20;
				if (instr4[rows] == 4 || instr4[rows] == 8) duty34 += 0x10;
				
				if (instr4[rows] > 4 && instr3[rows] > 8) mode = 0x80;
				else if (instr4[rows] > 4) mode = 1;
				else if (instr3[rows] > 8) mode = 4;
				
				note1 = notetab[ch1[rows]];
				note2 = notetab[ch2[rows]];
				note3 = notetab[ch3[rows]];
				if (instr4[rows] < 5) note4 = notetab[ch4[rows]];
				else note4 = noisetab[ch4[rows]+1];
				note1 = note1 - (note1*(8-detune1)/100);
				note2 = note2 - (note2*(8-detune2)/100);
				note3 = note3 - (note3*(8-detune3)/100);
				note4 = note4 - (note4*(8-detune4)/100);
				
				modlen = (nlength[rows]*256)+mode;
		
				OUTFILE << "\tdw #" << hex << modlen << ",#" << hex << duty12 << ",#" << hex << duty34;
				OUTFILE << ",#" << hex << +note1 << ",#" << +note2 << ",#" << +note3 << ",#" << +note4 << endl;
		
				detune1 = 8;
				detune2 = 8;
				detune3 = 8;
				detune4 = 8;
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