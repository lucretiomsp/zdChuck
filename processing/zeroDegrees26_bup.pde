import oscP5.*;
import netP5.*;

// events from Pharo
float snareScale = 0;

ThunderIcon bolt;
float boltX = 0, boltY = -200, boltZ = 60;  // bolt position in the scene
float boltAngle = 0;                        // radians, rotates around Y
float boltScale = 1;
int showThunder = 0;
boolean strikeNow = false;

float blackholeSize = 0;                    // diameter of the black sphere
int backgroundColor = 0;
int redTxt = 0;
int spaceBetweeTbg = 20;
int shift = 0;

// Letter cylinder
float wallRadius = 170;
float wallSpin = 0.004;                     // constant slow spin (radians per frame)
float wallSpinKick = 0;                     // extra spin from backspace, decays
float wallRot = 0;
float wallTilt = 0.25;                      // tilt around X so the top is visible
char[] letters;
char blank = 'x';
int cols, rows;
int cursor = 0;

OscP5 oscP5;

void setup() {
  size(400, 900, P3D);                      // P3D enables 3D
  background(0);
  frameRate(30);                            // smoother spin than 9 fps

  bolt = new ThunderIcon(0, 0, 320, 550);   // built around (0,0)

  cols = 24;                                // letters around the cylinder
  rows = ceil(height / (float) spaceBetweeTbg);
  letters = new char[cols * rows];
  for (int i = 0; i < letters.length; i++) letters[i] = blank;

  oscP5 = new OscP5(this, 57120);

  oscP5.plug(this, "test", "/test");
  oscP5.plug(this, "backspace", "/backspace");
  oscP5.plug(this, "shift", "/shift");
  oscP5.plug(this, "strobo", "/strobo");
  oscP5.plug(this, "keyValue", "/keyValue");
  oscP5.plug(this, "thunder", "/thunder");
  oscP5.plug(this, "snareEvent", "/snareEvent");
}

void draw() {
  background(backgroundColor);
  translate(width / 2.0, height / 2.0, 0);  // origin at screen center, z toward viewer

  // spin: constant speed plus decaying kick from backspace
  wallRot += wallSpin + wallSpinKick;
  wallSpinKick *= 0.94;

  // black hole at the core of the cylinder
  noStroke();
  fill(0);
  sphereDetail(24);
  pushMatrix();
  sphere(blackholeSize / 2.0);
  popMatrix();

  // letter cylinder
  pushMatrix();
  rotateX(wallTilt);
  rotateY(wallRot);
  scale(1 + snareScale * 2);
  textSize(30);
  textAlign(CENTER, CENTER);
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      char ch = letters[r * cols + c];
      if (ch == 0) continue;
      float a = TWO_PI * c / cols;          // angle of this column around the cylinder
      pushMatrix();
      translate(wallRadius * sin(a), (r - rows / 2.0) * spaceBetweeTbg, wallRadius * cos(a));
      rotateY(a);                           // letter faces outward
      fill(redTxt - shift, shift, random(255));
      text(ch, 0, 0);
      popMatrix();
    }
  }
  popMatrix();

  // thunder is drawn last
  if (strikeNow) {
    bolt.strike();
    strikeNow = false;
  }
  if (showThunder == 1) {
    boltAngle = sin(frameCount * 0.05) * 0.6; // gentle sway in space
    pushMatrix();
    translate(boltX, boltY, boltZ);
    rotateY(boltAngle);
    scale(boltScale);
    bolt.display();
    popMatrix();
  }
}

// This method must be public, and the parameter types must match the OSC data types
public void test(float theA, float theB) {
  blackholeSize = theA;
  redTxt = int(theB);
}

public void strobo(float theA) {
  backgroundColor = int(theA);
}

// Every /keyValue writes the next cell. When the wall is full it wraps
// to the top left and overwrites the oldest letters.
public void keyValue(int theA) {
  if (theA == 8) {                                    // backspace: step back, put the x back
    cursor = (cursor - 1 + letters.length) % letters.length;
    letters[cursor] = blank;
    return;
  }
  if (theA == 10 || theA == 13) {                     // enter: jump to the next row
    cursor = ((cursor / cols + 1) * cols) % letters.length;
    return;
  }
  letters[cursor] = (theA == 0) ? '@' : (char) theA;  // 0 shows as '@' (64)
  cursor = (cursor + 1) % letters.length;
}

// Each /thunder 1 is one strike; the bolt stays visible until /thunder 0
public void thunder(int theA) {
  if (theA == 1) strikeNow = true;
  showThunder = theA;
}

// special keys
public void backspace(int theA) {
  wallSpinKick += 0.15;                     // spin the cylinder, then it slows back down
}

public void shift(int theA) {
  shift = (int) random(255);
}

public void snareEvent(float gate, float note) {
  snareScale = gate;
  println(gate);
}

// oscEvent still exists, but plug'd messages are marked as already processed
void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.isPlugged() == false) {
    println("Unhandled: " + theOscMessage.addrPattern());
    println("Unhandled: " + theOscMessage);
  }
}
