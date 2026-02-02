void setup(){
    size(400, 400);
}

float x = 25;
static float speed = 2;

void draw(){
    background(255);
    
    // Update ball position
    x += speed;

    if (x > width - 25 || x < 25) {
        speed *= -1;
    }

    // 
    // Draw ball
    fill(255, 0, 0);
    ellipseMode(CENTER);
    ellipse(x, 200, 50, 50);
}