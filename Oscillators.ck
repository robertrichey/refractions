Hid keyboard;
HidMsg message;

0 => int device;

if (me.args()) {
    Std.atoi(me.arg(0)) => device;
}

if (!keyboard.openKeyboard(device)) {
    me.exit();
}


string keys[36];

"A" => keys[0];
"B" => keys[1];
"C" => keys[2];
"D" => keys[3];
"E" => keys[4];
"F" => keys[5];
"G" => keys[6];
"H" => keys[7];
"I" => keys[8];
"J" => keys[9];
"K" => keys[10];
"L" => keys[11];
"M" => keys[12];
"N" => keys[13];
"O" => keys[14];
"P" => keys[15];
"Q" => keys[16];
"R" => keys[17];
"S" => keys[18];
"T" => keys[19];
"U" => keys[20];
"V" => keys[21];
"W" => keys[22];
"X" => keys[23];
"Y" => keys[24];
"Z" => keys[25];
"0" => keys[26];
"1" => keys[27];
"2" => keys[28];
"3" => keys[29];
"4" => keys[30];
"5" => keys[31];
"6" => keys[32];
"7" => keys[33];
"8" => keys[34];
"9" => keys[35];




SinOsc wave => Envelope envelope => Pan2 panning => dac;
SinOsc wave2 => envelope => panning => dac;

550 => int ramp;
ramp::ms => envelope.duration;

10 => int ring;
0 => int signal;


0 => int counter;


0 => int panCounter;


0 => int isOn;
spork ~ play();




float pans[Math.random2(2, 2)];
2.0 / (pans.cap()-1) => float increment;
-1.0 => pans[0];

for (1 => int i; i < pans.cap(); i++) {
    pans[i-1] + increment => pans[i];
}



Std.mtof(60) => wave.freq;
wave.freq() * 2 + 3 => wave2.freq;

0.05 => wave.gain => wave2.gain;

<<< "keyboard '" + keyboard.name() + "' ready", "" >>>;


while (true) {
    keyboard => now;
    
    while (keyboard.recv(message)) {
        if (message.isButtonDown()) {
            keys[message.ascii - 65] => string key;
            <<< Std.itoa(message.ascii) >>>;
            
            if (key == "Q") {
                1 ^=> isOn;
            }
            if (key == "W") {
                counter++;
            }
            if (key == "A") {
                setVolume(1.1);
            }
            if (key == "S") {
                setVolume(0.9);
            }
            if (key == "Z") {
                setRamp(1.15);
            }
            if (key == "X") {
                setRamp(0.85);
            }
        }
    }
}

fun void play() {
    while (true) {
        if (isOn) {
            if (counter % 3 == 0) {
                0 => panning.pan;
            }
            else if (counter % 3 == 1) {
                pans[panCounter % pans.cap()] => panning.pan;
                panCounter++;
            }
            else if (counter % 3 == 2) {
                Math.random2f(-1.0, 1.0) => panning.pan;
            }
            
            <<< counter % 3, panning.pan() >>>;
            
            envelope.keyOn();
            envelope.duration() + ring::ms => now;
            envelope.keyOff();
            envelope.duration() => now;
        }
        samp => now;
    }
}

fun void setVolume(float factor) {
    wave.gain() * factor => wave.gain => wave2.gain;
    <<< wave.gain() >>>;
}

fun void setRamp(float factor) {
    Std.ftoi(factor * ramp) => ramp;
    ramp < 10 ? 10 : ramp > 10000 ? 10000 : ramp => ramp;
    ramp::ms => envelope.duration;
    <<< ramp, "ms" >>>;
}

fun void setPan() {
    float pans[Math.random2(2, 2)];
    2.0 / (pans.cap()-1) => float increment;
    -1.0 => pans[0];
    
    for (1 => int i; i < pans.cap(); i++) {
        pans[i-1] + increment => pans[i];
    }
}