// 4D mapping: animated spectrogram-like plot where
// X = Temperature, Y = Humidity, Z = Pressure, Time = animation frames.
// Left-drag to orbit. Scroll wheel can be used by user to zoom if desired (not implemented here).

import processing.event.*;

JSONArray raw;
ArrayList<Float> temps = new ArrayList<Float>();
ArrayList<Float> hums = new ArrayList<Float>();
ArrayList<Float> press = new ArrayList<Float>();
ArrayList<Float> times = new ArrayList<Float>();

float minTemp=1e9, maxTemp=-1e9;
float minHum=1e9, maxHum=-1e9;
float minPres=1e9, maxPres=-1e9;

float cx, cy, cz; // center in value space
float scaleFactor = 1;
float rotX = -PI/6;
float rotY = PI/6;
float animPos = 0;    // fractional index along time
float animSpeed = 0.5; // frames per draw (smaller = slower)
int trail = 40;        // number of historical samples to display with fade

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
  drawGrid();
  drawTrail();
  drawCurrentPoint();

  popMatrix();

  drawHud();
}

void mouseDragged() {
  rotY += (mouseX - pmouseX) * 0.01;
  rotX += (mouseY - pmouseY) * 0.01;
}

void loadData() {
  raw = loadJSONArray("data.json");
  if (raw == null || raw.size() == 0) {
    println("Failed to load data.json or it's empty.");
    return;
  }
  for (int i = 0; i < raw.size(); i++) {
    JSONObject o = raw.getJSONObject(i);
    float temp = o.hasKey("temp") ? o.getFloat("temp") : 0;
    float hum = o.hasKey("humidity") ? o.getFloat("humidity") : 0;
    float presVal = o.hasKey("pressure") ? o.getFloat("pressure") : 0;
    float t = o.hasKey("t") ? o.getFloat("t") : i;
    temps.add(temp);
    hums.add(hum);
    press.add(presVal);
    times.add(t);
    minTemp = min(minTemp, temp); maxTemp = max(maxTemp, temp);
    minHum = min(minHum, hum); maxHum = max(maxHum, hum);
    minPres = min(minPres, presVal); maxPres = max(maxPres, presVal);
  }
  cx = (minTemp + maxTemp)/2.0;
  cy = (minHum + maxHum)/2.0;
  cz = (minPres + maxPres)/2.0;
  float spanX = maxTemp - minTemp;
  float spanY = maxHum - minHum;
  float spanZ = maxPres - minPres;
  float span = max(spanX, max(spanY, spanZ));
  scaleFactor = span == 0 ? 1 : 420.0 / span; // fit into view with some padding
}

void drawAxes() {
  strokeWeight(2/scaleFactor);
  // X: Temperature (red)
  stroke(220, 60, 60);
  line(minTemp-2, cy, cz, maxTemp+2, cy, cz);
  // Y: Humidity (green)
  stroke(60, 200, 100);
  line(cx, minHum-2, cz, cx, maxHum+2, cz);
  // Z: Pressure (blue)
  stroke(70, 120, 230);
  line(cx, cy, minPres-2, cx, cy, maxPres+2);
}

void drawGrid() {
  stroke(220);
  strokeWeight(1/scaleFactor);
  noFill();
  float stepX = (maxTemp - minTemp) / 6.0;
  float stepY = (maxHum - minHum) / 6.0;
  float stepZ = (maxPres - minPres) / 6.0;
  if (stepX == 0) stepX = 1;
  if (stepY == 0) stepY = 1;
  if (stepZ == 0) stepZ = 1;
  // Planes parallel to YZ (vary X)
  for (float x = minTemp; x <= maxTemp+0.1; x += stepX) {
    line(x, minHum, minPres, x, maxHum, minPres);
    line(x, minHum, minPres, x, minHum, maxPres);
  }
  // Planes parallel to XZ (vary Y)
  for (float y = minHum; y <= maxHum+0.1; y += stepY) {
    line(minTemp, y, minPres, maxTemp, y, minPres);
    line(minTemp, y, minPres, minTemp, y, maxPres);
  }
  // Planes parallel to XY (vary Z)
  for (float z = minPres; z <= maxPres+0.1; z += stepZ) {
    line(minTemp, minHum, z, maxTemp, minHum, z);
    line(minTemp, minHum, z, minTemp, maxHum, z);
  }
}

