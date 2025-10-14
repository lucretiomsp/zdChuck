MidiIn midiReceiver;
midiReceiver.open(1) => int AmIOpen;
me.dir() + "samples/houseBass3.wav" => string filename;

[ me.dir() + "samples/houseBass3.wav", me.dir() + "samples/reeseBass5.wav" ,
me.dir() + "samples/subBass.wav" , me.dir() + "samples/synthPad172.wav"] @=> string files[];

// MY SAMPLER CLASS
public class Simone extends Chugraph {
    ADSR env;
    SndBuf smplPl => env outlet;
    env.set(3::ms , 180::ms , 1 , 120::ms);
    0.4 => smplPl.gain;
    1 => smplPl.rate;

string files[3];
string filePrefix;
60 => int note;
1 => int midiChannel;

fun SndBuf getSmplPl() {
    return smplPl;
}
fun Simone (int ch , string fileDir) { 
    ch => midiChannel;
    fileDir + "/" => filePrefix ;
    FileIO dir;
    dir.open(fileDir, FileIO.READ);
    dir.dirList() @=> files;
    filePrefix + files[0] => smplPl.read; 
    0 => smplPl.pos;
    // <<< dir.dirList()[1] >>>;
    <<< dir.dirList().size() >>>;
    <<< filePrefix + files[0] >>>;
}

// implememt how to change index!

fun void midiIn(MidiMsg msg) {
if (msg.data1 == (143 + midiChannel)) {
    Math.pow(2, (msg.data2 - 60) / 12.0) => smplPl.rate;
    0 => smplPl.pos;
    env.keyOn();
    <<<"CANE">>>;
}
// noteOFF must be implemented
if (msg.data1 == (127 + midiChannel)) {
env.keyOff();

}
/// cc20 changes index
if (msg.data1 == (175 + midiChannel && msg.data2 == 20)) {
    filePrefix + files[msg.data3 % 3] => smplPl.read;
    
   //  <<< files[msg.data3 % 3 ]  >>>;  
}
}
// end of class declaration
}

// DECLARATIONS

Simone  buf(3 , me.dir() + "samples/bass") => dac;
// files[0] => smplPl.read;
// 0 => buf.pos;
// 1 => float rate;


MidiMsg msg;

<<< "CIAO" >>>;

/*
fun void parseMIDIInput(MidiMsg msg) {
    Math.pow(2, (msg.data2 - 60) / 12.0) => buf.rate;
    //files[2] => buf.read; 
    if (msg.data1 == 146) { 0 => buf.pos; }
}
*/
fun void receiveMIDI() {
  while( true) {
   midiReceiver => now;
  while( midiReceiver.recv(msg) ){
 // <<<msg.data1,msg.data2,msg.data3,"MIDI Message">>>;
   msg => buf.midiIn;
   //parseMIDIInput(msg);
  }
  }
}

spork ~receiveMIDI();

while(1) {

    // 0 => buf.getSmplPl().pos;
    // 1 => buf.getSmplPl().rate;
    //advance time
    
    1200::ms => now;
}