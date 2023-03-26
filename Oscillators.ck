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




5 => int voiceCount;
SinOsc waves[voiceCount];
SinOsc octaves[voiceCount];
Envelope envelopes[voiceCount];
Pan2 pannings[voiceCount];
int isOn[voiceCount];
int counter[voiceCount];
int panCounter[voiceCount];
int ramps[voiceCount];
float panSettings[voiceCount][12];




setSoundChain();

setPanning();




while (true) {
    keyboard => now;
    
    while (keyboard.recv(message)) {
        if (message.isButtonDown()) {
            keys[message.ascii] => string key;
            
            if (key == "") {
                <<< "----- INVALID (" + message.ascii + ") -----", "" >>>;
            }
            
            if (key == " ") {
                printStatus();
            }
            
            findWave(key) @=> int pair[];
            pair[0] => int action;
            pair[1] => int which;

            if (action == 0) {
                1 ^=> isOn[which];
                spork ~ play(which);
                
                isOn[which] ? "ON" : "OFF" => string status;
                <<< "Oscillator", which, "is", status >>>;
            }
            if (action == 1) {
                counter[which]++;
                
                string status;
                
                if (counter[which] % 3 == 0) {
                    "CENTER" => status;
                }
                else if (counter[which] % 3 == 1) {
                    "LEFT -> RIGHT" => status;
                }
                else {
                    "RANDOM" => status;
                }
                
                <<< "Oscillator", which, "panning set to", status >>>;
            }
            if (action == 2) {
                setVolume(which, 1.1);
            }
            if (action == 4) {
                setVolume(which, 0.9);
            }
            if (action == 3) {
                setRamp(which, 1.15);
            }
            if (action == 5) {
                setRamp(which, 0.85);
            }
        }
    }
}




fun void play(int which) {
    10 => int ring;
    
    while (isOn[which]) {
        if (counter[which] % 3 == 0) {
            0 => pannings[which].pan;
        }
        else if (counter[which] % 3 == 1) { 
            panSettings[which][panCounter[which]] => pannings[which].pan;
            panCounter[which]++;
            
            if (panSettings[which][panCounter[which]] > 1.0) {
                0 => panCounter[which];
            }
        }
        else if (counter[which] % 3 == 2) {
            Math.random2f(-1.0, 1.0) => pannings[which].pan;
        }

        envelopes[which].keyOn();
        envelopes[which].duration() + ring::ms => now;
        envelopes[which].keyOff();
        envelopes[which].duration() => now;
    }
}


fun int[] findWave(string key) {
    [
    ["Q", "E", "T", "U", "O"],
    ["W", "R", "Y", "I", "P"],
    ["A", "D", "G", "J", "L"],
    ["S", "F", "H", "K", ";"],
    ["Z", "C", "B", "M", "."],
    ["X", "V", "N", ",", "/"]
    ] @=> string values[][];
    
    int pair[2];
    0 => int found;
    
    for (0 => int i; i < values.size(); i++) {
        for (0 => int j; j < values[i].size(); j++) {
            if (values[i][j] == key) {
                1 => found;
                i => pair[0];
                j => pair[1];
                break;
            }
        }
    }
    
    if (!found) {
        -1 => pair[0];
        -1 => pair[1];
    }
    return pair;
}


fun void setVolume(int which, float factor) {
    waves[which].gain() * factor => waves[which].gain => octaves[which].gain;
    factor > 1.0 ? "UP:" : "DOWN:" => string status;
    <<< "Oscillator", which, "gain", status, waves[which].gain() >>>;
}


fun void setRamp(int which, float factor) {
    Std.ftoi(factor * ramps[which]) => ramps[which];
    ramps[which] < 10 ? 10 : ramps[which] > 10000 ? 10000 : ramps[which] => ramps[which];
    ramps[which]::ms => envelopes[which].duration;

    factor > 1.0 ? "UP:" : "DOWN:" => string status;
    <<< "Oscillator", which, "envelope", status, ramps[which], "ms" >>>;
}


fun void setSoundChain() {
    [30, 47, 65, 83, 85] @=> int notes[];
    
    for (0 => int i; i < voiceCount; i++) {
        waves[i] => envelopes[i] => pannings[i] => dac;
        octaves[i] => envelopes[i] => pannings[i] => dac;
        
        500 => ramps[i];
        ramps[i]::ms => envelopes[i].duration;
        
        Std.mtof(notes[i]) => waves[i].freq;
        waves[i].freq() * 2 + 80 => octaves[i].freq;
        
        0.01 => waves[i].gain => octaves[i].gain;
    }
}


fun void setPanning() {
    [1, 3, 5, 7, 11] @=> int pans[];
    
    for (0 => int i; i < panSettings.size(); i++) {
        2.0 / (pans[i]-1) => float increment;
        -1.0 => panSettings[i][0];
        
        for (1 => int j; j < panSettings[i].size(); j++) {
            j < pans[i] ? panSettings[i][j-1] + increment : 2.0 => panSettings[i][j];
        }
    }
}


fun void printStatus() {
    <<< "----------------------------------------------------------------------", "" >>>;
    
    for (0 => int i; i < voiceCount; i++) {
        isOn[i] ? "ON" : "OFF" => string onOrOff;
        
        string panMode;
        
        if (counter[i] % 3 == 0) {
            "CENTER" => panMode;
        }
        else if (counter[i] % 3 == 1) {
            "LEFT -> RIGHT" => panMode;
        }
        else {
            "RANDOM" => panMode;
        }
        
        <<< "Oscillator", i, "  ", onOrOff, "   ", "Panning mode:", panMode, "   ", "Envelope:", ramps[i], "ms" >>>;
        
    }
    <<< "----------------------------------------------------------------------", "" >>>;
    <<< "", "" >>>;
}
