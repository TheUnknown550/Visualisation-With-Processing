void setup() {
    size(400, 400);
    noCursor();
}

void draw() {
    background(255);
    rectMode(CORNER);

    // Square 1: Top Left
    if (mouseX < width/2 && mouseY < height/2) fill(0);
    else fill(255);
    rect(0, 0, width/2, height/2);

    // Square 2: Top Right
    if (mouseX >= width/2 && mouseY < height/2) fill(0);
    else fill(255);
    rect(width/2, 0, width/2, height/2);

    // Square 3: Bottom Left
    if (mouseX < width/2 && mouseY >= height/2) fill(0);
    else fill(255);
    rect(0, height/2, width/2, height/2);

    // Square 4: Bottom Right
    if (mouseX >= width/2 && mouseY >= height/2) fill(0);
    else fill(255);
    rect(width/2, height/2, width/2, height/2);
}