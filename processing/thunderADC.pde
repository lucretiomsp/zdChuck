// ============================================================
//  ThunderIcon (Processing 4)
//  Lightning bolt icon with a luminous yellow glow, arcs, sparks.
//  Drop this file into your sketch folder as a tab.
//
//  ThunderIcon bolt;
//  void setup() {
//    size(720, 720, P2D);                      // P2D: the glow is GPU work
//    bolt = new ThunderIcon(width / 2, height / 2, 230, 380);  // after size()
//  }
//  void draw() {
//    background(8);                            // looks best on dark
//    bolt.setCharge(bolt.near(mouseX, mouseY) ? 1 : 0);   // optional hover
//    bolt.display();
//  }
//  void mousePressed() { bolt.strike(); }
// ============================================================

class ThunderIcon {
  float x, y, w, h;                         // center + size

  // Look. Change these, then call rebuild().
  color glowHot    = color(255, 250, 210);  // innermost rim
  color glowCol    = color(255, 214, 24);   // the yellow lumi
  color glowFar    = color(255, 166, 0);    // wide warm haze
  float glowSize   = 1.0;                   // scales every blur radius
  color bodyTop    = color(255, 234, 64);
  color bodyBottom = color(255, 194, 0);
  color bodyEdge   = color(255, 166, 0);
  color bodyCore   = color(255, 253, 232);

  // Bloom layers: blur radius (in bolt heights) and strength
  float[] layerSigma    = { 0.006, 0.02, 0.05, 0.11, 0.24 };
  float[] layerStrength = { 0.9,   1.0,  1.1,  1.15, 1.3  };

  // Behaviour
  boolean glowOn = true, arcsOn = true, sparksOn = true;
  boolean autoStrike = false;               // strike by itself every few seconds
  boolean washScene = true;                 // a strike briefly lights the whole canvas
  float glowSpeed = 0.045;                  // breathing speed

  // Outline in a -1..1 box (y points down)
  float[][] shape = {
    {  0.17, -1.00 }, {  1.00, -1.00 }, {  0.38, -0.20 }, {  0.92, -0.20 },
    { -0.50,  1.00 }, { -0.21,  0.20 }, { -1.00,  0.20 }
  };

  // Internals
  float[] vx, vy, edgeLen;
  float perimeter;
  int tip;                                  // lowest vertex, sparks fall from here
  PImage nearImg, farImg, bodyImg, coreImg;
  float[] nearRect = new float[4];          // x, y, w, h of each baked image
  float[] farRect  = new float[4];
  float[] bodyRect = new float[4];
  float level, coreLevel, pulse, charge, chargeTarget, flash;
  int dropout, nextStrike;
  ArrayList<Arc> arcs = new ArrayList<Arc>();
  ArrayList<Spark> sparks = new ArrayList<Spark>();
  ArrayList<Ring> rings = new ArrayList<Ring>();

  ThunderIcon(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    rebuild();
  }

  // ---- public API -------------------------------------------

  void setGlow(boolean state) { glowOn = state; }
  void toggleGlow()           { glowOn = !glowOn; }
  void setCharge(float c)     { chargeTarget = constrain(c, 0, 1); }

  boolean near(float px, float py) {
    return signedDist(px, py) < 0.08 * h;
  }

  void strike() {
    flash = 1;
    rings.add(new Ring(x, y, h));
    if (arcsOn) for (int i = 0; i < 4; i++) arcs.add(spawnArc(true));
    if (sparksOn) emitSparks(36, true);
  }

  void moveTo(float nx, float ny) {         // cheap: no re-bake
    float dx = nx - x, dy = ny - y;
    for (int i = 0; i < vx.length; i++) { vx[i] += dx; vy[i] += dy; }
    for (float[] r : new float[][] { nearRect, farRect, bodyRect }) { r[0] += dx; r[1] += dy; }
    x = nx; y = ny;
  }

  // ---- per frame --------------------------------------------

