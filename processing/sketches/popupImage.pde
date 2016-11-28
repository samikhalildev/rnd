/* @pjs preload="singapore.jpg", "up.jpg", "mochi.jpg"; */

/*
Pop up image

Controls:
  - Mouse click to invert depth and change colors.
  - Any key to switch to next image.

Author:
  Jason Labbe

Site:
  jasonlabbe3d.com
*/

String[] imgNames = {"singapore.jpg", "up.jpg", "mochi.jpg"};
PImage img;
int imgIndex = 0;

float camRotx = 0;
float camRoty = 0;

color color1 = color(255);
color color2 = color(0, 0, 50);
color colorTarget = color2;

float maxDepth = 50;
float depth = maxDepth;
float depthTarget = maxDepth;

int pixelSteps = 2;


void nextImage() {
  img = loadImage(imgNames[imgIndex]);
  //float scaleValue = 0.6;
  //img.resize(int(img.width*scaleValue), int(img.height*scaleValue));
  img.loadPixels();
  
  imgIndex += 1;
  
  if (imgIndex >= imgNames.length) {
    imgIndex = 0;
  }
}


void setup() {
  size(800, 800, P3D);
  
  smooth();
  
  nextImage();
}


void draw() {
  background(255);
  
  translate(width/2, height/2);
  
  rotateX(camRotx);
  rotateY(camRoty);
  
  int i = 0;
  
  for (int y = 0; y < img.height; y+=1) {
    for (int x = 0; x < img.width; x+=1) {
      if (i % pixelSteps == 0) {
        color pixelColor = img.pixels[i];
        
        float brightValue = brightness(pixelColor);
        
        float z = map(brightValue, 0, 255, depth, maxDepth-depth);
        
        color pointColor = lerpColor(color1, color2, z/maxDepth);
        
        stroke(pointColor);
        strokeWeight(map(z, 0, maxDepth, 1, 3));
        
        point(x-img.width/2, y-img.height/2, z);
      }
      
      i += 1;
    }
  }
  
  depth = lerp(depth, depthTarget, 0.1);
  color2 = lerpColor(color2, colorTarget, 0.1);
}


void mouseMoved() {
  camRotx = map(mouseY, 0, height, radians(180), radians(-180));
  camRoty = map(mouseX, 0, width, radians(-180), radians(180));
}


void mousePressed() {
  if (depthTarget == 0) {
    depthTarget = maxDepth;
  } else {
    depthTarget = 0;
  }
  
  colorTarget = color(random(255), random(255), random(255));
}


void keyPressed() {
  nextImage();
}
