public class GrainObject {
    Dyno safety;
    
    Gain master;
    0.9 => master.gain;
    
    Envelope envelope;
    3000::ms => envelope.duration;
    0 => int isOn;
    
    LiSa lisa[3];
    10 => int maxVoices;
    
    500.0 => float bufferLength;
    0 => int recordIndex;
    2 => int playIndex;
    
    for (0 => int i; i < 3; i++) {
        lisa[i].duration(bufferLength::ms);
        lisa[i].maxVoices(40);
        lisa[i].clear();
        lisa[i].gain(0.410);
        lisa[i].feedback(0);
        lisa[i].recRamp(10::ms);
        lisa[i].record(0);
        
        adc => lisa[i] => envelope => master;
    }
    
    fun void initialize(int pan) {
        if (pan < 0) {
            master => dac.left;
        }
        else if (pan > 0) {
            master => dac.right;
        }
        else {
            master => dac;
        }
    }
    
    fun void toggleOn() {
        1 ^=> isOn;
        isOn == 1 ? "ON" : "OFF" => string status;
        <<< "Grains:", status >>>;
        
        if (isOn) {
            envelope.keyOn();
        }
        else {
            envelope.keyOff();
        }
        
        envelope.duration() => now;
    }
    
    
    lisa[recordIndex].record(1);
    
    1.125 * 2 => float ninth;
    
    [1.0, 1.0, 1.0, 1.0, 1.0, 1.4, ninth] @=> float rates[];
    
    
    100 => float maxGrain;
    maxGrain / 2.0 => float minGrain;
    
    1.0 => float grainInterval;
    
    // create grains, rotate record and play buffers
    // shouldn't click as long as the grainLength < bufferLength
    fun void play() {
        while (true) {
            now + bufferLength::ms => time later;
            
            while (now < later) {
                rates[Math.random2(0, rates.size()-1)] => float newRate;
                Math.randomf() > 0.5 ? newRate : newRate * -1 => newRate;
                
                newRate > 1 ? maxGrain::ms : Math.random2f(minGrain, maxGrain)::ms => dur newDuration;
                
                minGrain * 0.1 => float ramp;
                spork ~ getGrain(playIndex, newDuration, ramp::ms, ramp::ms, newRate);
                
                grainInterval::ms => now;
            }
            
            // Rotate the record/play indexes
            lisa[recordIndex].record(0);
            
            (recordIndex + 1) % 3 => recordIndex;
            setNextRecorder();
            lisa[recordIndex].record(1);
            
            (playIndex + 1) % 3 => playIndex;
        }
    }
        
    fun void getGrain(int current, dur grainLength, dur rampUp, dur rampDown, float rate) {
        lisa[current].getVoice() => int voice;
        
        if (voice > -1 && voice < maxVoices) {
            lisa[current].rate(voice, rate);
            
            //lisa[current].gain() * Math.random2f(0.8, 1.2) => float voiceGain;
            //lisa[current].voiceGain(voice, voiceGain);
            
            
            rate < 1.0 ? 0.0 : Math.randomf() => float positionFactor;
            
            lisa[current].playPos(voice, positionFactor * bufferLength::ms);
            
            lisa[current].rampUp(voice, rampUp);
            (grainLength - (rampUp + rampDown)) => now;
            
            lisa[current].rampDown(voice, rampDown);
            rampDown => now;
        }
    }
    
    fun void setNextRecorder() {
        lisa[recordIndex].duration(bufferLength::ms);
    }
    
    fun void setMaxVoices(int factor) {
        factor +=> maxVoices;
        
        if (maxVoices < 0) {
            0 => maxVoices;
        }
        if (maxVoices > 40) {
            40 => maxVoices;
        }
        
        <<< "Max voices:", maxVoices * 3 >>>;
    }
    
    fun void setGain(float factor) {
        master.gain() * factor => master.gain;
        <<< "Set gain:", Std.ftoa(master.gain(), 2) >>>;
    }
    
    fun void setBufferLength(float factor) {
        factor *=> bufferLength;
        <<< "Buffer length:", bufferLength >>>;
    }
    
    fun void setGrainLength(float factor) {
        factor *=> maxGrain;
        maxGrain / 2.0 => minGrain;
        <<< "Grain length:", minGrain, "-", maxGrain >>>;
    }
    
    fun void setGrainInterval(float factor) {
        factor *=> grainInterval;
        <<< "Grain interval:", grainInterval >>>;
    }
    
    fun void printStatus() {
        isOn == 1 ? "ON" : "OFF" => string status;
        <<< "Grains:", status, " Gain:", Std.ftoa(master.gain(), 2), " Voices:", maxVoices * 3, " Buffer:", Std.ftoa(bufferLength, 0), "ms", " Size:", Std.ftoa(minGrain, 0) + "-" + Std.ftoa(maxGrain, 0), " Interval:", Std.ftoa(grainInterval, 1),  "ms" >>>;
    }
}
