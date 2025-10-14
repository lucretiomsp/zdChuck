MidiIn midiReceiver;
midiReceiver.open(1) => int AmIOpen;
me.dir() + "samples/houseBass3.wav" => string filename;

[ me.dir() + "samples/houseBass3.wav", me.dir() + "samples/reeseBass5.wav" ,
me.dir() + "samples/subBass.wav" , me.dir() + "samples/synthPad172.wav"] @=> string files[];

// MY SAMPLER CLASS
public class Simone extends SndBuf {
[] @=> string files[];
60 => int note;
1 => int midiChannel;

fun Simone (int ch) { ch => midiChannel;}

// implememt how to change index!

fun void midiIn(MidiMsg msg) {
if (msg.data1 == (143 + midiChannel)) {
    Math.pow(2, (msg.data2 - 60) / 12.0) => rate;
    0 => pos;
}
}
// end of class declaration
}

// DECLARATIONS

Simone  buf(3) => dac;
files[0] => buf.read;
0 => buf.pos;
1 => float rate;
0.4 => buf.gain;

MidiMsg msg;

<<< "CIAO" >>>;

fun void parseMIDIInput(MidiMsg msg) {
    Math.pow(2, (msg.data2 - 60) / 12.0) => buf.rate;
    //files[2] => buf.read; 
    if (msg.data1 == 146) { 0 => buf.pos; }
}

fun void receiveMIDI() {
  while( true) {
   midiReceiver => now;
  while( midiReceiver.recv(msg) ){
  <<<msg.data1,msg.data2,msg.data3,"MIDI Message">>>;
   msg => buf.midiIn;
   //parseMIDIInput(msg);
  }
  }
}

spork ~receiveMIDI();

while(1) {

    // 0 => buf.pos;
    // 1 => buf.rate;
    //advance time
    
    1200::ms => now;
}