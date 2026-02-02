class Circle{
    private float x;
    private float y;
    private float r;
    private float change_blue = 255;
    Circle(float x_, float y_, float r_){
        x = x_;
        y = y_;
        r = r_;
    }
    void draw(){
        noStroke();
        fill(0, 150, change_blue);
        ellipseMode(CENTER);
        ellipse(x, y, r, r);
        r = r > 0 ? r-1.5 : 0;
        change_blue = change_blue > 0 ? change_blue-5 : 0;
    }
}