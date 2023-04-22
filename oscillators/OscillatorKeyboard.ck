Hid keyboard;
HidMsg message;

0 => int device;

if (me.args()) {
    Std.atoi(me.arg(0)) => device;
}
if (!keyboard.openKeyboard(device)) {
    me.exit();
}

<<< "", "" >>>;
<<< "----- Keyboard '" + keyboard.name() + "' ready! -----", "" >>>;
<<< "", "" >>>;


string keys[128];

" " => keys[32];

"," => keys[44];
"." => keys[46];
"/" => keys[47];

"0" => keys[48];
"1" => keys[49];
"2" => keys[50];
"3" => keys[51];
"4" => keys[52];
"5" => keys[53];
"6" => keys[54];
"7" => keys[55];
"8" => keys[56];
"9" => keys[57];

";" => keys[59];

"A" => keys[65];
"B" => keys[66];
"C" => keys[67];
"D" => keys[68];
"E" => keys[69];
"F" => keys[70];
"G" => keys[71];
"H" => keys[72];
"I" => keys[73];
"J" => keys[74];
"K" => keys[75];
"L" => keys[76];
"M" => keys[77];
"N" => keys[78];
"O" => keys[79];
"P" => keys[80];
"Q" => keys[81];
"R" => keys[82];
"S" => keys[83];
"T" => keys[84];
"U" => keys[85];
"V" => keys[86];
"W" => keys[87];
"X" => keys[88];
"Y" => keys[89];
"Z" => keys[90];

"`" => keys[96];


SinOscFM wave[5];

wave[1].setCarrier(0.3, 4649, [40, 44, 47, 48, 47]);
wave[1].setModulator1(19919, 673, 2000);
wave[1].setModulator2(27107, 200, 5000);
wave[1].setPanning(5);
wave[1].initialize();

wave[2].setCarrier(0.25, 7283, [59, 60, 58, 62, 63]);
wave[2].setModulator1(691, 307, 7717);
wave[2].setModulator2(2729, 157, 6599);
wave[2].setPanning(11);
wave[2].initialize();

wave[3].setCarrier(0.25, 2441, [68, 67, 68, 67, 66]);
wave[3].setModulator1(409, 151, 5099);
wave[3].setModulator2(1277, 599, 7907);
wave[3].setPanning(23);
wave[3].initialize();

wave[4].setCarrier(0.1, 1117, [82, 75, 74, 72, 82]);
wave[4].setModulator1(9013, 383, 10067);
wave[4].setModulator2(7951, 223, 14699);
wave[4].setPanning(41);
wave[4].initialize();


0 => int current;

while (true) {
    keyboard => now;
    
    while (keyboard.recv(message)) {
        if (message.isButtonDown()) {
            keys[message.ascii] => string key;
            
            if (key == "") {
                <<< "----- INVALID (" + message.ascii + ") -----", "" >>>;
            }
            if (key == "Q") {
                1 ^=> wave[current].isOn;
            }
            if (key == "W") {
                    1 => wave[current].changePan;
            }
            if (key == "P") {
                for (0 => int i; i < wave.size(); i++) {
                    1 => wave[i].changeNote;
                }
            }
            if (key == "A") {
                wave[current].setVolume(1.1);
            }
            if (key == "Z") {
                wave[current].setVolume(0.9);
            }
            if (key == "S") {
                wave[current].setRamp(1.15);
            }
            if (key == "X") {
                wave[current].setRamp(0.85);
            }
            if (key == "1") {
                1 => current;
            }
            if (key == "2") {
                2 => current;
            }
            if (key == "3") {
                3 => current;
            }
            if (key == "4") {
                4 => current;
            }
        }
    }
}