  void update() {
    float t = frameCount;
    pulse = 0.5 + 0.5 * sin(t * glowSpeed);
    charge = lerp(charge, chargeTarget, 0.07);
    flash *= 0.9;

    if (dropout > 0) dropout--;
    else if (random(1) < 0.004) dropout = (int) random(2, 5);   // neon hiccup
    float drop = dropout > 0 ? 0.6 : 1;
    float flicker = (noise(t * 0.12, 11) - 0.5) * 0.25;

    level     = (0.72 + 0.2 * pulse + flicker + 0.35 * charge) * drop + 1.2 * flash;
    coreLevel = (0.45 + 0.35 * noise(t * 0.3, 42) + 0.3 * charge) * drop + flash;

    if (arcsOn && random(1) < 0.05 + 0.4 * charge) arcs.add(spawnArc(false));
    if (sparksOn && random(1) < 0.2 + 0.6 * charge) emitSparks(1, false);

    if (autoStrike && frameCount >= nextStrike) {
      if (nextStrike > 0) strike();
      nextStrike = frameCount + (int) random(180, 420);
    }

    for (int i = arcs.size() - 1; i >= 0; i--)   if (!arcs.get(i).update())   arcs.remove(i);
    for (int i = sparks.size() - 1; i >= 0; i--) if (!sparks.get(i).update()) sparks.remove(i);
    for (int i = rings.size() - 1; i >= 0; i--)  if (!rings.get(i).update())  rings.remove(i);
  }

  void display() {
    update();
    // Light adds up on the GPU. JAVA2D's ADD is very slow, so it falls back to BLEND,
    // which looks almost the same on a dark background.
    int light = g.isGL() ? ADD : BLEND;
    pushStyle();
    imageMode(CORNER);
    ellipseMode(CENTER);
    blendMode(light);

    // 0) a quick wash of light over the whole scene on a strike
    if (washScene && flash > 0.01) {
      noStroke();
      fill(255, 205, 90, 30 * flash * flash);
      rect(0, 0, width, height);
    }

    // 1) yellow lumi: wide haze breathes, the rim follows the core flicker
    if (glowOn) {
      layer(farImg, farRect, level);
      layer(nearImg, nearRect, 0.6 + 0.4 * coreLevel);
      if (level > 1) layer(farImg, farRect, level - 1);         // overdrive on strikes
    }
    for (Ring r : rings) r.draw();

    // 2) solid bolt
    blendMode(BLEND);
    layer(bodyImg, bodyRect, 1);

    // 3) white-hot core, flickering
    blendMode(light);
    layer(coreImg, bodyRect, coreLevel);

    // 4) electricity
    for (Arc a : arcs) a.draw();
    for (Spark sp : sparks) sp.draw();

    noTint();
    blendMode(BLEND);
    popStyle();
  }

  void layer(PImage img, float[] r, float alpha) {
    tint(255, 255 * constrain(alpha, 0, 1));
    image(img, r[0], r[1], r[2], r[3]);
  }

  // ---- baking -----------------------------------------------

  void rebuild() {
    int n = shape.length;
    vx = new float[n];
    vy = new float[n];
    edgeLen = new float[n];
    perimeter = 0;
    tip = 0;
    for (int i = 0; i < n; i++) {
      vx[i] = x + shape[i][0] * w * 0.5;
      vy[i] = y + shape[i][1] * h * 0.5;
      if (vy[i] > vy[tip]) tip = i;
    }
    for (int i = 0; i < n; i++) {
      int j = (i + 1) % n;
      edgeLen[i] = dist(vx[i], vy[i], vx[j], vy[j]);
      perimeter += edgeLen[i];
    }

    int last = layerSigma.length - 1;
    nearImg = bakeGlow(0, 1, pixelDensity, nearRect);           // tight rim: full res
    farImg  = bakeGlow(2, last, 0.5 * pixelDensity, farRect);   // soft haze: half res is plenty
    bakeBody(pixelDensity);
  }

  // Pixel grid around the bolt with room for a blur of radius 'sigma'. Fills r.
  int[] grid(float sigma, float s, float[] r) {
    float pad = 3 * sigma + 2;
    int iw = ceil((w + 2 * pad) * s), ih = ceil((h + 2 * pad) * s);
    r[0] = x - iw / (2 * s);
    r[1] = y - ih / (2 * s);
    r[2] = iw / s;
    r[3] = ih / s;
    return new int[] { iw, ih };
  }

