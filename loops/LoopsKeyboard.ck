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


LisaObject lisa[4];

lisa[0].initialize(1.333, 0, "LiSa 1");
lisa[1].initialize(1.5 / 2.0, 1, "LiSa 2");
lisa[2].initialize(0.5, 1, "LiSa 3");
lisa[3].initialize(1.25, 2, "LiSa 4");


1 => int current;

0 => int isArmed;
"M" => string trigger;

while (true) {
    keyboard => now;
    
    while (keyboard.recv(message)) {
        if (message.isButtonDown()) {
            keys[message.ascii] => string key;
            
            if (key == "N" || key == "M" || key == "," || key == "." || key == "/") {
                key == trigger ? 1 : 0 => isArmed;
                
                if (isArmed) {
                    <<< "LOOPING IS ARMED" >>>;
                }
            }
            if (isArmed) {                
                if (key == "") {
                    <<< "----- INVALID (" + message.ascii + ") -----", "" >>>;
                }
                if (key == "Q") {
                    spork ~ lisa[current].toggleOn();
                }
                if (key == "W") {
                    spork ~ lisa[current].loopMode();
                }
                if (key == "O") {
                    spork ~ lisa[current].record();
                }
                if (key == "A") {
                    spork ~ lisa[current].setVolume(1.1);
                }
                if (key == "Z") {
                    spork ~ lisa[current].setVolume(0.9);
                }
                if (key == " ") {
                    <<< "", "" >>>;
                    for (0 => int i; i < lisa.size(); i++) {
                        lisa[i].printStatus();
                    }
                    <<< "", "" >>>;
                }
                if (key == "X") {
                    //spork ~ lisa[current].setPan(1);
                }
                if (key == "1") {
                    0 => current;
                }
                if (key == "2") {
                    1 => current;
                }
                if (key == "3") {
                    2 => current;
                }
                if (key == "4") {
                    3 => current;
                }
            }
        }
    }
}
