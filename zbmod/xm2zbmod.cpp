#include <math.h>
#include <fstream>
#include <iostream>
#include <string>

#include "xmkit.h"

using namespace std;

int main(int argc, char *argv[]) {
    cout << "XM 2 ZBMOD CONVERTER\n";

    bool verbose = false;
    bool testRange = false;
    string infile = "music.xm";

    for (int i = 1; i < argc; i++) {
        string arg = argv[i];
        if (arg == "-v") verbose = true;
        if (arg == "-r") testRange = true;
        if (arg == "-i" && i < argc - 1) infile = argv[i + 1];
    }

    xmod xm;
    if (!xm.read(infile, 4, verbose)) return -1;

    const unsigned char notetab[49] = {
        0,    0x11, 0x12, 0x13, 0x14, 0x15, 0x17, 0x18, 0x19, 0x1B,
        0x1C, 0x1E, 0x20, 0x22, 0x24, 0x26, 0x28, 0x2B, 0x2D, 0x30,
        0x33, 0x36, 0x39, 0x3C, 0x40, 0x44, 0x48, 0x4C, 0x50, 0x55,
        0x5A, 0x60, 0x65, 0x6B, 0x72, 0x78, 0x80, 0x87, 0x8F, 0x98,
        0xA1, 0xAA, 0xB4, 0xBF, 0xCA, 0xD6, 0xE3, 0xF1, 0xFF};

    const string noteNames[12] = {"C-", "C#", "D-", "D#", "E-", "F-",
                                  "F#", "G-", "G#", "A-", "A#", "B-"};

    unsigned long binsize = 0;

    xm.extractPatterns();
    xm.extractInstruments(verbose);

    const float zbSampleRate = 3500000.00000 / 384.00000;
    const float fq = 1.059463094359;
    const float xmBaseFreq = 8259.41776338;
    float inpSampleRate, shift, downSample;
    int intShift[xm.uniqueInstruments];
    int intDownSample[xm.uniqueInstruments];
    intShift[0] = 0;
    intDownSample[0] = 0;

    for (int instr = 1; instr <= xm.uniqueInstruments; instr++) {
        if (xm.isInstrumentUsed(instr)) {
            inpSampleRate = xmBaseFreq * pow(fq, xm.instrSmpRelNotes[instr][0]);

            downSample = inpSampleRate / zbSampleRate;

            if (downSample <= 0.500) {
                cout << "Error: Relative note of sample " << instr
                     << " is below the threshold handled by xm2zbmod.\n";
                return -1;
            }

            if (downSample < 0)
                intDownSample[instr] = static_cast<int>(downSample - 0.50);
            else
                intDownSample[instr] = static_cast<int>(downSample + 0.50);

            shift = 12 * log2f(downSample - intDownSample[instr] + 1);
            if (shift < 0)
                shift = shift - 0.50;
            else
                shift = shift + 0.50;
            intShift[instr] = static_cast<int>(shift);

            if (verbose)
                cout << dec << "instr " << instr
                     << " float downSample: " << downSample
                     << " float shift: " << shift;
            if (verbose)
                cout << " int downsample " << intDownSample[instr]
                     << " int shift " << intShift[instr] << endl;
            if ((testRange) || (verbose)) {
                cout << "Range for instrument " << instr;
                if (intShift[instr] < 0)
                    cout << ": " << noteNames[abs(intShift[instr])] << "0 - "
                         << noteNames[abs(intShift[instr]) - 1] << "4\n";
                else if (intShift[instr] == 0)
                    cout << ": C-0 - B-3\n";
                else
                    cout << ": C-0 -" << noteNames[12 - intShift[instr]]
                         << "3\n";
            }
        }
    }

    if (testRange) return 0;

    ofstream ASMFILE;
    ASMFILE.open("music.asm", ios::out | ios::trunc);
    if (!ASMFILE.is_open()) {
        cout << "Error: Could not create music.asm - need to set write "
                "permission?\n";
        return -1;
    }
    ofstream SMPFILE;
    SMPFILE.open("samples.asm", ios::out | ios::trunc);
    if (!SMPFILE.is_open()) {
        cout << "Error: Could not create samples.asm - need to set write "
                "permission?\n";
        return -1;
    }
    ofstream SMPTABFILE;
    SMPTABFILE.open("sampletab.asm", ios::out | ios::trunc);
    if (!SMPTABFILE.is_open()) {
        cout << "Error: Could not create sampletab.asm - need to set write "
                "permission?\n";
        return -1;
    }

    ASMFILE << "sequence\n";

    for (int i = 0; i < xm.seqLength; i++) {
        if (i == xm.loopPoint) ASMFILE << "loop\n";
        ASMFILE << hex << "\tdw ptn" << +xm.sequence[i] << endl;
        binsize += 2;
    }

    ASMFILE << "\tdw 0\n\n\t\t\t;patterns\n";

    for (int ptn = 0; ptn < xm.uniquePtns; ptn++) {
        if (xm.isPtnUsed(ptn)) {
            unsigned char notech1, notech2, notech3;

            ASMFILE << "ptn" << ptn << endl;

            for (int row = 1; row <= xm.ptnLengths[ptn]; row++) {
                if (xm.ptnNotes[ptn][0][row] +
                            intShift[xm.ptnInstruments[ptn][0][row]] <
                        0 ||
                    xm.ptnNotes[ptn][0][row] +
                            intShift[xm.ptnInstruments[ptn][0][row]] >
                        48) {
                    cout << "Error: Note out of range in pattern " << hex << ptn
                         << " track 1 row " << row << endl;
                    if (verbose) {
                        cout << "invalid value: "
                             << +(xm.ptnNotes[ptn][0][row] +
                                  intShift[xm.ptnInstruments[ptn][0][row]]);
                        cout << ", intShift: "
                             << intShift[xm.ptnInstruments[ptn][0][row]];
                        cout << ", input: " << +xm.ptnNotes[ptn][0][row];
                        cout << ", instrument: "
                             << +xm.ptnInstruments[ptn][0][row] << endl;
                    }
                    ASMFILE.close();
                    SMPFILE.close();
                    SMPTABFILE.close();
                    return -1;
                }
                if (xm.ptnNotes[ptn][1][row] +
                            intShift[xm.ptnInstruments[ptn][1][row]] <
                        0 ||
                    xm.ptnNotes[ptn][1][row] +
                            intShift[xm.ptnInstruments[ptn][1][row]] >
                        48) {
                    cout << "Error: Note out of range in pattern " << hex << ptn
                         << " track 2 row " << row << endl;
                    if (verbose) {
                        cout << "invalid value: "
                             << +(xm.ptnNotes[ptn][1][row] +
                                  intShift[xm.ptnInstruments[ptn][1][row]]);
                        cout << ", intShift: "
                             << intShift[xm.ptnInstruments[ptn][1][row]];
                        cout << ", input: " << +xm.ptnNotes[ptn][1][row];
                        cout << ", instrument: "
                             << +xm.ptnInstruments[ptn][1][row] << endl;
                    }
                    ASMFILE.close();
                    SMPFILE.close();
                    SMPTABFILE.close();
                    return -1;
                }
                if (xm.ptnNotes[ptn][2][row] +
                            intShift[xm.ptnInstruments[ptn][2][row]] <
                        0 ||
                    xm.ptnNotes[ptn][2][row] +
                            intShift[xm.ptnInstruments[ptn][2][row]] >
                        48) {
                    cout << "Error: Note out of range in pattern " << hex << ptn
                         << " track 3 row " << row << endl;
                    if (verbose) {
                        cout << "invalid value: "
                             << +(xm.ptnNotes[ptn][2][row] +
                                  intShift[xm.ptnInstruments[ptn][2][row]]);
                        cout << ", intShift: "
                             << intShift[xm.ptnInstruments[ptn][2][row]];
                        cout << ", input: " << +xm.ptnNotes[ptn][2][row];
                        cout << ", instrument: "
                             << +xm.ptnInstruments[ptn][2][row] << endl;
                    }
                    ASMFILE.close();
                    SMPFILE.close();
                    SMPTABFILE.close();
                    return -1;
                }

                notech1 = notetab[xm.ptnNotes[ptn][0][row] +
                                  intShift[xm.ptnInstruments[ptn][0][row]]] +
                          xm.ptnDetune[ptn][0][row] - 8;
                notech2 = notetab[xm.ptnNotes[ptn][1][row] +
                                  intShift[xm.ptnInstruments[ptn][1][row]]] +
                          xm.ptnDetune[ptn][1][row] - 8;
                notech3 = notetab[xm.ptnNotes[ptn][2][row] +
                                  intShift[xm.ptnInstruments[ptn][2][row]]] +
                          xm.ptnDetune[ptn][2][row] - 8;

                unsigned char ctrlb = 0;
                if ((xm.ptnNotes[ptn][2][row] ==
                     xm.ptnNotes[ptn][2][row - 1]) &&
                    !xm.ptnTriggers[ptn][2][row])
                    ctrlb = (ctrlb | 1);
                if ((xm.ptnNotes[ptn][1][row] ==
                     xm.ptnNotes[ptn][1][row - 1]) &&
                    !xm.ptnTriggers[ptn][1][row])
                    ctrlb = (ctrlb | 4);
                if ((xm.ptnNotes[ptn][0][row] ==
                     xm.ptnNotes[ptn][0][row - 1]) &&
                    !xm.ptnTriggers[ptn][0][row])
                    ctrlb = (ctrlb | 0x40);
                if (row == 1) ctrlb = 0;

                ASMFILE << "\tdb #" << hex << +ctrlb << ",#"
                        << +xm.ptnRowSpeeds[ptn][row] << "\n";

                if ((ctrlb & 0x40) != 0x40) {
                    ASMFILE << hex << "\tdb #" << +notech1 << ",#"
                            << +xm.ptnInstruments[ptn][0][row] * 4 << endl;
                    binsize += 2;
                }
                if ((ctrlb & 4) != 4) {
                    ASMFILE << hex << "\tdb #" << +notech2 << ",#"
                            << +xm.ptnInstruments[ptn][1][row] * 4 << endl;
                    binsize += 2;
                }
                if ((ctrlb & 1) != 1) {
                    ASMFILE << hex << "\tdb #" << +notech3 << ",#"
                            << +xm.ptnInstruments[ptn][2][row] * 4
                            << "\n\tdw smp" << +xm.ptnInstruments[ptn][2][row]
                            << endl;
                    binsize += 4;
                }

                // ASMFILE << "\tdw core0\n";
                binsize += 2;
            }

            ASMFILE << "\tdb #80\n\n";
            binsize++;
        }
    }

    SMPTABFILE << "\tdw smp0,smp0\n";
    binsize += 4;

    for (int i = 1; i <= xm.uniqueInstruments; i++) {
        if (xm.isInstrumentUsed(static_cast<unsigned char>(i))) {
            SMPTABFILE << "\tdw smp";

            if (xm.instrSmpLoopType[i][0] == 1)
                SMPTABFILE << hex << i << "+#"
                           << static_cast<unsigned>(xm.instrSmpLoopStart[i][0] /
                                                    5)
                           << ",";
            else
                SMPTABFILE << "0,";

            SMPTABFILE << hex << "smp" << i << endl;
            binsize += 4;
        }
    }

    SMPFILE << "smp0\n\tdb 1,0\n\n";
    binsize += 2;

    for (int i = 1; i <= xm.uniqueInstruments; i++) {
        if (xm.isInstrumentUsed(static_cast<unsigned char>(i))) {
            SMPFILE << hex << "smp" << i;

            // TODO: upsample if intDownSample is negative
            for (long j = 0; j < xm.instrSmpLengths[i][0];
                 j += intDownSample[i]) {
                if (j % (intDownSample[i] * 32) == 0)
                    SMPFILE << "\n\tdb ";
                else
                    SMPFILE << ",";

                unsigned long temph;

                if (!xm.instrSmp16Bit[i][0]) {
                    if ((xm.instrSamples[i][0][j] & 0x80) == 0x80)
                        xm.instrSamples[i][0][j] =
                            xm.instrSamples[i][0][j] & 0x7f;
                    else
                        xm.instrSamples[i][0][j] =
                            xm.instrSamples[i][0][j] | 0x80;
                    temph = reinterpret_cast<unsigned char &>(
                        xm.instrSamples[i][0][j]);
                    temph = static_cast<unsigned long>(temph * 7 / 256) + 1;
                } else {
                    if ((xm.instrSamples[i][0][j] & 0x8000) == 0x8000)
                        xm.instrSamples[i][0][j] =
                            xm.instrSamples[i][0][j] & 0x7fff;
                    else
                        xm.instrSamples[i][0][j] =
                            xm.instrSamples[i][0][j] | 0x8000;
                    temph = reinterpret_cast<unsigned short &>(
                        xm.instrSamples[i][0][j]);
                    temph = static_cast<unsigned long>(temph * 7 / 65536) + 1;
                }

                SMPFILE << hex << "#" << temph;
                binsize++;

                // if ((j + intDownSample[i]) % (intDownSample[i] * 32) != 0)
                // SMPFILE << ",";
            }

            SMPFILE << ",0\n\n";
            binsize++;
        }
    }

    int error = 0;
    if (verbose) cout << hex << "data size: 0x" << binsize << " bytes.\n";
    if (binsize + 0x99ab > 0xffc0) {
        cout << "Error: Maximum data size exceeded by "
             << ((binsize + 0x99ab) - 0xffc0) << " bytes\n";
        error = -1;
    } else
        cout << "Succes!\n";
    ASMFILE.close();
    SMPFILE.close();
    SMPTABFILE.close();
    return error;
}
