/*
Node network
  
Controls:
- Mouse click to change hue.
- Press any key to toggle points.
  
Author: Jason Labbe
Site: jasonlabbe3d.com
*/
 
 
// Global variables
ArrayList<Bob> bobs = new ArrayList<Bob>();
int bobCount = 80;
float distThreshold = 100;
boolean doDrawPoints = false;
float hueBase = 0;
 
 
class Bob {
   
  PVector pos;
  PVector dir;
  float speed;
   
  Bob(float _x, float _y, float _angle, float _speed) {
    this.pos = new PVector(_x, _y);
     
    this.dir = new PVector(sin(radians(_angle)), cos(radians(_angle)));
    this.dir.normalize();
     
    this.speed = _speed;
  }
   
  void move() {
    this.pos.x += this.dir.x*this.speed;
    this.pos.y += this.dir.y*this.speed;
  }
   
  void keepInBounds() {
    if (this.pos.x < 0) {
      this.pos.x = 0;
      this.dir.x *= -1;
    } else if (this.pos.x > width) {
      this.pos.x = width;
      this.dir.x *= -1;
    }
     
    if (this.pos.y < 0) {
      this.pos.y = 0;
      this.dir.y *= -1;
    } else if (this.pos.y > height) {
      this.pos.y = height;
      this.dir.y *= -1;
    }
  }
   
  void drawPoint() {
    noStroke();
    fill(255, 200);
    ellipse(this.pos.x, this.pos.y, 5, 5);
  }
   
  void drawFill() {
    ArrayList<Bob> proximityBobs = new ArrayList<Bob>();
     
    for (Bob otherBob : bobs) {
      if (this == otherBob) {
        continue;
      }
       
      float distance = dist(this.pos.x, this.pos.y, otherBob.pos.x, otherBob.pos.y);
      if (distance < distThreshold) {
        proximityBobs.add(otherBob);
      }
    }
     
    if (proximityBobs.size() > 3) {
      noStroke();
      float hue = hueBase+(proximityBobs.size()-3)*4;
      fill(hue, 255, 255, 50);
       
      beginShape();
      vertex(this.pos.x, this.pos.y);
      for (Bob otherBob : proximityBobs) {
         vertex(otherBob.pos.x, otherBob.pos.y);
      }
      endShape();
    }
  }
}
 
 
void setup() {
  size(500, 500);
  background(0);
  colorMode(HSB, 255);
   
  for (int i = 0; i < bobCount; i++) {
    bobs.add(new Bob(random(0.0, width),
                     random(0.0, height),
                     random(0.0, 360.0),
                     random(0.5, 2.0)));
  }
}
 
 
void draw() {
  background(0);
   
  for (Bob bob : bobs) {
    bob.move();
    bob.keepInBounds();
    bob.drawFill();
     
    if (doDrawPoints) {
      bob.drawPoint();
    }
  }
}
 
 
void mousePressed() {
  hueBase = random(0.0, 200.0);
}
 
 
void keyPressed() {
  doDrawPoints = ! doDrawPoints;
}

