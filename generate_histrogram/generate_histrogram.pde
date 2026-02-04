int[] data;

void setup() {
    size(600, 600);
    String[] stuff = loadStrings("data.txt");
    data = int(split(stuff[0], ","));
}

void draw() {
    background(255);
    for (int i = 0; i < data.length; i++) {
        float x = map(i, 0, data.length, 50, width - 50);
        float h = map(data[i], 0, max(data), 0, height - 100);
        fill(230, 50, 50);
        rect(x, height - h - 50, (width - 100) / data.length - 2, h);
    }
}