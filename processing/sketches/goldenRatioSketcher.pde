/* @pjs preload="jensen.jpg", "snake.jpg", "denton.jpg"; */

/*
Golden ratio sketcher

Inspiration:
  Manoylov AC's sketch (https://www.openprocessing.org/sketch/158305)

Controls:
- Left-click to change image.
- Right-click to save an image.
- Press any key to change the drawing style.
 
Author: Jason Labbe
Site: jasonlabbe3d.com
*/


// Can play around with these variables
String[] imgNames = {"jensen.jpg", "snake.jpg", "denton.jpg"};
color backgroundColor = color(255);
float spacing = 3;
float goldenAngle = 137.5;
float minThickness = 1.0;
float maxThickness = 7.0;

int imgIndex = -1;
PImage img;
int num = 0;
int drawStyle = 0;
String tooltip;


// Returns -1 if it's outside the image's dimensions.
int worldPosToPixelIndex(PVector worldPos) {
  int startX = width/2-img.width/2;
  int valX = (int)worldPos.x-startX;
  if (valX < 0 || valX > img.width-1) {
    return -1;
  }
  
  int startY = height/2-img.height/2;
  int valY = (int)worldPos.y-startY;
  if (valY < 0 || valY > img.height-1) {
    return -1;
  }
  
  return valX + (valY*img.width);
}


void reset() {
  num = 0;
  background(backgroundColor);
}


void nextImage() {
  imgIndex += 1;
  
  if (imgIndex > imgNames.length-1) {
    imgIndex = 0;
  }
  
  reset();
  
  img = loadImage(imgNames[imgIndex]);
  img.loadPixels();
}


void setup() {
  size(600, 600);
  
  rectMode(CENTER);
  imageMode(CENTER);
  
  frameRate(240);
  
  tooltip = "Left-click to change image.\n";
  tooltip += "Press any key to change the drawing style.\n";
  
  nextImage();
}


void draw() {
  float angle = num * goldenAngle;
  float r = spacing * sqrt(num);
  float x = r * cos(radians(angle)) + width/2;
  float y = r * sin(radians(angle)) + height/2;
  
  num += 1;
  
  int pixelIndex = worldPosToPixelIndex(new PVector(x, y));
  
  if (pixelIndex > -1) {
    color pixelColor = img.pixels[pixelIndex];
    
    // Darker colors will be thicker.
    // The further from origin, the larger max thickness can be to fill in the gaps.
    float pixelBrightness = brightness(pixelColor);
    float thickness = map(pixelBrightness, 0, 255, maxThickness+r*0.01, minThickness);
    
    switch(drawStyle) {
      case 0:
        stroke(pixelColor);
        strokeWeight(thickness);
        point(x, y);
        break;
      case 1:
        noStroke();
        fill(pixelColor);
        triangle(x, y, x+thickness*0.5, y-thickness, x+thickness, y);
        break;
      case 2:
        noStroke();
        fill(pixelColor);
        rect(x, y, thickness, thickness);
        break;
    }
  }
  
  noStroke();
  fill(backgroundColor);
  rect(0, height*2-50, width*2, height*2);
  
  fill(0);
  textAlign(CENTER);
  textSize(10);
  text(tooltip, width/2, height-30);
}


void mousePressed() {
  if (mouseButton == LEFT) {
    nextImage();
  } else if (mouseButton == RIGHT) {
    saveFrame("goldenRatioSketcher-###.png");
  }
}


void keyPressed() {
  reset();
  
  drawStyle += 1;
  if (drawStyle > 2) {
    drawStyle = 0;
  }
}
