public class LisaObject {
    LiSa lisa[2];
    NRev reverb;
    Envelope envelope;
    Gain master;
    Dyno safety;
    Pan2 panning;
    0 => int isOn;
    0 => int isBidirectional;
    float rate;
    string name;
    
    [-0.5, 0, 0.5] @=> float panValues[];
    0 => int panCounter;
    3000::ms => envelope.duration;
    0.2 => master.gain;
    
    0.1 => reverb.mix;
    
    for (0 => int i; i < lisa.size(); i++) {
        // allocate memory
        10::second => lisa[i].duration;  
        
        0.35 => lisa[i].gain;
        
        lisa[i].recRamp(50::ms);
        
        adc => lisa[i] => reverb => master => envelope => safety => panning => dac;
    }
    
    fun void initialize(float rate, int count, string name) {
        count => int panCounter;
        panValues[panCounter] => panning.pan;
        -1.0 => lisa[0].rate;
        rate => this.rate => lisa[1].rate;
        name => this.name;
    }
    
    fun void record() {
        <<< name, ":", "RECORDING..." >>>;
        for (0 => int i; i < lisa.size(); i++) {
            lisa[i].record(1);
        }
        
        lisa[0].duration() => now;
        
        for (0 => int i; i < lisa.size(); i++) {
            lisa[i].record(0);
            lisa[i].loop(1);
            lisa[i].play(1);
        }
        <<< name, ":", "PLAYING" >>>;
    }
    
    fun void toggleOn() {
        1 ^=> isOn;
        isOn == 1 ? "ON" : "OFF" => string status;
        <<< name, ":", status >>>;
        
        if (isOn) {
            envelope.keyOn();
            
            for (0 => int i; i < lisa.size(); i++) {
                lisa[i].play(1);
                lisa[i].loop(1);
            }
        }
        else {
            envelope.keyOff();
        }
    }
    
    fun void loopMode() {
        1 ^=> isBidirectional;
        isBidirectional == 1 ? "BIDIRECTIONAL" : "STANDARD" => string status;
        <<< name, "looping:", status >>>;
        
        if (isBidirectional) {            
            for (0 => int i; i < lisa.size(); i++) {
                lisa[i].bi(1);
            }
        }
        else {
            for (0 => int i; i < lisa.size(); i++) {
                -1.0 => lisa[0].rate;
                rate => lisa[1].rate;
            }
        }
    }
    
    fun void clear() {
        for (0 => int i; i < lisa.size(); i++) {
            lisa[i].clear;
        }
    }
    
    fun void setVolume(float factor) {
        for (0 => int i; i < lisa.size(); i++) {
            lisa[i].gain() * factor => lisa[i].gain;
            factor > 1.0 ? "UP:" : "DOWN:" => string status;
            <<< "LiSa gain", status, Std.ftoa(lisa[i].gain(), 2) >>>;
        }
    }
    
    fun void setPan(int value) {
        if (value > 0) {
            panCounter++;
            panCounter > panValues.size()-1 ? 0 : panCounter => panCounter;
        }
        else {
            panCounter--;
            panCounter < 0 ? panValues.size()-1 : panCounter => panCounter;
        }
        panValues[panCounter] => panning.pan;
    }
    
    fun void printStatus() {
        isOn == 1 ? "ON" : "OFF" => string status;
        isBidirectional == 1 ? "BIDIRECTIONAL" : "STANDARD" => string loopMode;
        <<< name + ":", status, "Gain:", Std.ftoa(lisa[0].gain(), 2), "Loop:", loopMode >>>;
    }
}
