Circle[] circle = new Circle[50];

void setup(){
    size(680, 680);
    background(0);
}   

void draw(){
    background(0);
    circle[frameCount % circle.length] = new Circle(mouseX, mouseY, 75);

    for (int i = 0; i < circle.length; i++){
        if (circle[i] != null){
            circle[i].draw();
        }
    }
}
