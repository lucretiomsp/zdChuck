// Doemnico Cipriani 2025
// Utility class to parse Midi Input from Analog Heatx
// By default is receiving on channel 15
@import "zdMidiUtil.ck";

public class HeatFXInput {
0.0 => float cutoffValue; 
MidiIn heatMin;
heatMin.open(2) => int fxOpen;
    
ZdMidiMsg heatMsg;



// receive the MIDI
fun void receiveMIDI() {
  <<< "HeatFX receives MIDI" >>>;  
  while( true) {
   heatMin => now;
  while( heatMin.recv(heatMsg) ){
  //  <<< "MSG from Heat FX : " + heatMsg.data1 , heatMsg.data2 , heatMsg.data3 >>>;
    parseMIDI(heatMsg);
    }
  }
}

// parse the MIDI
fun void parseMIDI(ZdMidiMsg msg){
    if (msg.isCC()) {
       //  <<< "CAPITANO CC" + msg.data2 >>> ;
        
        // cutoff frequency
        if (msg.data2 == 22)
        { <<< cutoffValue >>>; Math.map(msg.data3, 0 , 127 , 0 , 3.14 ) => cutoffValue; } 
    }

}
// spork reception
spork ~receiveMIDI();
}
