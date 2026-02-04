// Two independently rotating squares
// Square A: 2D rotation around Z axis
// Square B: 3D rotation around Y axis

void setup() {
  size(600, 600, P3D);
  rectMode(CENTER);
  noStroke();
}

void draw() {
  background(245);

  // Square A
  pushMatrix();
  translate(width/4, height/4);
  rotate(frameCount * 0.03);
  fill(160, 32, 240); // purple
  rect(0, 0, 150, 150);
  popMatrix();

  // Square B
  pushMatrix();
  translate(width/1.5, height/1.5);
  rotateY(frameCount * 0.04);
  fill(32, 160, 240); // blue
  rect(0, 0, 150, 150);
  popMatrix();
}