void drawTrail() {
  if (temps.size() < 2) return;
  int last = floor(animPos);
  float f = animPos - last;
  int first = max(0, last - trail);
  strokeWeight(3/scaleFactor);
  for (int i = first+1; i <= last; i++) {
    float alpha = map(i, first+1, last, 40, 200);
    stroke(applyAlpha(valueColor((value(i-1)+value(i))*0.5), alpha));
    PVector a = pointAt(i-1);
    PVector b = pointAt(i);
    line(a.x, a.y, a.z, b.x, b.y, b.z);
  }
  // partial segment
  if (last < temps.size()-1) {
    PVector a = pointAt(last);
    PVector b = pointAt(last+1);
    PVector mid = PVector.lerp(a, b, f);
    float alpha = 200;
    stroke(applyAlpha(valueColor((value(last)+value(last+1))*0.5), alpha));
    line(a.x, a.y, a.z, mid.x, mid.y, mid.z);
  }
}

void drawCurrentPoint() {
  if (temps.size() < 2) return;
  int i = floor(animPos);
  float f = animPos - i;
  PVector a = pointAt(i);
  PVector b = pointAt(i+1);
  PVector p = PVector.lerp(a, b, f);
  float vNow = lerp(value(i), value(i+1), f);
  pushMatrix();
  translate(p.x, p.y, p.z);
  noStroke();
  fill(valueColor(vNow));
  sphereDetail(12);
  sphere(7/scaleFactor);
  popMatrix();
}

void drawHud() {
  fill(20);
  textAlign(LEFT, TOP);
  text("4D Mapping (X Temp, Y Hum, Z Pres)", 10, 10);
  text("Point: " + nf(animPos, 0, 2) + " / " + (temps.size()-1), 10, 28);
  text("Temp: " + nf(currentTemp(), 0, 2) + "  Hum: " + nf(currentHum(), 0, 2) + "%  Pres: " + nf(currentPres(), 0, 2) + " hPa", 10, 46);
  text("Trail length: " + trail + " samples  |  Speed: " + nf(animSpeed,0,2), 10, 64);
  text("Drag to orbit", 10, 82);
}

void updateAnimation() {
  if (temps.size() < 2) return;
  animPos += animSpeed;
  float maxPos = temps.size() - 1;
  if (animPos >= maxPos) {
    animPos -= maxPos; // loop
  }
}

PVector pointAt(int i) {
  return new PVector(temps.get(i), hums.get(i), press.get(i));
}

float value(int i) {
  // composite value for coloring; here we use temperature
  return temps.get(i);
}

float currentTemp() {
  int i = floor(animPos);
  float f = animPos - i;
  return lerp(temps.get(i), temps.get(i+1), f);
}

float currentHum() {
  int i = floor(animPos);
  float f = animPos - i;
  return lerp(hums.get(i), hums.get(i+1), f);
}

float currentPres() {
  int i = floor(animPos);
  float f = animPos - i;
  return lerp(press.get(i), press.get(i+1), f);
}

color applyAlpha(color c, float a) {
  return color(red(c), green(c), blue(c), constrain(a, 0, 255));
}

// Palette based on temperature for consistency
int valueColor(float temp) {
  if (maxTemp - minTemp < 0.0001) return color(255, 200, 0);
  float norm = constrain(map(temp, minTemp, maxTemp, 0, 1), 0, 1);
  if (norm < 0.5) {
    return lerpColor(color(30, 90, 255), color(255, 220, 80), norm * 2);
  } else {
    return lerpColor(color(255, 220, 80), color(240, 50, 40), (norm - 0.5) * 2);
  }
}
