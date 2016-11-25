/*
Vector soft selection
   
Controls:
- Move the mouse around.
- Hold 'a' to increase selection size.
- Hold 's' to decrease selection size.
   
Author: Jason Labbe
Site: jasonlabbe3d.com
*/


// Global variables
int pixelStep = 20;
int offsetX = 10;
int offsetY = 10;
float selectSize = 40;


void setup() {
  size(600, 600);
}


void keyPressed() {
  if (key == 'a') {
    selectSize = min( max(selectSize+1, 15), 60);
  } else if (key == 's') {
    selectSize = min( max(selectSize-1, 15), 60);
  }
}


void draw() {
  background(0);
  
  PVector mousePos = new PVector(mouseX, mouseY);
  
  for (int y = 0; y < height; y += pixelStep) {
    for (int x = 0; x < width; x += pixelStep) {
      PVector pos = new PVector(x+offsetX, y+offsetY);
      
      float distance = dist(pos.x, pos.y, mousePos.x, mousePos.y);
      
      // Point towards mouse cursor
      pos.sub(mousePos);
      pos.normalize();
      float mag = min( max(selectSize-distance*0.2, 0.1), 40);
      pos.mult(mag);
      pos.x += x+offsetX;
      pos.y += y+offsetY;
      
      // Draw point
      strokeWeight(1);
      stroke(0, 255, 100);
      point(x+offsetX, y+offsetY);
      
      // Draw line
      float weight = max(2.5-distance*0.01, 0.1);
      strokeWeight(weight);
      stroke(distance*0.8, 150, 0, 255);
      line(x+offsetX, y+offsetY, pos.x, pos.y);
    }
  }
}

