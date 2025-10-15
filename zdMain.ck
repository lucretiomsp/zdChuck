// import multiSampler
@import "ZeroSampler.ck";

MidiIn midiReceiver;
midiReceiver.open( 1 ) => int AmIOpen;

// !!!!! WE NEED A SECOND RECEIVER FOR THE HEATFX

// the samnstruments
ZdSampler bass(3 , me.dir() + "samples/bass") => dac;
ZdSampler kick(1 , me.dir() + "samples/kick") => dac;
ZdSampler snare(2 , me.dir() + "samples/snare") => dac;
ZdSampler ch(5 , me.dir() + "samples/ch") => dac;
//variables
0.2 => float cubeX;
0.1 => float cubeY;
0.0 => float cubeRed;
0.0 => float cubeColor;
0.0 => float cubeSize;

0.0 => float cameraZ;

0.0 => float bgColor;

if ( !AmIOpen ) { me.exit(); }

fun update() {
  //  GG.scene().backgroundColor(Color.BLACK);
  bgColor *  Math.random2f(0.1 , 0.98) => float  bgRand;
  GG.scene().backgroundColor(@(bgRand , bgRand  , bgRand));
}



// the MIDI message & the MIDI function
MidiMsg msg;

fun void parseMIDI(MidiMsg msg) {
  // global delay time

if (msg.data1 == 184 && msg.data2 == 21) {
  (msg.data3  - 64 )/ 2.0 => cubeX;
  (msg.data3 - 63) / 127.0 => cameraZ;
  
}

// midi note out on channel 1 (kick)
if (msg.data1 == 144) {
  // when noteOn 
  ((msg.data2) - 50) / 2.0  => cubeY;
  ((msg.data2) - 50) / 2.0  => cubeColor;
  (msg.data3 )   / 130.0  => cubeSize;
}

if (msg.data1 == 128) {
  // when noteOff
  0.0 => cubeY;
  0.0  => cubeColor;
  0.0  => cubeSize;
}

// midi note out on channel 2 (snare)
if (msg.data1 == 145) {
 //noteOn
  (msg.data3)  => cubeRed;
}

if (msg.data1 == 129) {
 //noteOff
  0 => cubeRed;
}
// midi note out on channel 13 (pad)
if (msg.data1 == 156) {
 
  (msg.data3) / 100 => bgColor;
}
}


fun void receiveMIDI() {
  while( true) {
   midiReceiver => now;
  while( midiReceiver.recv(msg) ){
  <<<msg.data1,msg.data2,msg.data3,"MIDI Message">>>;
  //  <<< "bgColor" , bgColor >>>;
    parseMIDI(msg);
  // play instruments 
  msg => bass.midiIn;
  msg => kick.midiIn;
  msg => snare.midiIn;
  msg => ch.midiIn;

  }
  }
}

// add to scene

GSuzanne cube --> GG.scene(); 
GG.camera().perspective();
vec3 v;
v.set(0.0, 0.0 , 0.0);

fun void play() {}
spork ~ receiveMIDI();


while (true) {
    update();
    GG.nextFrame() => now;

    // background
    // GG.scene().backgroundColor(@(0 , 0  , Math.random2f(0.1 , 0.98)));
    //camera
    GG.camera().rot(@(-0.3, 0.1 , cameraZ));

    //cube
    // cube.rotX(cubeX);
    // cube.rotY(cubeY);
    cube.color(@(cubeRed , cubeColor , 0));
    cube.pos(@(-1.8 , 0, -0.2));
    cube.sca(@(cubeSize , cubeSize , cubeSize));
   
}