  // Bloom: blur the bolt mask at several radii and add them up as light.
  PImage bakeGlow(int from, int to, float s, float[] rect) {
    int[] size = grid(layerSigma[to] * glowSize * h, s, rect);
    int iw = size[0], ih = size[1], n = iw * ih;
    float[] mask = coverage(rect, iw, ih, s, null);
    float[] r = new float[n], g = new float[n], b = new float[n];
    for (int L = from; L <= to; L++) {
      float[] bl = blur(mask, iw, ih, layerSigma[L] * glowSize * h * s);
      float t = L / (float) (layerSigma.length - 1);            // hot -> yellow -> amber
      color c = t < 0.5 ? lerpColor(glowHot, glowCol, t * 2) : lerpColor(glowCol, glowFar, t * 2 - 1);
      float k = layerStrength[L];
      float cr = red(c) * k, cg = green(c) * k, cb = blue(c) * k;
      for (int i = 0; i < n; i++) {
        float v = max(0, bl[i]);
        r[i] += v * cr;
        g[i] += v * cg;
        b[i] += v * cb;
      }
    }
    PImage img = createImage(iw, ih, ARGB);
    img.loadPixels();
    for (int i = 0; i < n; i++) {
      // light stored as colour * alpha, so an ADD blend gives back r, g, b
      float m = max(r[i], max(g[i], b[i]));
      int a = round(constrain(m + random(-0.5, 0.5), 0, 255));  // dithered alpha
      float sc = 255 / max(m, 0.001);
      img.pixels[i] = (a << 24) | (chan(r[i] * sc) << 16) | (chan(g[i] * sc) << 8) | chan(b[i] * sc);
    }
    img.updatePixels();
    return img;
  }

  int chan(float v) { return round(constrain(v, 0, 255)); }

  void bakeBody(float s) {
    int[] size = grid(0, s, bodyRect);
    int iw = size[0], ih = size[1], n = iw * ih;
    float[] sd = new float[n];
    float[] mask = coverage(bodyRect, iw, ih, s, sd);

    // a soft "spine": distance to the edge, smoothed, normalized
    float[] depth = new float[n];
    for (int i = 0; i < n; i++) depth[i] = max(0, -sd[i]);
    depth = blur(depth, iw, ih, 0.03 * h * s);
    float deepest = 0.001;
    for (int i = 0; i < n; i++) deepest = max(deepest, depth[i]);

    bodyImg = createImage(iw, ih, ARGB);
    coreImg = createImage(iw, ih, ARGB);
    bodyImg.loadPixels();
    coreImg.loadPixels();
    for (int i = 0; i < n; i++) {
      float row = bodyRect[1] + (i / iw + 0.5) / s;
      float vt = constrain((row - (y - h * 0.5)) / h, 0, 1);    // 0 top, 1 bottom
      float rim = ease(0, 2.5, -sd[i] * s);                       // thin amber rim, in pixels
      float spine = depth[i] / deepest;
      color c = lerpColor(bodyEdge, lerpColor(bodyTop, bodyBottom, vt), rim);
      c = lerpColor(c, bodyCore, 0.45 * ease(0.4, 1, spine));
      bodyImg.pixels[i] = (c & 0xFFFFFF) | (chan(mask[i] * 255) << 24);
      coreImg.pixels[i] = (bodyCore & 0xFFFFFF) | (chan(0.85 * ease(0.5, 1, spine) * mask[i] * 255) << 24);
    }
    bodyImg.updatePixels();
    coreImg.updatePixels();
  }

  // Anti-aliased inside mask of the outline over a pixel grid (optionally keeps distances).
  float[] coverage(float[] rect, int iw, int ih, float s, float[] keepDist) {
    float ox = rect[0], oy = rect[1];
    float[] m = new float[iw * ih];
    for (int j = 0; j < ih; j++) {
      for (int i = 0; i < iw; i++) {
        float d = signedDist(ox + (i + 0.5) / s, oy + (j + 0.5) / s);
        m[j * iw + i] = constrain(0.5 - d * s, 0, 1);
        if (keepDist != null) keepDist[j * iw + i] = d;
      }
    }
    return m;
  }

  // Gaussian blur, approximated by three box blurs (each pass O(n), any radius).
  float[] blur(float[] src, int iw, int ih, float sigma) {
    int r = max(1, round((sqrt(4 * sigma * sigma + 1) - 1) / 2));
    float[] a = src.clone(), tmp = new float[src.length];
    for (int pass = 0; pass < 3; pass++) {
      boxBlur(a, tmp, iw, ih, r, 1, iw);    // horizontal
      boxBlur(tmp, a, ih, iw, r, iw, 1);    // vertical
    }
    return a;
  }

