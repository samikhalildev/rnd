/* @pjs preload="singapore.jpg", "up.jpg", "mochi.jpg"; */

PImage img;
int pixelSteps = 20;

void drawCurve(float curveLength, color strokeColor, int weightValue) {
  float stepLength = curveLength/4.0;
  
  float a = random(-curveLength, curveLength);
  float b = random(-curveLength, curveLength);
  
  noFill();
  stroke(strokeColor);
  strokeWeight(weightValue);
  curve(a, -stepLength*2, 0, -stepLength*1, 0, stepLength*1, b, stepLength*2);
  
  strokeWeight(1);
  int z = 1;
  
  for (int x = weightValue; x > 0; x --) {
    float v = random(10, 50);
    color newColor = color(red(strokeColor)-v, green(strokeColor)-v, blue(strokeColor)-v, 150);
    stroke(newColor);
    
    curve(a, -stepLength*2, z-weightValue/2, -stepLength*random(0.9, 1.1), z-weightValue/2, stepLength*random(0.9, 1.1), b, stepLength*2);
    z += 1;
  }
}

void setup() {
  size(900, 800);
  
  background(255);
  
  img = loadImage("white.jpg");
  img.loadPixels();
}

void draw() {
  if (frameCount > 600) {
    return;
  }
  
  translate(width/2, height/2);
  
  int i = 0;
  
  for (int y = 0; y < img.height; y+=1) {
    for (int x = 0; x < img.width; x+=1) {
      int p = (int)random(20000);
      
      if (p < 1) {
        color pixelColor = img.pixels[i];
        pixelColor = color(red(pixelColor), green(pixelColor), blue(pixelColor), 100);
        
        pushMatrix();
        translate(x-img.width/2, y-img.height/2);
        rotate(radians(random(-90, 90)));
        
        if (frameCount < 20) {
          // Big rough strokes
          drawCurve(random(150, 250), pixelColor, (int)random(20, 40));
        } else if (frameCount < 50) {
          // Thick strokes
          drawCurve(random(75, 125), pixelColor, (int)random(8, 12));
        } else if (frameCount < 300) {
          // Small strokes
          drawCurve(random(30, 60), pixelColor, (int)random(1, 4));
        } else if (frameCount < 350) {
          // Big dots
          drawCurve(random(5, 20), pixelColor, (int)random(5, 15));
        } else if (frameCount < 600) {
          // Small dots
          drawCurve(random(1, 10), pixelColor, (int)random(1, 7));
        }
        
        //drawCurve(max(10, (int)map(frameCount, 0, 300, 200, 10)), pixelColor, (int)map(frameCount, 0, 400, 10, 1));
        
        popMatrix();
      }
      
      i += 1;
    }
  }
}
