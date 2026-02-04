// 3D path visualization of drone movement from data.json
// Left-drag to orbit the view. LEFT/RIGHT arrows switch metric: Temperature, Humidity, Pressure.

import processing.event.*;

JSONArray raw;
ArrayList<PVector> pts = new ArrayList<PVector>();
ArrayList<Float> times = new ArrayList<Float>();
ArrayList<Float> temps = new ArrayList<Float>();
ArrayList<Float> hums = new ArrayList<Float>();
ArrayList<Float> press = new ArrayList<Float>();
float minX=1e9, minY=1e9, minZ=1e9, maxX=-1e9, maxY=-1e9, maxZ=-1e9;
float minTemp=1e9, maxTemp=-1e9;
float minHum=1e9, maxHum=-1e9;
float minPres=1e9, maxPres=-1e9;
float cx, cy, cz; // center
float scaleFactor = 1;
float rotX = -PI/6; // start tilted down a bit
float rotY = PI/6;
float animPos = 0;    // fractional index along the path
float animSpeed = 0.35; // segments advanced per frame (smaller = slower)
int mode = 0; // 0=temp, 1=humidity, 2=pressure
String[] modeLabel = {"Temperature", "Humidity", "Pressure"};

void setup() {
  size(900, 700, P3D);
  smooth(8);
  loadData();
}

void draw() {
  background(245);
  lights();

  updateAnimation();

  pushMatrix();
  translate(width/2, height/2, 0);
  rotateX(rotX);
  rotateY(rotY);
  scale(scaleFactor);
  translate(-cx, -cy, -cz);

  drawAxes();
  drawGround();
  drawPathAnimated();
  drawCurrentPoint();

  popMatrix();

  drawHud();
}

void mouseDragged() {
  rotY += (mouseX - pmouseX) * 0.01;
  rotX += (mouseY - pmouseY) * 0.01;
}

void keyPressed() {
  if (keyCode == RIGHT) {
    mode = (mode + 1) % 3;
  } else if (keyCode == LEFT) {
    mode = (mode + 2) % 3; // equivalent to -1 mod 3
  }
}

void loadData() {
  raw = loadJSONArray("data.json");
  if (raw == null || raw.size() == 0) {
    println("Failed to load data.json or it's empty.");
    return;
  }
  for (int i = 0; i < raw.size(); i++) {
    JSONObject o = raw.getJSONObject(i);
    float x = o.getFloat("x");
    float y = o.getFloat("y");
    float z = o.getFloat("z");
    float t = o.getFloat("t");
    float temp = o.hasKey("temp") ? o.getFloat("temp") : 0;
    float hum = o.hasKey("humidity") ? o.getFloat("humidity") : Float.NaN;
    float presVal = o.hasKey("pressure") ? o.getFloat("pressure") : Float.NaN;
    pts.add(new PVector(x, y, z));
    times.add(t);
    temps.add(temp);
    hums.add(hum);
    press.add(presVal);
    minX = min(minX, x); maxX = max(maxX, x);
    minY = min(minY, y); maxY = max(maxY, y);
    minZ = min(minZ, z); maxZ = max(maxZ, z);
    minTemp = min(minTemp, temp); maxTemp = max(maxTemp, temp);
    if (!Float.isNaN(hum)) { minHum = min(minHum, hum); maxHum = max(maxHum, hum); }
    if (!Float.isNaN(presVal)) { minPres = min(minPres, presVal); maxPres = max(maxPres, presVal); }
  }
  // fallbacks if missing
  if (minHum > 1e8) { minHum = 0; maxHum = 100; }
  if (minPres > 1e8) { minPres = 990; maxPres = 1030; }
  cx = (minX + maxX)/2.0;
  cy = (minY + maxY)/2.0;
  cz = (minZ + maxZ)/2.0;
  float span = max(maxX - minX, max(maxY - minY, maxZ - minZ));
  scaleFactor = span == 0 ? 1 : 400.0 / span; // fit into view
}

void drawAxes() {
  strokeWeight(2/scaleFactor);
  // X axis (red)
  stroke(220, 60, 60);
  line(minX-20, cy, cz, maxX+20, cy, cz);
  // Y axis (green)
  stroke(60, 200, 100);
  line(cx, minY-20, cz, cx, maxY+20, cz);
  // Z axis (blue)
  stroke(70, 120, 230);
  line(cx, cy, minZ-20, cx, cy, maxZ+20);
}