  // 1D box blur along lines: 'len' samples spaced 'step', lines spaced 'lineStep'.
  void boxBlur(float[] src, float[] dst, int len, int lines, int r, int step, int lineStep) {
    float inv = 1.0 / (2 * r + 1);
    for (int l = 0; l < lines; l++) {
      int base = l * lineStep;
      float acc = 0;
      for (int i = 0; i <= r && i < len; i++) acc += src[base + i * step];
      for (int i = 0; i < len; i++) {
        dst[base + i * step] = acc * inv;
        if (i + r + 1 < len) acc += src[base + (i + r + 1) * step];
        if (i - r >= 0)      acc -= src[base + (i - r) * step];
      }
    }
  }

  // Distance to the outline: negative inside, positive outside.
  float signedDist(float px, float py) {
    float best = Float.MAX_VALUE;
    boolean inside = false;
    int n = vx.length;
    for (int i = 0, j = n - 1; i < n; j = i++) {
      float ax = vx[j], ay = vy[j], ex = vx[i] - ax, ey = vy[i] - ay;
      float t = constrain(((px - ax) * ex + (py - ay) * ey) / (ex * ex + ey * ey), 0, 1);
      float dx = px - ax - ex * t, dy = py - ay - ey * t;
      best = min(best, dx * dx + dy * dy);
      if ((ay > py) != (vy[i] > py) && px < ax + (py - ay) * ex / ey) inside = !inside;
    }
    return inside ? -sqrt(best) : sqrt(best);
  }

  float ease(float e0, float e1, float v) {  // smoothstep
    float t = constrain((v - e0) / (e1 - e0), 0, 1);
    return t * t * (3 - 2 * t);
  }

  // ---- electricity ------------------------------------------

  Arc spawnArc(boolean big) {
    float r = random(perimeter);              // random point on the outline
    int e = 0;
    while (e < edgeLen.length - 1 && r > edgeLen[e]) { r -= edgeLen[e]; e++; }
    int f = (e + 1) % vx.length;
    float t = r / edgeLen[e];
    float px = lerp(vx[e], vx[f], t), py = lerp(vy[e], vy[f], t);
    float tx = (vx[f] - vx[e]) / edgeLen[e], ty = (vy[f] - vy[e]) / edgeLen[e];
    float nx = ty, ny = -tx;
    if (signedDist(px + nx * 2, py + ny * 2) < 0) { nx = -nx; ny = -ny; }   // point outward

    float len = h * (big ? random(0.35, 0.65) : random(0.1, 0.28));
    if (big || random(1) < 0.45) {            // leap out into the air
      float side = random(-0.35, 0.35) * len;
      return new Arc(px, py, px + nx * len + tx * side, py + ny * len + ty * side,
                     0, 0, big ? 1.4 : 0.9, (int) random(big ? 10 : 5, big ? 18 : 11), big);
    }
    float dir = random(1) < 0.5 ? -1 : 1;     // crawl along the edge, bowing outward
    float bulge = len * random(0.12, 0.3);
    return new Arc(px, py, px + tx * len * dir, py + ty * len * dir,
                   nx * bulge, ny * bulge, 0.9, (int) random(5, 11), false);
  }

  void emitSparks(int count, boolean burst) {
    for (int i = 0; i < count; i++) {
      int c = (!burst || random(1) < 0.5) ? tip : (int) random(vx.length);
      float ang = HALF_PI + random(-1, 1) * (burst ? 1.6 : 0.7);
      float sp  = burst ? random(2, 9) : random(1, 3.5);
      sparks.add(new Spark(vx[c], vy[c], cos(ang) * sp, sin(ang) * sp,
                           random(18, 45), random(1.2, 2.6)));
    }
  }
}


// A crackling arc: midpoint displacement, re-rolled every few frames, can fork.
class Arc {
  float ax, ay, bx, by, ox, oy, weight;
  int life, maxLife;
  boolean forks;
  ArrayList<float[]> paths = new ArrayList<float[]>();   // x,y pairs; [0] is the main arc

