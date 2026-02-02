class Rectangle {
    float x, y, w, h, r, g, b;

    Rectangle(float x, float y, float w, float h, float r, float g, float b) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.r = r;
        this.g = g;
        this.b = b;
    }

    void display() {
        fill(r, g, b, 100);
        rectMode(CENTER);
        rect(x, y, w, h);
    }
}

class Circle {
    float x, y, r, r2, g2, b2;

    Circle(float x, float y, float r, float r2, float g2, float b2) {
        this.x = x;
        this.y = y;
        this.r = r;
        this.r2 = r2;
        this.g2 = g2;
        this.b2 = b2;
    }

    void display() {
        fill(r2, g2, b2, 100);
        ellipseMode(CENTER);
        ellipse(x, y, r * 2, r * 2);
    }
}


void setup() {
    size(400, 400);
}

int c1y = 50;
int c1x = 50;
int c2y = 50;
int c2x = 350;
int c3y = 350;
int c3x = 200;


void draw() {
    background(255);
    Circle c1 = new Circle(c1x, c1y, 50, 255,0,0);
    c1.display();
    Circle c2 = new Circle(c2x, c2y, 50, 0,255,0);
    c2.display();
    Circle c3 = new Circle(c3x, c3y, 50, 0,0,255);
    c3.display();
    c2y += 1;
    c2x -= 1;
    c1y += 1;
    c1x += 1;
    c3y -= 1;
}