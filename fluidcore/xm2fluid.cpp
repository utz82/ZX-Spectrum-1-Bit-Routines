#include <fstream>
#include <iomanip>
#include <iostream>
#include <string>

using namespace std;

unsigned fileoffset;
unsigned char songlength;
ifstream INFILE;
const unsigned char flags[] = {1, 0x40, 4, 0x80};

bool isPatternUsed(int patnum);

int main(int argc, char* argv[]) {
  cout << "XM 2 FLUIDCORE CONVERTER\n";

  // check for "-v" flag
  string arg = "";
  if (argc > 1) arg = argv[1];

  // open music.xm
  INFILE.open("music.xm", ios::in | ios::binary);
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

  auto readByte = [](unsigned offset) -> unsigned char {
    char c;
    INFILE.seekg(offset, ios::beg);
    INFILE.read((&c), 1);
    return static_cast<unsigned char>(c);
  };

  // verify xm parameters
  if (readByte(58) != 4) {
    cout << "Error: Obsolete XM version 1.0" << +readByte(58)
         << ", v1.04 required" << endl;
    return -1;
  }

  // read # of channels
  if (readByte(68) != 4) {
    cout << "Error: XM has " << +readByte(68) << " channels instead of 4"
         << endl;
    return -1;
  }

  // read global song parameters
  unsigned char uniqueptns;
  unsigned char speed;

  // read song length
  songlength = readByte(64);
  if (arg == "-v") cout << "song length:     " << +songlength << endl;

  // read # of unique patterns
  uniqueptns = readByte(70);
  if (arg == "-v") cout << "unique patterns: " << +uniqueptns << endl;

  // read global tempo
  speed = readByte(76);
  if (arg == "-v") cout << "global tempo:    " << +readByte(76) << endl;

  // locate the pattern headers and read pattern lengths
  unsigned ptnoffsetlist[256];
  unsigned ptnlengths[256];
  unsigned headlength, packedlength;
  unsigned char pp;
  int i;

  // first pattern is at 60 + XM header length
  ptnoffsetlist[0] = 60 + readByte(60) + readByte(61) * 256;
  fileoffset = ptnoffsetlist[0];

  for (i = 0; i < uniqueptns; i++) {
    headlength = static_cast<unsigned>(readByte(fileoffset));

    fileoffset += 5;
    ptnlengths[i] = static_cast<unsigned>(readByte(fileoffset));

    fileoffset += 2;
    packedlength = static_cast<unsigned>(readByte(fileoffset));

    fileoffset++;
    packedlength += (static_cast<unsigned>(readByte(fileoffset))) * 256;

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
    OUTFILE << "\tdw ptn" << hex << +readByte(fileoffset) << endl;
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
  int track;
  unsigned char row, ctrlbyte;
  unsigned char insamnt = 0;
  bool insused;
  char temp;
  int detune[] = {0, 0, 0, 0};
  int freq[] = {0, 0, 0, 0};
  int previousFreq[4];
  // unsigned char previousInstr[4];
  bool triggers[4];
  int debug = 0;
  int notes[4][257];  // [track][row]
  unsigned char instr[4][257];
  unsigned char rspeed[257], instruments[257];

  for (i = 0; i < 257; ++i) instruments[i] = 0;

  for (i = 0; i <= (uniqueptns)-1; i++) {
    if (isPatternUsed(i)) {
      OUTFILE << "ptn" << i << endl;

      for (track = 0; track < 4; ++track) {
        notes[track][0] = 0;
        instr[track][0] = 0;
        // previousInstr[track] = 0;
        previousFreq[track] = 0;
      }

      rspeed[0] = speed;

      fileoffset = ptnoffsetlist[i] + 9;

      for (row = 1; row <= ptnlengths[i]; row++) {
        ctrlbyte = 0;

        for (track = 0; track < 4; ++track) {
          notes[track][row] = notes[track][row - 1];
          instr[track][row] = instr[track][row - 1];
        }

        rspeed[row] = rspeed[row - 1];

        for (track = 0; track <= 3; track++) {
          triggers[track] = false;
          pp = readByte(fileoffset);

          if (pp >= 128) {  // have compressed pattern data

            fileoffset++;

            if (pp != 128) {
              temp = readByte(fileoffset);

              if ((pp & 1) ==
                  1) {  // if bit 0 is set, it's note -> counter val.

                if (temp == 97) temp = 0;  // silence

                notes[track][row] = notetab[static_cast<int>(temp)];
                triggers[track] = true;
                fileoffset++;
                temp = readByte(fileoffset);
              }

              if ((pp & 2) == 2) {  // if bit 1 is set, it's instrument
                instr[track][row] = temp;
                fileoffset++;
                temp = readByte(fileoffset);
              }

              if ((pp & 4) == 4) {  // if bit 2 is set, it's volume -> ignore
                fileoffset++;
                temp = readByte(fileoffset);
              }

              if ((pp & 8) == 8 &&
                  temp ==
                      0xb) {  // if bit 3 is set and value is $b (jump to order)
                fileoffset++;
                temp = readByte(fileoffset);
                looppoint = temp * 2;
                fileoffset++;

              } else if ((pp & 8) == 8 &&
                         temp == 0xf) {  // if bit 3 is set and value is $f (set
                                         // speed)
                fileoffset++;
                temp = readByte(fileoffset);
                if (temp < 0x20) rspeed[row] = temp;
                fileoffset++;

              } else if ((pp & 8) == 8 &&
                         temp == 0xe) {  // if bit 3 is set and value is $e5x
                                         // (finetune)

                fileoffset++;
                temp = readByte(fileoffset);

                if ((temp & 0xf0) == 0x50) {
                  temp = (temp & 0xf) - 8;
                  detune[track] = int(notes[track][row] / 100) * temp;
                }

                fileoffset++;
              }
            }

          } else {  // uncompressed pattern data

            // read notes
            temp = pp;
            if (temp == 97) temp = 0;  // silence

            notes[track][row] = notetab[static_cast<int>(temp)];
            triggers[track] = true;

            // read instruments
            fileoffset++;
            temp = readByte(fileoffset);
            instr[track][row] = temp;

            // read and ignore volume
            fileoffset++;
            temp = readByte(fileoffset);

            // read fx command
            fileoffset++;
            temp = readByte(fileoffset);
            pp = temp;

            // read fx parameter
            fileoffset++;
            temp = readByte(fileoffset);
            if (pp == 0xb) looppoint = temp * 2;
            if (pp == 0xf && temp < 0x20) rspeed[row] = temp;
            if (pp == 0xe && (temp & 0xf0) == 0x50) {
              temp = (temp & 0xf) - 8;
              detune[track] = int(notes[3][row] / 100) * temp;
            }

            fileoffset++;
          }
        }

        for (track = 0; track < 4; ++track) {
          if (notes[track][row] == 0) instr[track][row] = 0;
          freq[track] = notes[track][row] + detune[track];
          if (triggers[track] || (freq[track] != previousFreq[track]) ||
              instr[track][row] != instr[track][row - 1]) {
            ctrlbyte |= flags[track];
          }
        }

        if (row == 1) ctrlbyte = flags[0] + flags[1] + flags[2] + flags[3];

        // OUTFILE << "\tdw #" << hex << setfill('0') << setw(2) << +rspeed[row]
        //         << setw(2) << +ctrlbyte;
        // for (track = 0; track < 4; ++track) {
        //   if (ctrlbyte & flags[track]) {
        //     OUTFILE << ",#" << +freq[track] << ",(HIGH(smp"
        //             << +instr[track][row] << "))*256";
        //   }
        // }

        OUTFILE << "\tdb #" << hex << +ctrlbyte << ",#" << +rspeed[row];
        for (track = 0; track < 4; ++track) {
          if (ctrlbyte & flags[track]) {
            OUTFILE << ",#" << +(freq[track] & 0xff) << ",#"
                    << +((freq[track] >> 8) & 0xff) << ",(HIGH(smp"
                    << +instr[track][row] << "))";
          }
        }

        OUTFILE << endl;

        // OUTFILE << "\tdw #" << hex << +rspeed[row] << "00,#" << +freq[0] <<
        // ",#"
        //         << +freq[1];
        // OUTFILE << ",(HIGH(smp" << +instr[0][row] << "))*256+(HIGH(smp"
        //         << +instr[1][row] << ")),#";
        // OUTFILE << +freq[2] << ",#" << +freq[3] << ",(HIGH(smp"
        //         << +instr[2][row] << "))*256+(HIGH(smp" << +instr[3][row]
        //         << "))\n";

        for (track = 0; track < 4; ++track) {
          previousFreq[track] = freq[track];
          // previousInstr[track] = instr[track][row];
        }

        // update instrument list
        for (track = 0; track < 4; ++track) {
          insused = false;
          for (int x = 0; x < 256; x++) {
            if (instr[track][row] == instruments[x]) insused = true;
          }
          if (insused == false) {
            insamnt++;
            instruments[insamnt] = instr[track][row];
          }
        }
        for (track = 0; track < 3; ++track) detune[track] = 0;
      }

      OUTFILE << "\tdw 0\n\n";
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

  for (i = 1; i <= insamnt; ++i) {
    OUTFILE << "smp" << +instruments[i] << "\n\t"
            << "include \"samples/" << instrnames[(instruments[i] - 1)]
            << "\"\n";
  }

  INFILE.close();
  OUTFILE.close();
  return 0;
}

// check if a pattern exists in sequence
bool isPatternUsed(int patnum) {
  int usage = false;
  char cp;

  for (fileoffset = 80; fileoffset < ((unsigned)songlength + 80);
       fileoffset++) {
    INFILE.seekg(fileoffset, ios::beg);
    INFILE.read((&cp), 1);
    if (patnum == static_cast<unsigned char>(cp)) usage = true;
  }

  return (usage);
}
