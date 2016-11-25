/*
Psychedelic golden ratio

Credits:
  Daniel Shiffman's awesome explanation on the golden ratio (https://www.youtube.com/watch?v=KWoJgHFYWxY)
  
Controls:
- Drag mouse to rotate camera.
  
Author: Jason Labbe
Site: jasonlabbe3d.com
*/


int maxCount = 500;
int num = 0;
float spacing = 4;
float z = 0;
float goldenAngle = 137.5;
ArrayList<PVector> positions = new ArrayList<PVector>();

float camRotx = 0;
float camRoty = 0;


void setup() {
  size(600, 600, P3D);
  colorMode(HSB, 255);
  smooth(1);
}


void draw() {
  background(15);
  
  if (num < maxCount) {
    float angle = num * goldenAngle;
    float r = spacing * sqrt(num);
    float x = r * cos(angle);
    float y = r * sin(angle);
    
    positions.add(new PVector(x, y, z));
    
    num += 1;
    z += 0.5;
    goldenAngle += 0.00002;
  }
  
  color startColor = color(200+sin(frameCount*0.05)*25, 250, 255);
  color endColor = color(200+cos(frameCount*0.05)*25, 250, 255);
  
  translate(width/2, height/2, 50);
  rotateX(camRotx);
  rotateY(camRoty);
  
  for (int i = 0; i < positions.size(); i++) {
    float perc = map(i, 0, positions.size(), 0.0, 1.0);
    
    float thickness = lerp(1, 14, perc);
    strokeWeight(thickness);
    
    color pointColor = lerpColor(startColor, endColor, perc);
    stroke(pointColor);
    
    pushMatrix();
    
    float mult = lerp(0.5, 0.6, perc);
    rotateZ(frameCount*mult);
    
    PVector pos = positions.get(i);
    point(pos.x, pos.y, pos.z);
    
    popMatrix();
  }
}


void mouseDragged() {
  camRotx = -(mouseY-height/2)/160.0;
  camRoty = (mouseX-width/2)/220.0;
}
