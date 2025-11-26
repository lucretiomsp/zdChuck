// Domenico Cipriani @ 2025 

// to use the ZdLoopPlayer your audiofiles must be named terminating with |(pipe)<bpm> as in
// myBassLoop|128.wav

@import "stringSortFunc.ck";

public class ZdLoopPlayer extends Chugraph {
    ADSR env;
    SndBuf smplPl => env =>  outlet;
    env.set(1::ms , 380::ms , 1 , 120::ms);
    0.4 => smplPl.gain;
    1 => smplPl.rate;
    0 => int numSamples;
    0 => int sampleIndex;

string files[9];
string filePrefix;
60 => int note;
1 => int midiChannel;
170.0 => float performanceBpm;
float rates[9];
float originalBpms[9];

// #######

fun float getBpmFromFileName(string fileName)
{
  fileName.find("|") => int pipePosition;
  fileName.substring(pipePosition + 1).toFloat() => float bpm;

  return bpm; 
}

fun void fillOriginalBpms (string files [])
{
  for ( 0=> int i; i < files.size() ; i++) 
  {
    originalBpms.size(files.size());
    getBpmFromFileName(filePrefix + files[i]) => originalBpms[i];
    <<< files[i] , " original bpm :" , originalBpms[i] >>>;
  }
}
// ####

fun SndBuf getSmplPl() {
    return smplPl;
}

fun int getSampleIndex() {

    return sampleIndex;
}

// CONSTRUCTOR ##########################################################################################

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
    // <<< "File name : " , filePrefix + files[0] >>>;
    <<< "BPM of first sample : " , getBpmFromFileName( (filePrefix + files[0])) >>>;
    oBpm @=> originalBpms;
    
    fillOriginalBpms(files);
    rates.size(originalBpms.size());
}

// ###################################################################################################

// implememt how to change index!
fun void setRates(float actualBpm)
{
   
   for (0 => int i; i < originalBpms.size() ; i ++)
   {
    // <<< "original BPMS : " , originalBpms[i] >>>;
    actualBpm => performanceBpm;
    performanceBpm / originalBpms[i] => rates[i];
    <<< "new rates" , rates[i] >>>;
   }
    rates[sampleIndex] => smplPl.rate;
}

fun void midiIn(MidiMsg msg) {
if (msg.data1 == (143 + midiChannel)) {
     rates[sampleIndex] => smplPl.rate;
    // 1 => smplPl.rate;
    // <<< "LOOPER RATE : " , smplPl.rate() >>> ;
    // <<< "SAMPLE INDEX: " , sampleIndex >>>;
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
