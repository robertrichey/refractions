Mandolin mandolin;
NRev reverb;
Echo echo[3];
Gain master;

0.6 => reverb.gain;
0.05 => reverb.mix;

0.2 => master.gain;

mandolin => reverb;


[0, 2, 3, 4,  6, 7, 8,  10, 11] @=> int scale[];


500 => int quarter;
quarter * 2 => int half;
half * 2 => int whole;
quarter / 2 => int eighth;
eighth / 2 => int sixteenth;

quarter / 6.667 => float trillDuration;


for (0 => int i; i < echo.size(); i++) {
    reverb => echo[i] => master => dac;
    half::ms => echo[i].max => echo[i].delay;
    0.0 => echo[i].mix;
}


spork ~ echoControl();


while (true) {
    Math.random2f(0.2, 0.8) => mandolin.pluckPos;
    
    scale[Math.random2(0,scale.size()-1)] => int note;
    Math.random2(5, 7) * 12 => int octave;
    
    Std.mtof(note + octave) => mandolin.freq;
    
    Math.random2f(0.2, 0.9) => mandolin.pluck;
    
    Math.randomf() => float chance;
    
    if (chance > 0.9) {
        quarter::ms => now;
    }
    else if (chance > .925) {
        eighth::ms => now;
    }
    else if (chance > .05) {
        sixteenth::ms => now;
    }
    else {
        0 => int pickDirection;
        
        Math.random2(4, 20) => int trillCount;
        
        0.0 => float pluck;
        0.7 / trillCount => float increment;
        
        for(0 => int i; i < trillCount; i++) {
            trillDuration::ms => now;
            
            Math.random2f(0.2, 0.3) + i * increment => pluck;
            pluck + -0.2 * pickDirection => mandolin.pluck;
            
            // simulate alternate plucking
            !pickDirection => pickDirection;
        }
        trillDuration::ms => now;
    }
}


fun void echoControl() {
    float current;
    
    while (true) {
        Math.random2f(0, 1) => float chance;
        float next;
        
        if (chance < 0.35) {
            0.0 => next;
        }
        else if (chance < 0.55) {
            0.08 => next;
        }
        else if (chance < 0.8) {
            0.5 => next;
        }
        else {
            0.15 => next;
        }
        
        (next - current) / half => float increment; 
        
        for (0 => int i; i < half; i++) {
            increment +=> current;
            
            for (0 => int i; i < echo.size(); i++) {
                current => echo[i].mix;
            }
            1::ms => now;
        }
        
        next => current;
        
        Math.random2(1, 3) * whole::ms => now;
    }
}
