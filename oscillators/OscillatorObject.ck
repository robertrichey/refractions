public class SinOscFM {
    SinOsc carrier => Envelope masterEnvelope => Pan2 panning => dac;
    SinOsc modulator1 => Envelope envelope1 => carrier;
    SinOsc modulator2 => Envelope envelope2 => carrier;
    
    
    2 => carrier.sync;

    
    int ramp;

    
    0 => int noteIndex;
    int notes[];
    
    
    0 => int changeNote;
    0 => int isOn;
    
    
    0 => int panMode;
    0 => int panIndex;
    0 => int changePan;
    float panSettings[];
    
    
    fun void play() {
        while (true) {
            if (isOn) {
                if (panMode == 0) {
                    0 => panning.pan;
                }
                else if (panMode == 1) { 
                    panSettings[panIndex] => panning.pan;
                    (panIndex + 1) % panSettings.size() => panIndex;
                }
                else if (panMode == 2) {
                    Math.random2f(-1.0, 1.0) => panning.pan;
                }
                
                masterEnvelope.keyOn();
                masterEnvelope.duration() => now;
                
                masterEnvelope.keyOff();
                masterEnvelope.duration() => now;
                
                if (changeNote) {
                    0 => changeNote;
                    setNoteToNext();
                }
                if (changePan) {
                    0 => changePan;
                    setPanMode();
                }
            }
            ms => now;
        }
    }
    
    
    fun void modulate1() {
        while (true) {
            envelope1.keyOn();
            envelope1.duration() => now;
            
            envelope1.keyOff();
            envelope1.duration() => now;
        }
    }
    
    fun void modulate2() {
        while (true) {
            envelope2.keyOn();
            envelope2.duration() => now;
            
            envelope2.keyOff();
            envelope2.duration() => now;
        }
    }
    
    fun void initialize() {  
        spork ~ modulate1();
        spork ~ modulate2();
        spork ~ play();
    }
    
    fun void setCarrier(float gain, int duration, int arr[]) {
        gain => carrier.gain;
        duration => ramp;
        ramp::ms => masterEnvelope.duration;
        arr @=> notes;
        Std.mtof(notes[noteIndex] - 4) => carrier.freq;
    }
    
    fun void setModulator1(int frequency, float gain, int duration) {
        frequency => modulator1.freq;
        gain => modulator1.gain;
        duration::ms => envelope1.duration;
    }
    
    fun void setModulator2(int frequency, float gain, int duration) {
        frequency => modulator2.freq;
        gain => modulator2.gain;
        duration::ms => envelope2.duration;
    }
    
    fun void setPanning(int panCount) {
        float arr[panCount];
        
        if (panCount == 0) {
            0 => arr[0];
        }
        else {
            -1.0 => arr[0];
            2.0 / (panCount - 1) => float increment;
            
            for (1 => int i; i < arr.size(); i++) {
                arr[i-1] + increment => arr[i];
            }
        }
        
        arr @=> panSettings;
    }
    
    
    fun void setNoteToNext() {
        (noteIndex + 1) % notes.size() => noteIndex;
        Std.mtof(notes[noteIndex] - 4) => carrier.freq;
        <<< notes[noteIndex] >>>;
    }
    
    
    fun void setVolume(float factor) {
        carrier.gain() * factor => carrier.gain;
        factor > 1.0 ? "UP:" : "DOWN:" => string status;
        <<< "Oscillator gain", status, carrier.gain() >>>;
    }
    
    
    fun void setRamp(float factor) {
        Std.ftoi(factor * ramp) => ramp;
        ramp < 20 ? 20 : ramp > 15000 ? 15000 : ramp => ramp;
        ramp::ms => masterEnvelope.duration;
        
        factor > 1.0 ? "UP:" : "DOWN:" => string status;
        <<< "Oscillator envelope", status, ramp, "ms" >>>;
    }
    
    fun void setPanMode() {
        (panMode + 1) % 3 => panMode;
        
        string status;
        
        if (panMode == 0) {
            "CENTER" => status;
        }
        else if (panMode == 1) {
            "LEFT -> RIGHT" => status;
        }
        else if (panMode == 2) {
            "RANDOM" => status;
        }
        
        <<< "Oscillator panning set to", status >>>;
    }
}