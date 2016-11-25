/*
Orange Wave 3d
  
Controls:
- Move mouse around to rotate camera.
- Hold left-click and drag to zoom in & out.
- Hold right-click and drag to change frequency along x axis, and amplitude on y axis.
  
Author: Jason Labbe
Site: jasonlabbe3d.com
*/


// Global variables
float freq = 10;
float amp = 50;
 
float rotx = -0.25;
float roty = 0.5;
float zoom = 0;
 
int widthCount = 25;
int heightCount = 16;
int depthCount = 20;
float widthOffset = (widthCount*10)/2;
 
 
void setup() {
  size(640, 450, P3D);
  background(0);
  rectMode(CENTER);
  noFill();
  textSize(11);
  textAlign(CENTER);
  smooth(1);
}
 
 
void mouseMoved() {
  rotx = -(mouseY-height/2)/160.0;
  roty = (mouseX-width/2)/220.0;
}
 
 
void mouseDragged() {
  if(mouseButton == LEFT || mouseButton == CENTER) {
    zoom = mouseX-width/2;
  } else if (mouseButton == RIGHT) {
    freq = 10 * (1.0-mouseX/(float)width+1);
    amp = 50 * (1.0-mouseY/(float)height+1);
  }
}
 
 
void draw() {
  background(0);
   
  pushMatrix();
  translate(width/2, height/2, zoom);
  rotateX(rotx);
  rotateY(roty);
   
  for (int z = 0; z < depthCount; z++) {
    translate(0, 0, z*0.5);
     
    for (int x = 0; x < widthCount; x++) {
      strokeWeight(5);
      stroke(255, 200, 100, 200);
       
      // Middle orange
      point(widthOffset-x*10, sin((frameCount+x*3)/freq)*(amp*1));
       
      for (int y = 1; y < heightCount/2; y++) {
        float rectSize = 5-y*0.5;
        stroke(255, 150-(y*30), 0, 80-(y*10));
        strokeWeight(rectSize*2);
        
        // Top orange
        point(widthOffset-x*10, -(y*10)+sin((frameCount+x*3)/freq)*(amp*(1-(y*0.13))));
         
        // Bottom orange
        point(widthOffset-x*10, (y*10)+sin((frameCount+x*3)/freq)*(amp*(1-(y*0.13))));
         
        stroke(50, 50, 255-(y*20), 20-(y*3));
        strokeWeight(rectSize*2);
        
        // Top blue
        point(widthOffset-x*10, -(y*12)+cos((frameCount+x*3)/freq)*(amp*(1-(y*0.13))));
         
        // Bottom blue
        point(widthOffset-x*10, (y*12)+cos((frameCount+x*3)/freq)*(amp*(1-(y*0.13))));
      }
    }
  }
   
  popMatrix();
   
  stroke(255);
  text("Move mouse=Rotate camera  ||  Drag L-click=Zoom  ||  Drag R-click=Freq along x & amp along y", width/2, height-30);
}


