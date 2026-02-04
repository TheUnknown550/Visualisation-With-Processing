void setup() {
  size(600, 600, P3D);
}

void draw() {
  background(255);
  rectMode(CENTER);
  translate(width/4, height/4);
  rotate(frameCount * 0.05);
  stroke(255);
  fill(160, 32, 240);
  rect(0, 0, 150, 150);

  translate(width/1.5, height/1.5);
  rotateY(frameCount * 0.05);
  stroke(255);
  rectMode(CENTER);
  fill(160, 32, 240);
  rect(0, 0, 150, 150);


}