void drawGround() {
  stroke(210);
  strokeWeight(1/scaleFactor);
  noFill();
  float step = (maxX - minX) / 10.0;
  if (step <= 0) step = 5;
  for (float x = minX-10; x <= maxX+10; x += step) {
    line(x, minY-10, minZ-10, x, minY-10, maxZ+10);
  }
  for (float z = minZ-10; z <= maxZ+10; z += step) {
    line(minX-10, minY-10, z, maxX+10, minY-10, z);
  }
}

void drawPathAnimated() {
  if (pts.size() < 2) return;
  int lastFull = floor(animPos);
  float f = animPos - lastFull;

  strokeWeight(3/scaleFactor);

  // Completed segments
  for (int i = 1; i <= lastFull; i++) {
    float vAvg = (activeValue(i-1) + activeValue(i)) * 0.5;
    stroke(valueColor(vAvg));
    PVector a = pts.get(i-1);
    PVector b = pts.get(i);
    line(a.x, a.y, a.z, b.x, b.y, b.z);
  }

  // In-progress segment
  if (lastFull < pts.size() - 1) {
    PVector a = pts.get(lastFull);
    PVector b = pts.get(lastFull + 1);
    PVector mid = PVector.lerp(a, b, f);
    float vAvg = (activeValue(lastFull) + activeValue(lastFull + 1)) * 0.5;
    stroke(valueColor(vAvg));
    line(a.x, a.y, a.z, mid.x, mid.y, mid.z);
  }
}

void drawCurrentPoint() {
  if (pts.size() < 2) return;
  int i = floor(animPos);
  float f = animPos - i;
  PVector a = pts.get(i);
  PVector b = pts.get(i+1);
  PVector p = PVector.lerp(a, b, f);
  float vNow = lerp(activeValue(i), activeValue(i+1), f);
  pushMatrix();
  translate(p.x, p.y, p.z);
  noStroke();
  fill(valueColor(vNow));
  sphereDetail(12);
  sphere(6/scaleFactor);
  popMatrix();
}

void drawHud() {
  fill(20);
  textAlign(LEFT, TOP);
  text("Points: " + pts.size(), 10, 10);
  if (!times.isEmpty()) {
    text("Last t: " + times.get(times.size()-1), 10, 28);
  }
  float vMin = mode == 0 ? minTemp : mode == 1 ? minHum : minPres;
  float vMax = mode == 0 ? maxTemp : mode == 1 ? maxHum : maxPres;
  text(modeLabel[mode] + " range: " + nf(vMin, 0, 2) + " - " + nf(vMax, 0, 2), 10, 46);
  text("Playback " + modeLabel[mode] + ": " + nf(currentValue(), 0, 2), 10, 64);
  text("Drag to orbit", 10, 82);
  text("Playback: " + nf(animPos, 0, 2) + " / " + (pts.size()-1), 10, 100);
  text("Switch metric: LEFT/RIGHT", 10, 118);
}

void updateAnimation() {
  if (pts.size() < 2) return;
  animPos += animSpeed;
  float maxPos = pts.size() - 1;
  if (animPos >= maxPos) {
    animPos -= maxPos; // loop back to start
  }
}

float currentValue() {
  if (pts.size() < 2) return activeValue(0);
  int i = floor(animPos);
  float f = animPos - i;
  return lerp(activeValue(i), activeValue(i+1), f);
}

float activeValue(int i) {
  switch(mode) {
  case 1: return hums.get(i);
  case 2: return press.get(i);
  default: return temps.get(i);
  }
}

// Map active metric to a blue->yellow->red palette
int valueColor(float v) {
  float vMin = mode == 0 ? minTemp : mode == 1 ? minHum : minPres;
  float vMax = mode == 0 ? maxTemp : mode == 1 ? maxHum : maxPres;
  if (vMax - vMin < 0.0001) return color(255, 200, 0);
  float norm = constrain(map(v, vMin, vMax, 0, 1), 0, 1);
  if (norm < 0.5) {
    return lerpColor(color(30, 90, 255), color(255, 220, 80), norm * 2);
  } else {
    return lerpColor(color(255, 220, 80), color(240, 50, 40), (norm - 0.5) * 2);
  }
}
