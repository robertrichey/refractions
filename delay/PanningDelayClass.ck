public class PanningDelay {
    Gain master;
    1.0 => master.gain;
    
    PitShift shifter;
    1.0 => shifter.mix;
    
    Dyno safety;
    
    Envelope masterEnvelope;
    Envelope dryEnvelope;
    Envelope wetEnvelope;
    
    Delay delay[];
    500 => int delayInterval;
    0.7 => float delayGain;
    
    Pan2 panning[];
    
    0 => int masterIsOn;
    0 => int wetIsOn;
    string name;
    
    
    fun void initialize(string name, int voiceCount, float interval) {
        name => this.name;
        
        voiceCount * 2 - 2 => int lineCount;
        
        initializeDelay(lineCount) @=> delay;
        initializePan(lineCount) @=> panning;
        
        interval => shifter.shift;
        
        2000::ms => masterEnvelope.duration => dryEnvelope.duration => wetEnvelope.duration;
        dryEnvelope.keyOn();
        
        0 => int index;
         
        for (0 => int i; i < voiceCount-1; i++) {
            Std.scalef(i+1, 1, voiceCount, -1, 1) => panning[index].pan;
            index++;
        }
        for (0 => int i; i < voiceCount-1; i++) {
            Std.scalef(i+1, 1, voiceCount, 1, -1) => panning[index].pan;
            index++;
        }
        for (0 => int i; i < lineCount; i++) {    
            delay[i] => panning[i] => dac;
            
            delayInterval::ms => delay[i].max => delay[i].delay;
            delayGain => delay[i].gain;
            
            if (i == lineCount-1) {
                delay[i] => delay[0];
            }
            else {
                delay[i] => delay[i+1];
            }
        }
        
        adc => master;
        master => dryEnvelope => safety;
        master => shifter => wetEnvelope => safety;
        safety => masterEnvelope => delay[delay.size() / 2];
    }
    
    fun Delay[] initializeDelay(int n) {
        return Delay array[n];
    }
    
    fun Pan2[] initializePan(int n) {
        return Pan2 array[n];
    }
    
    fun void setDelayInterval(float factor) {
        if (!masterIsOn) {
            Std.ftoi(delayInterval * factor) => delayInterval;
            delayInterval < 20 ? 20 : delayInterval => delayInterval;
            <<< "Delay Interval: ", delayInterval, "ms" >>>;
            
            for (0 => int i; i < delay.size(); i++) {                
                delayInterval::ms => delay[i].max => delay[i].delay;
            }
        }
        else {
            <<< "Turn MASTER off before adjusting delay", "" >>>;
        }
    }
    
    fun void setDelayGain(float factor) {
        factor *=> delayGain;
        delayGain > 0.99 ? 0.99 : delayGain => delayGain;
        <<< "Delay Gain:", Std.ftoa(delayGain, 2) >>>;
        
        for (0 => int i; i < delay.size(); i++) {
            delayGain => delay[i].gain;
        }
    }
    
    fun void turnOn() {
        1 ^=> masterIsOn;
        
        if (masterIsOn) {
            masterEnvelope.keyOn();
            <<< "Master: ON", "" >>>;
        }
        else {
            masterEnvelope.keyOff();
            <<< "Master: OFF", "" >>>;
        }
    }
    
    fun void pitchShift() {
        1 ^=> wetIsOn;
        
        if (wetIsOn) {
            wetEnvelope.keyOn();
            dryEnvelope.keyOff();
            <<< "Transpose: ON", "" >>>;
        }
        else {
            wetEnvelope.keyOff();
            dryEnvelope.keyOn();
            <<< "Transpose: OFF", "" >>>;
        }
    }
    
    fun void printStatus() {
        masterIsOn ? "ON" : "OFF" => string masterStatus;
        wetIsOn ? "ON" : "OFF" => string transposeStatus;
        <<< name + ":", masterStatus, "Transpose:", transposeStatus, "Gain:", Std.ftoa(delayGain, 2), "Delay:", delayInterval, "ms" >>>;
    }
}