Car[] cars = new Car[100];

void setup(){
    size(400, 400);
    for (int i = 0; i < cars.length; i++){
        cars[i] = new Car(color(random(255), random(255), random(255)), random(width), random(height), random(-5, 5));
    }
}

void draw(){
    background(0);
    for (int i = 0; i < cars.length; i++){
        cars[i].display();
        cars[i].move();
    }
}
