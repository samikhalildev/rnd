/*
Particle twister

Controls:
  - Move mouse along y to flatten it.
  - Mouse click to reset.

Author:
  Jason Labbe

Site:
  jasonlabbe3d.com
*/

int rowCount = 100;
int particleCount = 25;
float spacing = 3;
float thickness = 2;
float speed = 0.03;


void setup() {
  size(700, 700, P3D);
  colorMode(HSB);
  smooth();
}


void draw() {
  background(0);
  
  strokeWeight(2);
  
  translate(width/2, height);
  
  // Flatten when mouse is down
  rotateX(map(spacing, 0, 3, radians(45), 0));
  translate(0, map(spacing, 0, 5, -height/2, 0));
  
  for (int i = 0; i < rowCount; i++) {
    stroke(map(i, 0, rowCount, 100, 200), 255, 255);
    
    pushMatrix();
    
    translate(0, -i*spacing);
    rotateY(radians(frameCount*i*speed));
    
    for (int x = 0; x < particleCount; x++) {
      pushMatrix();
      
      PVector pos = PVector.fromAngle(radians((360.0/i)*x));
      pos.mult(i*thickness*map(spacing, 0, 3, 2, 1));
      translate(pos.x, 0, pos.y);
      point(0, 0, 0);
      
      popMatrix();
    }
    
    popMatrix();
  }
}


void mouseMoved() {
  spacing = map(mouseY, 0, height, 3, 0);
}


void mousePressed() {
  frameCount = 0;
}
