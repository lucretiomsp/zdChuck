// import multiSampler
@import "ZeroSampler.ck";
@import "heatFXmin.ck";

//my 3dModels
GModel lighthouse(me.dir() + "3dModels/lighthouse.obj");



MidiIn midiReceiver;
midiReceiver.open( 1 ) => int AmIOpen;

HeatFXInput heat;


// the istruments
ZdSampler bass(3 , me.dir() + "samples/bass") => dac;
ZdSampler kick(1 , me.dir() + "samples/kick") => dac;
ZdSampler snare(2 , me.dir() + "samples/snare") => dac;
ZdSampler perc(4 , me.dir() + "samples/percs") => dac;
ZdSampler ch(5 , me.dir() + "samples/ch") => dac;

// the envelopes
ADSR envK(1::ms , 180::ms , 0.3 , 190::ms) => blackhole;
ADSR envSn(1::ms , 120::ms , 0.0 , 180::ms) => blackhole;
//variables

0.2 => float torusX;
0.1 => float torusY;
0.0 => float torusRed;
0.0 => float torusColor;
0.0 => float torusSize;
0.0 => float torusRotY;

// cube
0.0 => float cubcol;
0.0 => float cubSize;


// camera
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
  (msg.data3  - 64 )/ 2.0 => torusX;
  (msg.data3 - 63) / 127.0 => cameraZ;
  
}

//  ############ midi note out on channel 1 (kick)
if (msg.data1 == 144) {
  // when noteOn 
  ((msg.data2) - 50) / 2.0  => torusY;
  ((msg.data2) - 50) / 2.0  => torusColor;
  (msg.data3 )   / 130.0  => torusSize;
  envK.keyOn();
}

if (msg.data1 == 128) {
  // when noteOff
  /*
  0.0 => torusY;
  0.0  => torusColor;
  0.0  => torusSize;
  */
  envK.keyOff();
}

// ############ midi note out on channel 2 (snare)
if (msg.data1 == 145) {
 //noteOn
  //(msg.data3)  => torusRed;
  0.09 + torusRotY => torusRotY;
  // <<< "ruota = " + torusRotY >>>;
  envSn.keyOn();

}

if (msg.data1 == 129) {
 //noteOff
  0 => torusRed;
  envSn.keyOff();
  <<< "cane" >>> ;
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
   //  <<<msg.data1,msg.data2,msg.data3,"MIDI Message">>>;
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

// the window
GWindow.title("Zero Degrees - ADC25 - Bristol");
GWindow.windowed(600 , 900);

// add to scene
lighthouse --> GG.scene();
GTorus torus --> GG.scene(); 
// GCube cubeSn --> torus;
GCube cubeSn --> GG.scene();


lighthouse.sca(@(0.7, 0.7 , 0.7));
lighthouse.pos(@(1.8 , - 3.6 , 0));
lighthouse.rotX(0.9);
 
GG.camera().orthographic();
GG.scene().light().rot(@(-0.6 , 0.7 , 0.4));
GG.scene().light().intensity(4);
fun void play() {}
spork ~ receiveMIDI();


while (true) {
    update();
    
    GG.nextFrame() => now;

    // background
    // GG.scene().backgroundColor(@(0 , 0  , Math.random2f(0.1 , 0.98)));
    //camera

    // GG.camera().rot(@(-0.3, 0.1 , cameraZ));

    //torus
    torus.rotY(torusRotY);
    // torus.rotY(torusY);
    
    1 + envK.value() * 1 => torusSize;
    envK.value() * 20 => torusRed;
    1 + envK.value() * 3 => torusColor;
    
    // torus is the kick
    torus.color(@(torusRed , torusColor , 0));
    torus.pos(@(-0.15 , 0.0, 0.0));
    torus.sca(@(torusSize , torusSize , torusSize));

    // cube is the snare
    envSn.value() =>  cubcol;
    envSn.value() * 0.7 => cubSize;
    cubeSn.rotZ(torusRotY);
    cubeSn.sca(@(cubSize , cubSize , cubSize));
    cubeSn.pos(@(0.0 , 0.0, 0.0));
    cubeSn.color(@(0 , cubcol ,0 ));
    
   
     // draw UI
   if (UI.begin("ZD GUI")) {  // draw a UI window called "Tutorial"
      // scenegraph view of the current scene
      UI.scenegraph(GG.scene()); 
   }

   
   UI.end(); // end of UI window, must match UI.begin(...)
   
}