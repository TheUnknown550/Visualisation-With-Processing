// Noise-driven moving yellow ball with integer position labels
// Displays x and y coordinates above the ball

PVector pos;
float radius = 20;
float tX = 0;      // noise time for x
float tY = 1000;   // noise time for y (offset so x/y are independent)
float noiseStep = 0.01;

void setup() {
  size(600, 600);
  pos = new PVector(width/2, height/2);
  textAlign(CENTER, BOTTOM);
  textSize(16);
}

void draw() {
  background(0, 130, 255); // blue background

  // Update position directly from noise fields
  pos.x = noise(tX) * width;
  pos.y = noise(tY) * height;
  tX += noiseStep;
  tY += noiseStep;

  // draw coords
  fill(255);
  int xi = int(pos.x);
  int yi = int(pos.y);
  text("x=" + xi + " y=" + yi, pos.x, pos.y - radius - 6);

  // draw ball
  fill(255, 215, 0); // yellow
  noStroke();
  ellipse(pos.x, pos.y, radius*2, radius*2);
}
