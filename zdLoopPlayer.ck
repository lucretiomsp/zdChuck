// Domenico Cipriani @ 2025 
@import "stringSortFunc.ck";

public class ZdLoopPlayer extends Chugraph {
    ADSR env;
    SndBuf smplPl => env =>  outlet;
    env.set(1::ms , 380::ms , 1 , 120::ms);
    0.4 => smplPl.gain;
    1 => smplPl.rate;
    0 => int numSamples;
    0 => int sampleIndex;

string files[3];
string filePrefix;
60 => int note;
1 => int midiChannel;
120.0 => float performanceBpm;
float rates[4];
float originalBpms[];

fun SndBuf getSmplPl() {
    return smplPl;
}

fun int getSampleIndex() {

    return sampleIndex;
}
fun ZdLoopPlayer (int ch , string fileDir , float oBpm []) { 
    ch => midiChannel;
    fileDir + "/" => filePrefix ;
    FileIO dir;
    dir.open(fileDir, FileIO.READ);
    AlphaBetaSort.sort(dir.dirList()) @=> files;
    filePrefix + files[0] => smplPl.read; 
    0 => smplPl.pos;
    // <<< dir.dirList()[1] >>>;
    dir.dirList().size() => numSamples;
    <<< "ZdLoopPlayer num of samples : " ,  dir.dirList().size() >>>;
    <<< "File name : " , filePrefix + files[0] >>>;
    oBpm @=> originalBpms;
}

// implememt how to change index!
fun void setRates(float actualBpm)
{
   for (0 => int i; i < originalBpms.size() ; i ++)
   {
    performanceBpm / originalBpms[i] => rates[i];
    rates[sampleIndex] => smplPl.rate;
   }
}

fun void midiIn(MidiMsg msg) {
if (msg.data1 == (143 + midiChannel)) {
    1 => smplPl.rate;
    0 => smplPl.pos;
    env.keyOn();
    
}
// noteOFF must be implemented
if (msg.data1 == (127 + midiChannel)) {
env.keyOff();

}
/// cc19 changes index
if (msg.data1 == 175 + midiChannel && msg.data2 == 19) {
    filePrefix + files[msg.data3 % numSamples] => smplPl.read;
    msg.data3 => sampleIndex;
   // <<< files[msg.data3 % 3 ]  >>>;  
}
}
// end of class declaration
}
