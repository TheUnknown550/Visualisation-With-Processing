// Simple Snake game in Processing
// Features:
// - Snake grows when it eats food
// - Hitting your own tail or the wall ends the game (snake stops)
// - Press R to restart

int cellSize = 20;
int cols, rows;
Snake snake;
Food food;
boolean gameOver = false;

void setup() {
  size(600, 600);
  frameRate(10);
  cols = width / cellSize;
  rows = height / cellSize;
  resetGame();
}

void draw() {
  background(18, 18, 18);
  drawGrid();

  if (!gameOver) {
    boolean ate = snake.update(food.pos);
    if (ate) {
      food.respawn(snake.body);
    }
    if (snake.isDead()) {
      gameOver = true;
    }
  }

  food.show();
  snake.show();
  drawHud();
}

void keyPressed() {
  if (key == 'r' || key == 'R') {
    resetGame();
    return;
  }

  // Prevent 180-degree reversals
  if (keyCode == UP && snake.dir.y != 1) {
    snake.dir = new PVector(0, -1);
  } else if (keyCode == DOWN && snake.dir.y != -1) {
    snake.dir = new PVector(0, 1);
  } else if (keyCode == LEFT && snake.dir.x != 1) {
    snake.dir = new PVector(-1, 0);
  } else if (keyCode == RIGHT && snake.dir.x != -1) {
    snake.dir = new PVector(1, 0);
  }
}

void resetGame() {
  snake = new Snake();
  food = new Food();
  gameOver = false;
}

void drawGrid() {
  stroke(40);
  for (int x = 0; x <= width; x += cellSize) {
    line(x, 0, x, height);
  }
  for (int y = 0; y <= height; y += cellSize) {
    line(0, y, width, y);
  }
}

void drawHud() {
  fill(255);
  textSize(16);
  textAlign(LEFT, TOP);
  text("Score: " + (snake.body.size() - 1), 10, 10);

  if (gameOver) {
    textAlign(CENTER, CENTER);
    textSize(24);
    text("Game Over\nPress R to restart", width / 2, height / 2);
  }
}

class Snake {
  ArrayList<PVector> body = new ArrayList<PVector>();
  PVector dir = new PVector(1, 0); // start moving right
  boolean dead = false;

  Snake() {
    body.add(new PVector(cols / 2, rows / 2));
  }

  boolean update(PVector foodPos) {
    if (dead) return false;

    PVector head = body.get(0);
    PVector next = PVector.add(head, dir);

    // Wall collision
    if (next.x < 0 || next.x >= cols || next.y < 0 || next.y >= rows) {
      dead = true;
      return false;
    }

    // Tail collision
    if (hitsSelf(next)) {
      dead = true;
      return false;
    }

    body.add(0, next);
    boolean ate = (next.x == foodPos.x && next.y == foodPos.y);
    if (!ate) {
      body.remove(body.size() - 1); // move forward
    }
    return ate;
  }

  boolean hitsSelf(PVector pos) {
    for (int i = 0; i < body.size(); i++) {
      PVector b = body.get(i);
      if (pos.x == b.x && pos.y == b.y) {
        return true;
      }
    }
    return false;
  }

  boolean isDead() {
    return dead;
  }

  void show() {
    noStroke();
    for (int i = 0; i < body.size(); i++) {
      PVector p = body.get(i);
      float shade = map(i, 0, body.size(), 255, 120);
      fill(shade, 200, 120);
      rect(p.x * cellSize, p.y * cellSize, cellSize, cellSize, 4);
    }
  }
}

class Food {
  PVector pos;

  Food() {
    respawn(new ArrayList<PVector>());
  }

  void respawn(ArrayList<PVector> occupied) {
    while (true) {
      int x = int(random(cols));
      int y = int(random(rows));
      boolean clash = false;
      for (PVector b : occupied) {
        if (b.x == x && b.y == y) {
          clash = true;
          break;
        }
      }
      if (!clash) {
        pos = new PVector(x, y);
        return;
      }
    }
  }

  void show() {
    fill(200, 60, 80);
    noStroke();
    rect(pos.x * cellSize, pos.y * cellSize, cellSize, cellSize, 4);
  }
}
