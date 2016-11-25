/*
Prague triangle

Tried to re-create the loading screen from Deus Ex: MD.

Author:
  Jason Labbe

Site:
  jasonlabbe3d.com
*/

float pieceWidth = 40;
float pieceHeight = 40;
float widthHalf = pieceWidth/2;
float heightHalf = pieceHeight/2;

float allScale = 3;
float innerScale = 0;
float timeScale = 0; // Cycles from 0.0 to 1.0

ArrayList<Triangle> pieces = new ArrayList<Triangle>();


class Triangle {

  PVector pos;
  boolean up;

  Triangle(float _x, float _y, boolean _up) {
    this.pos = new PVector(_x, _y);
    this.up = _up;
  }

  void show() {

    if (up) {
      triangle(-widthHalf, heightHalf, 0, -heightHalf, widthHalf, heightHalf);
    } else {
      triangle(-widthHalf, -heightHalf, 0, heightHalf, widthHalf, -heightHalf);
    }
  }
}


void addTriangle(float _x, float _y, boolean _up) {
  pieces.add(new Triangle(_x, _y, _up));
}


void setup() {
  size(300, 300);
  
  // Generates a big triangle made out of little triangles
  
  // 1st row
  addTriangle(-widthHalf*3, pieceHeight, true);
  addTriangle(-widthHalf*2, pieceHeight, false);
  addTriangle(-widthHalf, pieceHeight, true);
  addTriangle(0, pieceHeight, false);
  addTriangle(widthHalf, pieceHeight, true);
  addTriangle(widthHalf*2, pieceHeight, false);
  addTriangle(widthHalf*3, pieceHeight, true);

  // 2nd row
  addTriangle(-widthHalf*2, 0, true);
  addTriangle(-widthHalf, 0, false);
  addTriangle(widthHalf, 0, false);
  addTriangle(widthHalf*2, 0, true);

  // 3rd row
  addTriangle(-widthHalf, -pieceHeight, true);
  addTriangle(0, -pieceHeight, false);
  addTriangle(widthHalf, -pieceHeight, true);

  // 4th row
  addTriangle(0, -pieceHeight*2, true);
}


void draw() {
  background(0);
  
  translate(width/2, height/2);
  rotate(radians(frameCount*0.35));
  scale(0.4);

  pushMatrix();
  
  scale(allScale);
  allScale -= 0.01;
  if (allScale <= 1) {
    allScale = 3;
  }

  timeScale = constrain(map(allScale, 3, 1, 0, 1), 0, 1);

  for (int i = 0; i < pieces.size (); i++) {
    Triangle piece = pieces.get(i);

    pushMatrix();

    translate(piece.pos.x, piece.pos.y);
    
    // Draw individual white piece
    pushMatrix();
    
    float pieceScale = constrain(-0.05*i+timeScale*2, 0, 1);
    scale(pieceScale);
    
    strokeWeight(2); // Can see the shapes if it's too thin
    stroke(255, pieceScale*255);
    fill(255, pieceScale*255);
    piece.show();
    strokeWeight(1);
    
    popMatrix();
    
    // Draw black piece to mimic outline
    pushMatrix();
    
    float innerPieceScale = constrain(1.0-(-0.2*i+timeScale*4), 0, 1);
    scale(innerPieceScale);
    noStroke();
    fill(0);
    piece.show();
    
    popMatrix();

    popMatrix();
  }

  popMatrix();

  // Inner white
  pushMatrix();
  
  innerScale = map(timeScale, 0, 1, 1, 0);

  scale(innerScale);
  
  // Big hack so that it scales at the right pivot
  if (innerScale < 0.9) {
    translate(0, (0.9-innerScale)*25);
  }
  
  noStroke();
  fill(255);
  triangle(-widthHalf*4, heightHalf*3, 0, -heightHalf*5, widthHalf*4, heightHalf*3);
  
  popMatrix();

  // Inner black
  noStroke();
  fill(0);
  triangle(-widthHalf, heightHalf, 0, -heightHalf, widthHalf, heightHalf);
}
