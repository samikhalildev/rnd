/*
Sprite collision detection
 Move the hero with the arrow keys. If the hero hits the enemy then the background will change red.
 
 Author: Jason Labbe
 Site: jasonlabbe3d.com
 */

PImage hero;
int[] heroPos = {
  40, 105
};
PImage enemy;
int[] enemyPos = {
  75, 75
};
int[] squareInt = new int[4];
boolean isInt = false;
boolean drawInt = false;

void setup() {
  size(200, 200);
  hero = loadImage("megaManX.gif");
  enemy = loadImage("sparkMandrill.gif");
  hero.loadPixels();
  enemy.loadPixels();
}

void draw() {
  if (isInt) {
    background(255, 0, 0); // Background turns red if hero is hit
  } else {
    background(255);
  }

  image(enemy, enemyPos[0], enemyPos[1]);
  image(hero, heroPos[0], heroPos[1]);
  if (isInt & drawInt) {
    fill(255, 255, 0);
    rect(squareInt[0], squareInt[1], squareInt[2] - squareInt[0], squareInt[3] - squareInt[1]);
  }
}

void keyPressed() {
  if (keyCode == 38) {
    heroPos[1] -= 2;
  } else if (keyCode == 40) {
    heroPos[1] += 2;
  } else if (keyCode == 37) {
    heroPos[0] -= 2;
  } else if (keyCode == 39) {
    heroPos[0] += 2;
  }
  isInt = pixelCollision();
}

boolean pixelCollision() {
  boolean isColliding = false;

  int ax = heroPos[0];
  int ay = heroPos[1];
  int AX = heroPos[0] + hero.width;
  int AY = heroPos[1] + hero.height;

  int bx = enemyPos[0];
  int by = enemyPos[1];
  int BX = enemyPos[0] + enemy.width;
  int BY = enemyPos[1] + enemy.height;

  // Check to see if bounding boxes are overlapping
  boolean isCollidingAABB = ! ( (AX < bx) || (BX < ax) || (AY < by) || (BY < ay) );
  if (isCollidingAABB) {
    if (ax < bx) { 
      squareInt[0] = bx;
    } else { 
      squareInt[0] = ax;
    }

    if (ay < by) { 
      squareInt[1] = by;
    } else { 
      squareInt[1] = ay;
    }

    if (AX < BX) { 
      squareInt[2] = AX;
    } else { 
      squareInt[2] = BX;
    }

    if (AY < BY) { 
      squareInt[3] = AY;
    } else { 
      squareInt[3] = BY;
    }

    // Begin checking for pixel collision
    int[] intOrigin1 = {
      squareInt[0] - ax, squareInt[1] - ay
    };
    int[] intOrigin2 = {
      squareInt[0] - bx, squareInt[1] - by
    };
    int[] intSize = {
      squareInt[2] - squareInt[0], squareInt[3] - squareInt[1]
    };
    int resolution = 2; // Bigger values would be faster to check, but not as accurate
    for (int y = 0; y < intSize[1]; y = y + resolution) {
      for (int x = 0; x < intSize[0]; x = x + resolution) {
        int pixel1 = (intOrigin1[0] + x) + (intOrigin1[1] + y) * hero.width;
        float alpha1 = alpha(hero.pixels[pixel1]);
        if (alpha1 > 0) {
          int pixel2 = (intOrigin2[0] + x) + (intOrigin2[1] + y) * enemy.width;
          float alpha2 = alpha(enemy.pixels[pixel2]);
          if (alpha2 > 0) {
            isColliding = true; // If we find 2 non-alpha pixels that are overlapping, there's a collision
            break;
          }
        }
      }
    }
  }
  return isColliding;
}


