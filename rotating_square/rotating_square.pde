void setup() {
  size(600, 600);
}

void draw() {
  background(255);
  rectMode(CENTER);
  translate(width/2, height/2);
  rotate(frameCount * 0.05);
  stroke(255);
  fill(160, 32, 240);
  rect(0, 0, 200, 200);

}