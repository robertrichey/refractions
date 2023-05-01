public class DistortionObject {    
    Envelope envelope;
    Dyno safety;
    Gain gain;
    
    adc => envelope;
    envelope => FoldbackSaturator folder => gain => safety => Pan2 foldPan => dac;
    envelope => ABSaturator abs => gain => safety => Pan2 absPan => dac;
    
    0.5 => foldPan.pan; 
    -0.5 => absPan.pan; 
    
    0.25 => gain.gain;
    
    70 => abs.drive;
    4 => abs.dcOffset;
    0.1 => abs.gain;
    
    0.007 => folder.threshold;
    0.1 => folder.gain;
    
    0 => int isOn;
    
    fun void toggleOn() {
        1 ^=> isOn;
        isOn == 1 ? "ON" : "OFF" => string status;
        <<< "Distortion:", status >>>;
        
        if (isOn) {
            60000::ms => envelope.duration;
            envelope.keyOn();
        }
        else {
            200::ms => envelope.duration;
            envelope.keyOff();
        }
        
        envelope.duration() => now;
    }
}