  Arc(float ax, float ay, float bx, float by, float ox, float oy,
      float weight, int life, boolean forks) {
    this.ax = ax; this.ay = ay; this.bx = bx; this.by = by;
    this.ox = ox; this.oy = oy;
    this.weight = weight;
    this.life = this.maxLife = life;
    this.forks = forks;
    build();
  }

  void build() {
    paths.clear();
    float[] main = zigzag(ax, ay, bx, by, ox, oy, 5);
    paths.add(main);
    if (forks) {
      int count = (int) random(1, 3);
      float len = dist(ax, ay, bx, by);
      float dir = atan2(by - ay, bx - ax);
      for (int i = 0; i < count; i++) {
        int k = 2 * (int) random(6, 26);     // start somewhere along the main arc
        float a = dir + random(-0.9, 0.9), l = len * random(0.25, 0.5);
        paths.add(zigzag(main[k], main[k + 1], main[k] + cos(a) * l, main[k + 1] + sin(a) * l, 0, 0, 4));
      }
    }
  }

  float[] zigzag(float x0, float y0, float x1, float y1, float bowX, float bowY, int depth) {
    int n = (1 << depth) + 1;
    float[] p = new float[n * 2];
    p[0] = x0; p[1] = y0;
    p[2 * n - 2] = x1; p[2 * n - 1] = y1;
    for (int step = n - 1; step > 1; step /= 2) {
      int half = step / 2;
      for (int i = 0; i < n - 1; i += step) {
        int k = i + step, m = i + half;
        float dx = p[2 * k] - p[2 * i], dy = p[2 * k + 1] - p[2 * i + 1];
        float kick = random(-0.3, 0.3);
        p[2 * m]     = (p[2 * i] + p[2 * k]) * 0.5 - dy * kick;
        p[2 * m + 1] = (p[2 * i + 1] + p[2 * k + 1]) * 0.5 + dx * kick;
        if (step == n - 1) { p[2 * m] += bowX; p[2 * m + 1] += bowY; }
      }
    }
    return p;
  }

  boolean update() {
    life--;
    if (life % 3 == 0) build();
    return life > 0;
  }

  void draw() {
    float a = life / (float) maxLife * random(0.65, 1);    // electric flicker
    noFill();
    strokeJoin(ROUND);
    for (int i = 0; i < paths.size(); i++) {
      float wt = weight * (i == 0 ? 1 : 0.6);
      float[] p = paths.get(i);
      stroke(255, 200, 40, 50 * a);   strokeWeight(5 * wt);   polyline(p);
      stroke(255, 232, 120, 130 * a); strokeWeight(2 * wt);   polyline(p);
      stroke(255, 255, 240, 255 * a); strokeWeight(0.9 * wt); polyline(p);
    }
  }

  void polyline(float[] p) {
    beginShape();
    for (int i = 0; i < p.length; i += 2) vertex(p[i], p[i + 1]);
    endShape();
  }
}


// A hot spark that falls, cools down and fades.
class Spark {
  float x, y, vx, vy, life, maxLife, size;

  Spark(float x, float y, float vx, float vy, float life, float size) {
    this.x = x; this.y = y; this.vx = vx; this.vy = vy;
    this.life = this.maxLife = life;
    this.size = size;
  }

  boolean update() {
    vy += 0.11;
    vx *= 0.985;
    vy *= 0.985;
    x += vx;
    y += vy;
    return --life > 0;
  }

  void draw() {
    float a = life / maxLife;
    stroke(lerpColor(color(255, 120, 10), color(255, 250, 215), a), 255 * a);
    strokeWeight(size);
    line(x, y, x - vx * 2.2, y - vy * 2.2);
  }
}


// Shockwave ring on a strike.
class Ring {
  float x, y, r, grow, life, maxLife = 40;

  Ring(float x, float y, float size) {
    this.x = x;
    this.y = y;
    r = size * 0.35;
    grow = size * 0.045;
    life = maxLife;
  }

  boolean update() {
    r += grow;
    grow *= 0.96;
    return --life > 0;
  }

  void draw() {
    float a = life / maxLife;
    noFill();
    stroke(255, 210, 70, 80 * a);   strokeWeight(9 * a + 2);   ellipse(x, y, r * 2, r * 2);
    stroke(255, 245, 190, 150 * a); strokeWeight(1.5 * a + 0.5); ellipse(x, y, r * 2, r * 2);
  }
}
