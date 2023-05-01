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


GrainObject granular[3];

granular[0].initialize(0);
granular[1].initialize(-1);
granular[2].initialize(1);

for (0 => int i; i < granular.size(); i++) {
    spork ~ granular[i].play();
}

1 => int current;

0 => int isArmed;
"," => string trigger;

while (true) {
    keyboard => now;
    
    while (keyboard.recv(message)) {
        if (message.isButtonDown()) {
            keys[message.ascii] => string key;
            
            if (key == "N" || key == "M" || key == "," || key == "." || key == "/") {
                key == trigger ? 1 : 0 => isArmed;
                
                if (isArmed) {
                    <<< "GRANULAR IS ARMED" >>>;
                }
            }
            if (isArmed) {                
                if (key == "") {
                    <<< "----- INVALID (" + message.ascii + ") -----", "" >>>;
                }
                if (key == "E") {
                    for (0 => int i; i < granular.size(); i++) {
                        spork ~ granular[i].setBufferLength(1.1);
                    }
                }
                if (key == "D") {
                    for (0 => int i; i < granular.size(); i++) {
                        spork ~ granular[i].setBufferLength(0.9);
                    }
                }
                if (key == "R") {
                    for (0 => int i; i < granular.size(); i++) {
                        spork ~ granular[i].setGrainLength(1.1);
                    }
                }
                if (key == "F") {
                    for (0 => int i; i < granular.size(); i++) {
                        spork ~ granular[i].setGrainLength(0.9);
                    }                
                }
                if (key == "T") {
                    for (0 => int i; i < granular.size(); i++) {
                        spork ~ granular[i].setGrainInterval(1.1);
                    }                
                }
                if (key == "G") {
                    for (0 => int i; i < granular.size(); i++) {
                        spork ~ granular[i].setGrainInterval(0.9);
                    }    
                }
                if (key == "W") {
                    for (0 => int i; i < granular.size(); i++) {
                        spork ~ granular[i].setMaxVoices(2);
                    }    
                }
                if (key == "S") {
                    for (0 => int i; i < granular.size(); i++) {
                        spork ~ granular[i].setMaxVoices(-2);
                    }  
                }
                if (key == "Q") {
                    for (0 => int i; i < granular.size(); i++) {
                        spork ~ granular[i].setGain(1.1);
                    }  
                }
                if (key == "A") {
                    for (0 => int i; i < granular.size(); i++) {
                        spork ~ granular[i].setGain(0.9);
                    }  
                }
                if (key == "O") {
                    for (0 => int i; i < granular.size(); i++) {
                        spork ~ granular[i].toggleOn();
                    }  
                }
                if (key == " ") {
                    <<< "", "" >>>;
                    granular[0].printStatus();
                    <<< "", "" >>>;
                }
            }
        }
    }
}
