// 3D path visualization of drone movement from data.json
// Left-drag to orbit the view.

import processing.event.*;

JSONArray raw;
ArrayList<PVector> pts = new ArrayList<PVector>();
ArrayList<Float> times = new ArrayList<Float>();
ArrayList<Float> temps = new ArrayList<Float>();
float minX=1e9, minY=1e9, minZ=1e9, maxX=-1e9, maxY=-1e9, maxZ=-1e9;
float minTemp=1e9, maxTemp=-1e9;
float cx, cy, cz; // center
float scaleFactor = 1;
float rotX = -PI/6; // start tilted down a bit
float rotY = PI/6;
PVector planeOrigin;
PVector planeNormal;
PVector planeU;
PVector planeV;
float planeThickness = 10; // height of temp extrusion along the plane normal

void setup() {
  size(900, 700, P3D);
  smooth(8);
  loadData();
}

void draw() {
  background(245);
  lights();

  pushMatrix();
  translate(width/2, height/2, 0);
  rotateX(rotX);
  rotateY(rotY);
  scale(scaleFactor);
  translate(-cx, -cy, -cz);

  drawAxes();
  drawGround();
  drawFilledPlane();
  drawPath();
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
    float x = o.getFloat("x");
    float y = o.getFloat("y");
    float z = o.getFloat("z");
    float t = o.getFloat("t");
    float temp = o.hasKey("temp") ? o.getFloat("temp") : 0;
    pts.add(new PVector(x, y, z));
    times.add(t);
    temps.add(temp);
    minX = min(minX, x); maxX = max(maxX, x);
    minY = min(minY, y); maxY = max(maxY, y);
    minZ = min(minZ, z); maxZ = max(maxZ, z);
    minTemp = min(minTemp, temp); maxTemp = max(maxTemp, temp);
  }
  cx = (minX + maxX)/2.0;
  cy = (minY + maxY)/2.0;
  cz = (minZ + maxZ)/2.0;
  float span = max(maxX - minX, max(maxY - minY, maxZ - minZ));
  scaleFactor = span == 0 ? 1 : 400.0 / span; // fit into view
  planeThickness = span * 0.08; // 8% of size gives visible relief
  computeBestFitPlane();
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

void drawFilledPlane() {
  if (pts.size() < 3 || planeOrigin == null) return;
  noStroke();
  beginShape(TRIANGLE_FAN);
  float midTemp = (minTemp + maxTemp) * 0.5;
  PVector center = PVector.add(planeOrigin, tempOffset(midTemp));
  fill(tempColor(midTemp));
  vertex(center.x, center.y, center.z);

  for (int i = 0; i < pts.size(); i++) {
    PVector p = extrudedPoint(pts.get(i), temps.get(i));
    fill(tempColor(temps.get(i)));
    vertex(p.x, p.y, p.z);
  }
  PVector p0 = extrudedPoint(pts.get(0), temps.get(0));
  fill(tempColor(temps.get(0)));
  vertex(p0.x, p0.y, p0.z);
  endShape();
}

PVector extrudedPoint(PVector original, float temp) {
  PVector onPlane = projectToPlane(original);
  return PVector.add(onPlane, tempOffset(temp));
}

PVector tempOffset(float temp) {
  float offset = map(temp, minTemp, maxTemp, -planeThickness/2.0, planeThickness/2.0);
  return PVector.mult(planeNormal, offset);
}

void drawPath() {
  if (pts.size() < 2) return;
  strokeWeight(3/scaleFactor);
  for (int i = 1; i < pts.size(); i++) {
    float tempAvg = (temps.get(i-1) + temps.get(i)) * 0.5;
    stroke(tempColor(tempAvg));
    PVector a = pts.get(i-1);
    PVector b = pts.get(i);
    line(a.x, a.y, a.z, b.x, b.y, b.z);
  }
}

void drawCurrentPoint() {
  if (pts.isEmpty()) return;
  PVector p = pts.get(pts.size()-1);
  pushMatrix();
  translate(p.x, p.y, p.z);
  noStroke();
  fill(tempColor(temps.get(temps.size()-1)));
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
  if (!temps.isEmpty()) {
    text("Temp range: " + nf(minTemp, 0, 2) + " - " + nf(maxTemp, 0, 2), 10, 46);
    text("Last temp: " + nf(temps.get(temps.size()-1), 0, 2), 10, 64);
  }
  text("Drag to orbit", 10, 82);
}

void computeBestFitPlane() {
  if (pts.size() < 3) return;
  PVector c = new PVector(cx, cy, cz); // centroid already computed
  PVector sumCross = new PVector();
  for (int i = 0; i < pts.size(); i++) {
    PVector a = PVector.sub(pts.get(i), c);
    PVector b = PVector.sub(pts.get((i+1) % pts.size()), c);
    sumCross.add(PVector.cross(a, b, null));
  }
  if (sumCross.mag() < 1e-4) {
    planeNormal = new PVector(0, 1, 0);
  } else {
    planeNormal = sumCross.normalize(null);
  }
  planeU = PVector.cross(planeNormal, new PVector(0, 0, 1), null);
  if (planeU.mag() < 1e-4) {
    planeU = PVector.cross(planeNormal, new PVector(0, 1, 0), null);
  }
  planeU.normalize();
  planeV = PVector.cross(planeNormal, planeU, null).normalize();
  planeOrigin = c.copy();
}

PVector projectToPlane(PVector p) {
  PVector delta = PVector.sub(p, planeOrigin);
  float u = PVector.dot(delta, planeU);
  float v = PVector.dot(delta, planeV);
  return PVector.add(planeOrigin, PVector.add(PVector.mult(planeU, u), PVector.mult(planeV, v)));
}

// Map temperature to a blue->yellow->red heat palette
int tempColor(float temp) {
  if (maxTemp - minTemp < 0.0001) return color(255, 200, 0);
  float norm = constrain(map(temp, minTemp, maxTemp, 0, 1), 0, 1);
  if (norm < 0.5) {
    return lerpColor(color(30, 90, 255), color(255, 220, 80), norm * 2);
  } else {
    return lerpColor(color(255, 220, 80), color(240, 50, 40), (norm - 0.5) * 2);
  }
}
