 /* @pjs preload="kirby.png", "megaMan.png", "link.png"; */

/*
Pixel dust
 
Controls:
- Space bar to reset.
- z or x to change the target's size.
- a or s to change the image's resolution.

Author: Jason Labbe
Site: jasonlabbe3d.com
*/


// Global variables
ArrayList<Pixel> allPixels = new ArrayList<Pixel>();
int currentImageIndex = 0;
PVector lastMousePos = new PVector(0, 0);
float targetSize = 50;
int pixelStep = 2;


class Pixel {
  PVector pos = new PVector(0, 0);
  PVector vel = new PVector(0, 0);
  color pixelColor;
  float fallRate;
  boolean active = false;

  Pixel(int x, int y, color inputColor) {
    this.pos.set(x, y);
    this.pixelColor = inputColor;
    this.fallRate = random(0.1, 2);
  }

  void draw() {
    stroke(this.pixelColor);
    point(this.pos.x, this.pos.y);
  }
}


/*
Clears current pixels and loads in new image.
*/
void reset(int imageIndex) {
  background(20);
  allPixels.clear();

  PImage img = null;
  switch(imageIndex) {
  case 0:
    img = loadImage("kirby.png");
    break;
  case 1:
    img = loadImage("megaMan.png");
    break;
  case 2:
    img = loadImage("link.png");
    break;
  }
  img.loadPixels();

  int i = 0;
  for (int y = 0; y < img.height; y+=1) {
    for (int x = 0; x < img.width; x+=1) {
      color pixelColor = img.pixels[i];

      i += 1;

      if (alpha(pixelColor) == 0) { continue; }
      if (i % pixelStep > 0) { continue; }

      Pixel newPixel = new Pixel(x+(width-img.width)/2, y+(height-img.height)/2, pixelColor);
      allPixels.add(newPixel);
      newPixel.draw();
    }
  }
}


void drawTarget() {
  stroke(255, 0, 0, 100);
  ellipse(mouseX, mouseY, targetSize*2, targetSize*2);
}


void drawControlTips() {
  textAlign(CENTER);
  String tipsDisplay = "Press space bar to reset.\n";
  tipsDisplay += "Press z or x to change the size of your target.\n";
  tipsDisplay += "Press a or s to change the image's resolution.";
  text(tipsDisplay, width/2, 30);
}


void setup() {
  size(800, 800);
  noFill();
  rectMode(CENTER);
  reset(currentImageIndex);
}


void keyPressed() {
  if (keyCode == 90) { // z
    targetSize = min(targetSize+10, 170);
  } else if (keyCode == 88) { // x
    targetSize = max(targetSize-10, 10);
  } else if (keyCode == 32) { // Space
    currentImageIndex += 1;
    if (currentImageIndex > 2) { currentImageIndex = 0; }
    reset(currentImageIndex);
  } else if (keyCode == 83) { // s
    pixelStep = min(pixelStep+1, 5);
    reset(currentImageIndex);
  } else if (keyCode == 65) { // a
    pixelStep = max(pixelStep-1, 1);
    reset(currentImageIndex);
  }
}


void draw() {
  background(20);

  PVector mousePos = new PVector(mouseX, mouseY);
  
  for (Pixel pixel : allPixels) {
    if (dist(pixel.pos.x, pixel.pos.y, mousePos.x, mousePos.y) < targetSize) { 
      pixel.active = true;
      
      PVector newVel = mousePos.get();
      newVel.sub(lastMousePos);
      // Using PVector.mag() seems to crash in JavaScript mode
      // so will calculate magnitude manually.
      float mag = (float)Math.sqrt( (newVel.x * newVel.x)+(newVel.y * newVel.y) ) * 0.01;
      newVel.normalize();
      //newVel.setMag(random(mag*10, mag*15) ); // Better in Java mode
      newVel.setMag(random(mag*0.1, mag*0.5)); // Better in JavaScript mode
      pixel.vel.add(newVel);
    }

    pixel.draw();

    if (! pixel.active) { continue; }

    pixel.vel.add(0, pixel.fallRate, 0);
    pixel.pos.add(pixel.vel);
    pixel.fallRate += random(0.1, 0.5);

    if (pixel.pos.y > height) { pixel.active = false; }
  }
  
  lastMousePos.set(mouseX, mouseY);
  
  drawTarget();
  drawControlTips();
}

