// import multiSampler
@import "ZeroSampler.ck";
@import "heatFXmin.ck";

//my 3dModels
GModel lighthouse(me.dir() + "3dModels/lighthouse.obj");
// GModel bird(me.dir() + "3dModels/12214_Bird_v1max_l3.obj");


MidiIn midiReceiver;
midiReceiver.open( 1 ) => int AmIOpen;
// the heat
HeatFXInput heat;


// the istruments
ZdSampler bass(3 , me.dir() + "samples/bass") => dac;
ZdSampler kick(1 , me.dir() + "samples/kick") => dac;
ZdSampler snare(2 , me.dir() + "samples/snare") => dac;
ZdSampler rim(4 , me.dir() + "samples/rim") => dac;
ZdSampler ch(5 , me.dir() + "samples/ch") => dac;
ZdSampler oh(6 , me.dir() + "samples/oh") => dac;
ZdSampler pad(7 , me.dir() + "samples/pad") => dac;
ZdSampler vox(9 , me.dir() + "samples/vox") => dac;
ZdSampler perc(10 , me.dir() + "samples/percs") => dac;

// the levels
0.5 => ch.gain;
0.7 => perc.gain;

// the envelopes
ADSR envK(1::ms , 180::ms , 0.3 , 190::ms) => blackhole;
ADSR envSn(1::ms , 120::ms , 0.0 , 180::ms) => blackhole;
ADSR envBass(70::ms , 120::ms , 0.6 , 1::ms) => blackhole;
ADSR envVox(20::ms , 300::ms , 0.8 , 311::ms) => blackhole;
//variables

// kick
0.2 => float torusX;
0.1 => float torusY;
0.0 => float torusRed;
0.0 => float torusColor;
0.0 => float torusSize;
0.0 => float torusRotY;

// snare
0.0 => float cubcol;
0.0 => float cubSize;

// bass
0.0 => float bassVel;

// vox
0.0 => float voxVel;

// pad
0.0 => float padVel;

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
}

// ############ midi note out on channel 3 (bass)
if (msg.data1 == 146) {
 //noteOn
  (msg.data3 / 127.0)  => bassVel;
  
  // <<< "ruota = " + torusRotY >>>;
  envBass.keyOn();

}

if (msg.data1 == 130) {
 //noteOff
  0 => bassVel;
  envBass.keyOff();
}


// ############ midi note out on channel 9 (vox)
if (msg.data1 == 152) {
 //noteOn
  //(msg.data3 / 127.0)  => voxVel;
  
  envVox.keyOn();

}

if (msg.data1 == 136) {
 //noteOff
 
  envVox.keyOff();
}


// ############ midi note out on channel 13 (pad)
if (msg.data1 == 156) {
   (msg.data3 / 100 ) => padVel;
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
  msg => oh.midiIn;
  msg => pad.midiIn;
  msg => vox.midiIn;
  msg => rim.midiIn;
  msg => perc.midiIn;

  }
  }
}

// the window
GWindow.title("Zero Degrees - ADC25 - Bristol");
GWindow.windowed(600 , 900);


// ###############################
// add to scene
lighthouse --> GG.scene();
GTorus torus -->   GG.scene(); 
// GCube cubeSn --> torus;

GCube cubeSn --> lighthouse;
GCube cubeSn2 --> GG.scene(); // always visible
GSuzanne susy --> GG.scene();


//####################################

torus.pos(@(0 , 0.0, 0.0));

cubeSn.pos(@(0.0 , 7.0, 0.0));

cubeSn2.rot(@(-0.3 , -0.35 , -0.2));
cubeSn2.color(@(1, 0 , 0));

lighthouse.sca(@(0.7, 0.7 , 0.7));
lighthouse.pos(@(1.8 , - 3.6 , 0));
// lighthouse.rotX(0.9);

susy.pos(@(-2 , 2, 0));
susy.color(@(0.0 , 0.0 , 1));
susy.rot(@(0.0 , 0.9 , -0.2));

GG.camera().orthographic();


fun void play() {}
spork ~ receiveMIDI();


while (true) {
    update();
    
    GG.nextFrame() => now;
    GG.scene().light().rot(@(-0.6 , 0.7 , heat.cutoffValue));
    GG.scene().light().intensity(3 - heat.cutoffValue);
    // GG.camera().rot(@(0 , 0,  heat.cutoffValue));
    // background
    // GG.scene().backgroundColor(@(0 , 0  , Math.random2f(0.1 , 0.98)));
    //camera

    // GG.camera().rot(@(-0.3, 0.1 , cameraZ));

    //torus
    torus.rotY(torusRotY);
    torus.rotX(heat.cutoffValue);
    // torus.rotY(torusY);
    
    0 + envK.value() * 1 => torusSize;
    envK.value() * 20 => torusRed;
    0 + envK.value() * 3 => torusColor;
    
    // torus is the kick
    torus.color(@(torusRed , torusColor , 0));
    
    torus.sca(@(torusSize , torusSize , torusSize));

    // cube is the snare
    envSn.value() =>  cubcol;
    envSn.value() * 0.7 => cubSize;
    cubeSn.rotZ(torusRotY);
    cubeSn.sca(@(cubSize , cubSize , cubSize));
    
    cubeSn.color(@(cubcol * 2 , 0 ,0 ));
    cubeSn.color(@(cubcol * 2 , 0 ,0 ));
    
    cubeSn2.sca(@(cubSize , cubSize , cubSize));
    cubeSn2.pos(@(-1.3 , - 0.7 ,   0));
    cubeSn2.rotZ(torusRotY);

    // lighthouse
    lighthouse.rotY(heat.cutoffValue / 2);
    lighthouse.sca(@(0.7, 0.7 * envBass.value() * Math.sgn(Math.fabs(bass.last()) ), 0.7));

    // susy is the voice
    

    susy.sca(@(envVox.value() , envVox.value()  , envVox.value() ));
    
     // draw UI
     /*
   if (UI.begin("ZD GUI")) {  // draw a UI window called "Tutorial"
      // scenegraph view of the current scene 
      UI.scenegraph(GG.scene()); 
   }

   
   UI.end(); // end of UI window, must match UI.begin(...)
   */
}