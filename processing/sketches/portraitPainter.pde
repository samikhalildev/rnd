/* @pjs preload="singapore.jpg", "up.jpg", "mochi.jpg"; */

PImage img;
int pixelSteps = 20;

void drawCurve(float curveLength, color strokeColor, int weightValue) {
  noFill();
  
  float a = random(-curveLength, curveLength);
  float b = random(-curveLength, curveLength);
  
  stroke(strokeColor);
  strokeWeight(weightValue);
  float stepLength = curveLength/4.0;
  curve(a, -stepLength*2, 0, -stepLength*1, 0, stepLength*1, b, stepLength*2);
  
  float v = 50;
  color newColor = color(red(strokeColor)-v, green(strokeColor)-v, blue(strokeColor)-v, 100);
  stroke(newColor);
  strokeWeight(1);
  int z = 1;
  
  for (int x = weightValue; x > 0; x --) {
    curve(a, -stepLength*2, -z, -stepLength*1, -z, stepLength*1, b, stepLength*2);
    curve(a, -stepLength*2, z, -stepLength*1, z, stepLength*1, b, stepLength*2);
    z += 2;
  }
}

void setup() {
  size(800, 500);
  
  background(255);
  
  img = loadImage("mochi.jpg");
  img.loadPixels();
}

void draw() {
  translate(width/2, height/2);
  
  int i = 0;
  
  for (int y = 0; y < img.height; y+=1) {
    for (int x = 0; x < img.width; x+=1) {
      int p = (int)random(10000);
      
      if (p < 1) {
      //if (i % pixelSteps == 0) {
        color pixelColor = img.pixels[i];
        
        //float brightValue = brightness(pixelColor);
        
        pushMatrix();
        translate(x-img.width/2, y-img.height/2);
        rotate(radians(random(-90, 90)));
        drawCurve(random(1, 100), pixelColor, (int)random(1, 10));
        
        popMatrix();
      }
      
      i += 1;
    }
  }
}
