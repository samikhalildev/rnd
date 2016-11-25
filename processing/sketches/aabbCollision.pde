/*
AABB collision detection
 The square follows the mouse around. If it intersects the other square, a yellow portion is drawn to show the intersection.
 
 Author: Jason Labbe
 Site: jasonlabbe3d.com
 */

int[] square1 = new int[2];
int[] square2 = new int[2];
int[] squareInt = new int[4];
boolean isInt = false;
int size1 = 100;
int size2 = 100;

void setup() {
  size(400, 400);
  square2[0] = width / 2;
  square2[1] = height / 2;
}

void draw() {
  background(75, 75, 100);
  strokeWeight(1);
  fill(200);
  rect(square2[0], square2[1], size1, size1);
  fill(255);
  rect(square1[0], square1[1], size2, size2);
  if (isInt) {
    fill(255, 255, 0);
    strokeWeight(3);
    rect(squareInt[0], squareInt[1], squareInt[2] - squareInt[0], squareInt[3] - squareInt[1]);
  }
}

void mouseMoved() {
  square1[0] = mouseX;
  square1[1] = mouseY;
  isInt = aabbCollision();
}

boolean aabbCollision() {
  int ax = square1[0];
  int ay = square1[1];
  int AX = square1[0] + size1;
  int AY = square1[1] + size1;

  int bx = square2[0];
  int by = square2[1];
  int BX = square2[0] + size2;
  int BY = square2[1] + size2;

  // Check to see if bounding boxes are overlapping
  boolean isColliding = ! ( (AX < bx) || (BX < ax) || (AY < by) || (BY < ay) );
  if (isColliding) {
    // Save these coordinates so the intersection can be drawn in draw()
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
  }
  return isColliding;
}


