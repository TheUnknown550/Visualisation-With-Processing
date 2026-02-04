void setup() {
  size(600, 600, P3D);
}

void draw() {
  background(0);
  stroke(255);
  noFill();
  
  translate(width/2, height/2, 0);
  rotateX(frameCount * 0.01);
  rotateY(frameCount * 0.01);
  box(200);
}