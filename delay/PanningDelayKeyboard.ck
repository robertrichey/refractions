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


PanningDelay delay[5];

delay[1].initialize(2, 1.333 / 2.0);
delay[2].initialize(7, 1.4);
delay[3].initialize(9, 2.0);
delay[4].initialize(17, 1.125);

0 =>int current;


while (true) {
    keyboard => now;
    
    while (keyboard.recv(message)) {
        if (message.isButtonDown()) {
            keys[message.ascii] => string key;
            
            if (key == "") {
                <<< "----- INVALID (" + message.ascii + ") -----", "" >>>;
            }
            
            if (key == "Q") {
                delay[current].turnOn();
            }
            if (key == "W") {
                delay[current].pitchShift();
            }
            if (key == "A") {
                delay[current].setDelayInterval(0.9);
            }
            if (key == "Z") {
                delay[current].setDelayInterval(1.1);
            }
            if (key == "S") {
                delay[current].setDelayGain(1.03);
            }
            if (key == "X") {
                delay[current].setDelayGain(0.97);
            }
            if (key == " ") {
                delay[current].printStatus();
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
