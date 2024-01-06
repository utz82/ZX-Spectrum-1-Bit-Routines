#include <fstream>
#include <iostream>
#include <string>

using namespace std;

unsigned fileoffset;
unsigned char songlength;
char cp; // read value
ifstream INFILE;

bool isPatternUsed(int patnum);

int main(int argc, char *argv[]) {

  cout << "XM 2 FLUIDCORE CONVERTER\n";

  // check for "-v" flag
  string arg = "";
  if (argc > 1)
    arg = argv[1];

  // open music.xm
  INFILE.open("music.xm", ios::in | ios::binary);
  // ifstream INFILE;
  if (!INFILE.is_open()) {
    cout << "Error: Could not open music.xm\n";
    return -1;
  }

  // create music.asm
  ofstream OUTFILE;
  OUTFILE.open("music.asm", ios::out | ios::trunc);

  if (!OUTFILE.is_open()) {
    cout << "Error: Could not create music.asm - need to set write "
            "permission?\n";
    return -1;
  }

  // verify xm parameters
  INFILE.seekg(58, ios::beg); // read version
  INFILE.read((&cp), 1);
  if (cp != 4) {
    cout << "Error: Obsolete XM version 1.0" << +cp << ", v1.04 required"
         << endl;
    return -1;
  }

  INFILE.seekg(68, ios::beg); // read # of channels
  INFILE.read((&cp), 1);
  if (cp != 4) {
    cout << "Error: XM has " << +cp << " channels instead of 4" << endl;
    return -1;
  }

  // read global song parameters
  unsigned char uniqueptns;
  unsigned char speed;

  INFILE.seekg(64, ios::beg); // read song length
  INFILE.read((&cp), 1);
  songlength = static_cast<unsigned char>(cp);
  if (arg == "-v")
    cout << "song length:     " << +songlength << endl;

  INFILE.seekg(70, ios::beg); // read # of unique patterns
  INFILE.read((&cp), 1);
  uniqueptns = static_cast<unsigned char>(cp);
  if (arg == "-v")
    cout << "unique patterns: " << +uniqueptns << endl;

  INFILE.seekg(76, ios::beg); // read global tempo
  INFILE.read((&cp), 1);
  speed = static_cast<unsigned char>(cp);
  if (arg == "-v")
    cout << "global tempo:    " << +cp << endl;
  // OUTFILE << "\n\tdb #" << hex << +cp << "\t\t;speed" << endl;	//write
  // it to music.asm as hex

  // locate the pattern headers and read pattern lengths
  unsigned ptnoffsetlist[256];
  unsigned ptnlengths[256];
  unsigned headlength, packedlength, xmhead;
  unsigned char pp;
  int i;

  // determine XM header length
  INFILE.seekg(61, ios::beg);
  INFILE.read((&cp), 1);
  pp = static_cast<unsigned char>(cp);
  xmhead = pp * 256;
  INFILE.seekg(60, ios::beg);
  INFILE.read((&cp), 1);
  pp = static_cast<unsigned char>(cp);
  xmhead += pp;

  ptnoffsetlist[0] = xmhead + 60;
  fileoffset = ptnoffsetlist[0];

  for (i = 0; i < uniqueptns; i++) {

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
    packedlength += (static_cast<unsigned>(pp)) * 256;

    ptnoffsetlist[i + 1] = ptnoffsetlist[i] + headlength + packedlength;
    fileoffset = fileoffset + packedlength + 1;

    if (arg == "-v")
      cout << "pattern " << i << " starts at " << ptnoffsetlist[i]
           << ", length " << ptnlengths[i] << " rows\n";
  }

  // generate pattern sequence
  OUTFILE << "\nsequence\n";
  unsigned char looppoint = 0;

  for (fileoffset = 80; fileoffset < ((unsigned)songlength + 80);
       fileoffset++) {

    INFILE.seekg(fileoffset, ios::beg);
    INFILE.read((&cp), 1);
    OUTFILE << "\tdw ptn" << hex << +cp << endl;
  }
  OUTFILE << "\tdw 0\n\n;pattern data\n";

  // define note value arrays
  const unsigned notetab[97] = {
      0,      0x20,   0x22,   0x40,   0x41,   0x80,   0xfe,   0xff,   0x100,
      0x196,  0x1AF,  0x1C8,  0x1E3,  0x200,  0x21E,  0x23F,  0x261,  0x285,
      0x2AB,  0x2D4,  0x2FF,  0x32D,  0x35D,  0x390,  0x3C7,  0x400,  0x43D,
      0x47D,  0x4C2,  0x50A,  0x557,  0x5A8,  0x5FE,  0x65A,  0x6BA,  0x721,
      0x78D,  0x800,  0x87A,  0x8FB,  0x984,  0xA14,  0xAAE,  0xB50,  0xBFD,
      0xCB3,  0xD74,  0xE41,  0xF1A,  0x1000, 0x10F4, 0x11F6, 0x1307, 0x1429,
      0x155C, 0x16A1, 0x17F9, 0x1966, 0x1AE9, 0x1C82, 0x1E34, 0x2000, 0x21E7,
      0x23EB, 0x260E, 0x2851, 0x2AB7, 0x2D41, 0x2FF2, 0x32CC, 0x35D1, 0x3905,
      0x3C68, 0x4000, 0x43CE, 0x47D6, 0x4C1C, 0x50A3, 0x556E, 0x5A83, 0x5FE4,
      0x6598, 0x6BA3, 0x7209, 0x78D1, 0x8000, 0x879D, 0x8FAD, 0x9838, 0xA145,
      0xAADC, 0xB505, 0xBFC9, 0xCB30, 0xD745, 0xE412, 0xF1A2};

  // convert pattern data
  int m, x, note, notech1, notech2, notech3, notech4;
  unsigned char rows;
  unsigned char insamnt = 0;
  bool insused;
  char temp;
  int detune1 = 0;
  int detune2 = 0;
  int detune3 = 0;
  int detune4 = 0;
  int debug = 0;
  int ch1[257], ch2[257], ch3[257], ch4[257]; // was unsigned
  unsigned char instr1[257], instr2[257], instr3[257], instr4[257], rspeed[257],
      instruments[257];
  for (i = 0; i < 257; ++i)
    instruments[i] = 0;

  for (i = 0; i <= (uniqueptns)-1; i++) {

    if (isPatternUsed(i)) {

      OUTFILE << "ptn" << i << endl;
      ch1[0] = 0;
      ch2[0] = 0;
      ch3[0] = 0; // tone/slide
      ch4[0] = 0; // tone/noise
      instr1[0] = 0;
      instr2[0] = 0;
      instr3[0] = 0;
      instr4[0] = 0;
      rspeed[0] = speed;

      fileoffset = ptnoffsetlist[i] + 9;

      for (rows = 1; rows <= ptnlengths[i]; rows++) {

        ch1[rows] = ch1[rows - 1];
        ch2[rows] = ch2[rows - 1];
        ch3[rows] = ch3[rows - 1];
        ch4[rows] = ch4[rows - 1];

        instr1[rows] = instr1[rows - 1];
        instr2[rows] = instr2[rows - 1];
        instr3[rows] = instr3[rows - 1];
        instr4[rows] = instr4[rows - 1];

        rspeed[rows] = rspeed[rows - 1];

        for (m = 0; m <= 3; m++) {

          INFILE.seekg(fileoffset, ios::beg);
          INFILE.read((&cp), 1);
          pp = static_cast<unsigned char>(cp);

          if (pp >= 128) { // have compressed pattern data

            fileoffset++;

            if (pp != 128) {

              INFILE.seekg(fileoffset, ios::beg);
              INFILE.read((&temp), 1);
              temp = static_cast<unsigned char>(temp);

              if ((pp & 1) == 1) { // if bit 0 is set, it's note -> counter val.

                if (temp == 97)
                  temp = 0; // silence

                note = notetab[static_cast<int>(temp)];
                if (m == 0)
                  ch1[rows] = note;
                if (m == 1)
                  ch2[rows] = note;
                if (m == 2)
                  ch3[rows] = note;
                if (m == 3)
                  ch4[rows] = note;

                fileoffset++;
                INFILE.seekg(fileoffset, ios::beg); // read next byte
                INFILE.read((&temp), 1);
                temp = static_cast<unsigned char>(temp);
              }

              if ((pp & 2) == 2) { // if bit 1 is set, it's instrument

                if (m == 0)
                  instr1[rows] = temp;
                if (m == 1)
                  instr2[rows] = temp;
                if (m == 2)
                  instr3[rows] = temp;
                if (m == 3)
                  instr4[rows] = temp;

                fileoffset++;
                INFILE.seekg(fileoffset, ios::beg); // read next byte
                INFILE.read((&temp), 1);
                temp = static_cast<unsigned char>(temp);
              }

              if ((pp & 4) == 4) { // if bit 2 is set, it's volume -> ignore
                fileoffset++;
                INFILE.seekg(fileoffset, ios::beg); // read next byte
                INFILE.read((&temp), 1);
                temp = static_cast<unsigned char>(temp);
              }

              if ((pp & 8) == 8 &&
                  temp ==
                      0xb) { // if bit 3 is set and value is $b (jump to order)
                fileoffset++;
                INFILE.seekg(fileoffset, ios::beg); // read next byte
                INFILE.read((&temp), 1);
                temp = static_cast<unsigned char>(temp);
                looppoint = temp * 2;
                fileoffset++;

              } else if ((pp & 8) == 8 &&
                         temp == 0xf) { // if bit 3 is set and value is $f (set
                                        // speed)
                fileoffset++;
                INFILE.seekg(fileoffset, ios::beg); // read next byte
                INFILE.read((&temp), 1);
                temp = static_cast<unsigned char>(temp);
                if (temp < 0x20)
                  rspeed[rows] = temp;
                fileoffset++;

              } else if ((pp & 8) == 8 &&
                         temp == 0xe) { // if bit 3 is set and value is $e5x
                                        // (finetune)

                fileoffset++;
                INFILE.seekg(fileoffset, ios::beg); // read next byte
                INFILE.read((&temp), 1);
                temp = static_cast<unsigned char>(temp);

                if ((temp & 0xf0) == 0x50) {
                  temp = (temp & 0xf) - 8;
                  if (m == 0)
                    detune1 = int(ch1[rows] / 100) * temp;
                  if (m == 0)
                    detune2 = int(ch2[rows] / 100) * temp;
                  if (m == 0)
                    detune3 = int(ch3[rows] / 100) * temp;
                  if (m == 0)
                    detune4 = int(ch4[rows] / 100) * temp;
                }

                fileoffset++;
              }
            }

          } else { // uncompressed pattern data

            // read notes
            temp = pp;
            if (temp == 97)
              temp = 0; // silence
            // noteval = temp;

            note = notetab[static_cast<int>(temp)];
            if (m == 0)
              ch1[rows] = note;
            if (m == 1)
              ch2[rows] = note;
            if (m == 2)
              ch3[rows] = note;
            if (m == 3)
              ch4[rows] = note;

            fileoffset++;
            INFILE.seekg(fileoffset, ios::beg); // read next byte
            INFILE.read((&temp), 1);
            temp = static_cast<unsigned char>(temp);

            // read instruments
            if (m == 0)
              instr1[rows] = temp;
            if (m == 1)
              instr2[rows] = temp;
            if (m == 2)
              instr3[rows] = temp;
            if (m == 3)
              instr4[rows] = temp;

            // read and ignore volume
            fileoffset++;
            INFILE.seekg(fileoffset, ios::beg); // read next byte
            INFILE.read((&temp), 1);
            temp = static_cast<unsigned char>(temp);

            // read fx command
            fileoffset++;
            INFILE.seekg(fileoffset, ios::beg); // read next byte
            INFILE.read((&temp), 1);
            temp = static_cast<unsigned char>(temp);
            pp = temp;

            // read fx parameter
            fileoffset++;
            INFILE.seekg(fileoffset, ios::beg); // read next byte
            INFILE.read((&temp), 1);
            temp = static_cast<unsigned char>(temp);

            // evaluate fx
            if (pp == 0xb)
              looppoint = temp * 2;
            if (pp == 0xf && temp < 0x20)
              rspeed[rows] = temp;
            if (pp == 0xe && (temp & 0xf) == 0x50) {
              temp = (temp & 0xf) - 8;
              if (m == 0)
                detune1 = int(ch1[rows] / 100) * temp;
              if (m == 0)
                detune2 = int(ch2[rows] / 100) * temp;
              if (m == 0)
                detune3 = int(ch3[rows] / 100) * temp;
              if (m == 0)
                detune4 = int(ch4[rows] / 100) * temp;
            }

            // advance file pointer
            fileoffset++;
          }
        }

        if (ch1[rows] == 0)
          instr1[rows] = 0;
        if (ch2[rows] == 0)
          instr2[rows] = 0;
        if (ch3[rows] == 0)
          instr3[rows] = 0;
        if (ch4[rows] == 0)
          instr4[rows] = 0;

        notech1 = ch1[rows] + detune1;
        notech2 = ch2[rows] + detune2;
        notech3 = ch3[rows] + detune3;
        notech4 = ch4[rows] + detune4;

        OUTFILE << "\tdw #" << hex << +rspeed[rows] << "00,#" << +notech1
                << ",#" << +notech2;
        OUTFILE << ",(HIGH(smp" << +instr1[rows] << "))*256+(HIGH(smp"
                << +instr2[rows] << ")),#";
        OUTFILE << +notech3 << ",#" << +notech4 << ",(HIGH(smp" << +instr3[rows]
                << "))*256+(HIGH(smp" << +instr4[rows] << "))\n";

        // update instrument list
        insused = false;
        for (x = 0; x < 256; x++) {
          if (instr1[rows] == instruments[x])
            insused = true;
        }
        if (insused == false) {
          insamnt++;
          instruments[insamnt] = instr1[rows];
        }
        insused = false;
        for (x = 0; x < 256; x++) {
          if (instr2[rows] == instruments[x])
            insused = true;
        }
        if (insused == false) {
          insamnt++;
          instruments[insamnt] = instr2[rows];
        }
        insused = false;
        for (x = 0; x < 256; x++) {
          if (instr3[rows] == instruments[x])
            insused = true;
        }
        if (insused == false) {
          insamnt++;
          instruments[insamnt] = instr3[rows];
        }
        insused = false;
        for (x = 0; x < 256; x++) {
          if (instr4[rows] == instruments[x])
	    insused = true;
        }
        if (insused == false) {
          insamnt++;
          instruments[insamnt] = instr4[rows];
        }

        detune1 = 0;
        detune2 = 0;
        detune3 = 0;
        detune4 = 0;
      }

      OUTFILE << "\tdb #40\n\n";
    }
  }

  OUTFILE << hex << "loop equ sequence+#" << +looppoint << endl;

  if (debug >= 1)
    cout << "WARNING: " << debug
         << "out of range note(s) replaced with rests.\n";
  cout << "Success!\n";

  INFILE.close();
  OUTFILE.close();

  // read sample list and generate samples.asm
  INFILE.open("samplelist.txt", ios::in);
  if (!INFILE.is_open()) {
    cout << "Error: Could not open samplelist.txt\n";
    return -1;
  }

  OUTFILE.open("samples.asm", ios::out | ios::trunc);

  if (!OUTFILE.is_open()) {
    cout << "Error: Could not create samples.asm - need to set write "
            "permission?\n";
    return -1;
  }

  OUTFILE << "\torg 256*(1+(HIGH($)))\t\t\t;align to 256b "
             "page\nsmp0\t\t\t\t;silence\n\tds 256,0\n\n";

  string instrnames[256];
  i = 0;

  while (getline(INFILE, instrnames[i])) {
    i++;
  }

  for (x = 1; x <= insamnt; x++) {
    OUTFILE << "smp" << +instruments[x] << "\n\t"
            << "include \"samples/" << instrnames[(instruments[x] - 1)]
            << "\"\n";
  }

  INFILE.close();
  OUTFILE.close();
  return 0;
}

// check if a pattern exists in sequence
bool isPatternUsed(int patnum) {

  int usage = false;

  for (fileoffset = 80; fileoffset < ((unsigned)songlength + 80);
       fileoffset++) {
    INFILE.seekg(fileoffset, ios::beg);
    INFILE.read((&cp), 1);
    if (patnum == static_cast<unsigned char>(cp))
      usage = true;
  }

  return (usage);
}
