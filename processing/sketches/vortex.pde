/*
Vortex

Credits:
  Daniel Shiffman's awesome explanation on the golden ratio (https://www.youtube.com/watch?v=KWoJgHFYWxY)
  
Author: 
	Jason Labbe

Site: 
	jasonlabbe3d.com
*/


int maxCount = 700;
float spacing = 10;
float z = 0;
float goldenAngle = 137.4;
ArrayList<PVector> positions = new ArrayList<PVector>();

float camRotx = 0;
float camRoty = 0;


void setup() {
  fullScreen();
  
  colorMode(HSB, 255);
  
  smooth(1);
  
  // Create points.
  for (int num = 0; num < maxCount; num++) {
    float angle = num * goldenAngle;
    float r = spacing * sqrt(num);
    float x = r * cos(angle);
    float y = r * sin(angle);
    
    positions.add(new PVector(x, y, z));
    
    z += 0.5;
    goldenAngle += 0.00002;
    spacing += 0.01;
  }
}


void draw() {
  background(15);
  
  color startColor = color(max(0, 200+sin(frameCount*0.05)*25), 235, 255);
  color endColor = color(max(0, 200+cos(frameCount*0.05)*25), 255, 255);
  
  translate(width/2, height/2, 50);
  
  for (int i = 0; i < positions.size(); i++) {
    float perc = map(i, 0, positions.size(), 0.0, 1.0);
    
    strokeWeight(lerp(0, 1, perc));
    color pointColor = lerpColor(startColor, endColor, perc);
    stroke(pointColor);
    
    pushMatrix();
    
    float mult = lerp(0.1, 2, perc);
    rotate(radians(frameCount*mult));
    
    PVector pos = positions.get(i);
    PVector lastPos = pos;
    
    if (i > 0) {
      lastPos = positions.get(i-1);
    }
    
    line(pos.x, pos.y, lastPos.x, lastPos.y);
    
    if (i % 10 == 0) {
      strokeWeight(lerp(1, 10, perc));
      point(pos.x, pos.y, pos.z);
    }
    
    popMatrix();
  }
}
