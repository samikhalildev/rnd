/* @pjs preload="wideMouth1.jpg", "wideMouth2.jpg", "wideMouth3.jpg";*/

/*
Wide mouth

Controls:
- a or s to change the image's resolution.

Author: Jason Labbe
Site: jasonlabbe3d.com
*/


int pixelStep = 6;
int currentImageIndex = 0;
ArrayList<Pixel> allPixels = new ArrayList<Pixel>();
ArrayList<PVector> repulseTargets = new ArrayList<PVector>();
PVector repulse;


class Pixel {
  PVector pos = new PVector(0, 0);
  PVector vel = new PVector(0, 0);
  color pixelColor;

  Pixel(int x, int y, color inputColor) {
    this.pos.set(x, y);
    this.pixelColor = inputColor;
  }

  void draw() {
    stroke(this.pixelColor);
    point(this.pos.x, this.pos.y);
    //fill(this.pixelColor);
    //ellipse(this.pos.x, this.pos.y, 2, 2);
  }
}


void setup() {
  size(500, 500);
  background(0);
  noFill();
  //noStroke();
  ellipseMode(CENTER);
  
  repulseTargets.add(new PVector(255, 325));
  repulseTargets.add(new PVector(251, 282));
  repulseTargets.add(new PVector(250, 283));
  
  reset(currentImageIndex);
}


void reset(int imageIndex) {
  repulse = repulseTargets.get(currentImageIndex);
  
  PImage img = null;
  switch(imageIndex) {
  case 0:
    img = loadImage("wideMouth1.jpg");
    break;
  case 1:
    img = loadImage("wideMouth2.jpg");
    break;
  case 2:
    img = loadImage("wideMouth3.jpg");
    break;
  }
  img.loadPixels();
  
  allPixels.clear();
  int i = 0;
  for (int y = 0; y < img.height; y+=1) {
    for (int x = 0; x < img.width; x+=1) {
      color pixelColor = img.pixels[i];

      i += 1;

      if (alpha(pixelColor) == 0) { continue; }
      if (i % pixelStep > 0) { continue; }

      Pixel newPixel = new Pixel(x+(width-img.width)/2, y+(height-img.height)/2, pixelColor);
      // Offset if it's the same coordinates as the repulse target (otherwise they won't get a velocity)
      if (newPixel.pos.x == repulse.x) { newPixel.pos.x += 1; }
      if (newPixel.pos.y == repulse.y) { newPixel.pos.y += 1; }
      allPixels.add(newPixel);
      newPixel.draw();
    }
  }
}


void draw() {
  background(0);
  
  int inBoundsCount = 0;
  
  for (Pixel pixel : allPixels) {
    PVector newVec = pixel.pos.get();
    newVec.sub(repulse);
    newVec.normalize();
    newVec.setMag(random(0.001, 2.0));
    newVec.x *= 1.5;
    pixel.vel.add(newVec);
    
    pixel.draw();
  
    pixel.pos.add(pixel.vel);
    
    if (pixel.pos.x > 0 && pixel.pos.x < width && pixel.pos.y > 0 && pixel.pos.y < height) {
      inBoundsCount += 1;
    }
  }
  
  // Go to next image if there are no more pixels inside the window
  if (inBoundsCount == 0) {
    currentImageIndex += 1;
    if (currentImageIndex > repulseTargets.size()-1) { currentImageIndex = 0; }
    reset(currentImageIndex);
  }
}


void keyPressed() {
  if (keyCode == 83) { // s
    pixelStep = min(pixelStep+1, 15);
    reset(currentImageIndex);
  } else if (keyCode == 65) { // a
    pixelStep = max(pixelStep-1, 1);
    reset(currentImageIndex);
  }
}

