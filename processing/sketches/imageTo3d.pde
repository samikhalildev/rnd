/* @pjs preload="jensen.jpg"; */

PImage img;
float rotx = 0;
float roty = 0;


void setup() {
  size(800, 800, P3D);
  
  smooth();
  
  imageMode(CENTER);
  
  img = loadImage("jensen.jpg");
  img.loadPixels();
}

color color1 = color(255);
color color2 = color(0, 0, 50);
float maxDepth = 50;

void draw() {
  background(255);
  
  translate(width/2, height/2);
  
  rotateY(radians(frameCount*0.5));
  //rotateX(rotx);
  //rotateY(roty);
  
  int i = 0;
  
  for (int y = 0; y < img.height; y+=1) {
    for (int x = 0; x < img.width; x+=1) {
      if (i % 2 == 0) {
        color pixelColor = img.pixels[i];
        
        float brightValue = brightness(pixelColor);
        
        float z = map(brightValue, 0, 255, maxDepth, 0);
        
        color pointColor = lerpColor(color1, color2, z/maxDepth);
        
        stroke(pointColor);
        strokeWeight(map(z, 0, maxDepth, 1, 3));
        
        point(x-img.width/2, y-img.height/2, z);
        
        color reflectionColor = color(red(pointColor), green(pointColor), blue(pointColor), map(y, 0, img.height, 0, 50));
        stroke(reflectionColor);
        point(x-img.width/2, -y+img.height/2+img.height, z);
      }
      
      i += 1;
    }
  }
}

void mouseMoved() {
  maxDepth = map(mouseX, 0, width, 0, 100);
  //rotx = map(mouseY, 0, height, radians(180), radians(-180));
  //roty = map(mouseX, 0, width, radians(-180), radians(180));
}
