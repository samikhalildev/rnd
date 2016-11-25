/*
Infinity rainbow
 
Controls:
- Mouse's x position controls its count value
- Mouse's y position controls its size value
 
Author: Jason Labbe
Site: jasonlabbe3d.com
*/


int ballCount = 140;
float ballSize = 5;


void setup() {
  size(600, 600);
  background(255);
  noStroke();
}


void draw() {
  colorMode(RGB, 255);
  
  fill(255, 20);
  rect(0, 0, width, height);
  
  fill(255);
  rect(0, 0, width, 50);
  
  fill(0);
  text("Count: " + ballCount, 10, 20);
  text("Size:  " + int(ballSize), 10, 40);

  colorMode(HSB, 100);
  
  // Need to loop backwards so draw order is proper
  for (int i = ballCount; i > 0; i--) {
    fill(i/1.5, 200, 100);
    float posX = (width/2) + sin((frameCount-i)/20) * 200;
    float posY = (height/2) + sin((frameCount-i)/10) * 100;
    ellipse(posX, posY, ballSize+i/2, ballSize+i/2);
  }
}


void mouseMoved() {
  ballCount = int( map(mouseX, 0, width, 10, 140) );
  ballSize = map(mouseY, 0, height, 1, 100);
}

