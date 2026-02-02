void setup() {
    size(400, 400);
    noCursor();
}

void draw() {
    background(0,0,255);
    float n = noise(frameCount * 0.05);
    float diameter = map(n, 0, 1, 50, 300);
    
    fill(255,255,0);
    ellipse(width/2, height/2, diameter, diameter);

}