class Car{
    color c;
    float x;
    float y;
    float speed;
    Car(color c_, float x_, float y_, float speed_){
        c = c_;
        x = x_;
        y = y_;
        speed = speed_;
    }

    void display(){
        fill(c);
        rectMode(CENTER);
        rect(x, y, 20, 10);
        noStroke();
    }
    void move(){
        x += speed;
        if (x > width + 10){
            x = -10;
        }   
    }
}