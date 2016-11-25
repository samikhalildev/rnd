/*
Virus network 3d
 
Author: Jason Labbe
Site: jasonlabbe3d.com

To do:
  - Make it more likely to get virus nodes.
  - Clean up code.
*/


// Global variables
float depth = 600;

float widthOffset;
float heightOffset;
float depthOffset;

int bobCount = 60;
ArrayList<Bob> bobs = new ArrayList<Bob>();

ArrayList<Cube> cubes = new ArrayList<Cube>();
float cubeSize = 3;

PVector mouseClick = new PVector();

PVector posStart = new PVector();
PVector rotStart = new PVector();
float zoomStart = 0;

PVector cameraPos = new PVector();
PVector cameraRot = new PVector();
float cameraZoom = -700;


class Cube {
  
  boolean active = true;
  PVector center;
  int startFrame = 0;
  color color1 = color(255, 0);
  color color2 = color(255, 30);
  
  Cube(PVector _center, int _startFrame) {
    this.center = new PVector(_center.x, _center.y, _center.z);
    this.startFrame = _startFrame;
  }
  
  void display() {
    if (! active) {
      return;
    }
    
    if (frameCount > this.startFrame) {
      float blendValue = sin((frameCount-startFrame)*0.05);
      
      if (blendValue < 0) {
        this.active = false;
        return;
      }
      
      color currentColor = lerpColor(this.color1, this.color2, blendValue);
      
      noFill();
      stroke(currentColor);
      strokeWeight(3);
      
      pushMatrix();
      
      translate(this.center.x-widthOffset, this.center.y-heightOffset, this.center.z-depthOffset);
      
      box(cubeSize*2);
      
      popMatrix();
    }
  }
}


class Bob {
  
  PVector pos;
  PVector dir;
  float speed;
  
  Bob(float _x, float _y, float _z, float _speed) {
    this.pos = new PVector(_x, _y, _z);
    
    this.dir = PVector.random3D();
    this.dir.normalize();
    
    this.speed = _speed;
  }
  
  void move() {
    this.pos.x += this.dir.x*this.speed;
    this.pos.y += this.dir.y*this.speed;
    this.pos.z += this.dir.z*this.speed;
  }
  
  void keepInBounds() {
    if (this.pos.x < 0) {
      this.pos.x = 0;
      this.dir.x *= -1;
      createPattern(this.pos, new String[] {"y", "z"});
    } else if (this.pos.x > width) {
      this.pos.x = width;
      this.dir.x *= -1;
      createPattern(this.pos, new String[] {"y", "z"});
    }
    
    if (this.pos.y < 0) {
      this.pos.y = 0;
      this.dir.y *= -1;
      createPattern(this.pos, new String[] {"x", "z"});
    } else if (this.pos.y > height) {
      this.pos.y = height;
      this.dir.y *= -1;
      createPattern(this.pos, new String[] {"x", "z"});
    }
    
    if (this.pos.z < 0) {
      this.pos.z = 0;
      this.dir.z *= -1;
      createPattern(this.pos, new String[] {"x", "y"});
    } else if (this.pos.z > depth) {
      this.pos.z = depth;
      this.dir.z *= -1;
      createPattern(this.pos, new String[] {"x", "y"});
    }
  }
  
  // Get number of close enough bobs
  ArrayList<Bob> getNeighbors(float threshold) {
    ArrayList<Bob> proximityBobs = new ArrayList<Bob>();
    
    for (Bob otherBob : bobs) {
      if (this == otherBob) {
        continue;
      }
      
      float distance = dist(this.pos.x, this.pos.y, this.pos.z, otherBob.pos.x, otherBob.pos.y, otherBob.pos.z);
      if (distance < threshold) {
        proximityBobs.add(otherBob);
      }
    }
    
    return proximityBobs;
  }
  
  void draw() {
    ArrayList<Bob> proximityBobs = this.getNeighbors(100);
    
    if (proximityBobs.size() > 0) {
      float blendValue = constrain(map(proximityBobs.size(), 0, 6, 0.0, 1.0), 0.0, 1.0);
      color smallColor = color(0, 255, 255, 100);
      color bigColor = color(255, 0, 0, 100);
      color currentColor = lerpColor(smallColor, bigColor, blendValue);
      
      // Draw line
      stroke(currentColor);
      strokeWeight(proximityBobs.size()*0.25);
      
      for (Bob otherBob : proximityBobs) {
        line(this.pos.x-widthOffset, this.pos.y-heightOffset, this.pos.z-depthOffset, 
             otherBob.pos.x-widthOffset, otherBob.pos.y-heightOffset, otherBob.pos.z-depthOffset);
      }
      
      noStroke();
      fill(currentColor);
      pushMatrix();
      translate(this.pos.x-widthOffset, this.pos.y-heightOffset, this.pos.z-depthOffset);
      sphere(proximityBobs.size()*2);
      popMatrix();
      
      //strokeWeight(proximityBobs.size()*3);
      //point(this.pos.x-widthOffset, this.pos.y-heightOffset, this.pos.z-depthOffset);
    } else {
      // Draw bob
      stroke(255);
      strokeWeight(max(1, proximityBobs.size()));
      point(this.pos.x-widthOffset, this.pos.y-heightOffset, this.pos.z-depthOffset);
    }
    
    // Bobs with too many neighbours slow down, otherwise speed it up
    if (proximityBobs.size() > 2) {
      this.speed *= 0.98;
    } else {
      this.speed *= 1.01;
    }
    
    this.speed = max(0.25, min(this.speed, 6));
  }
}


void createPattern(PVector source, String[] axis) {
  PVector center = new PVector(source.x, source.y, source.z);
  
  int count = (int)random(2, 10);
  
  for (int x = 0; x < count; x++) {
    int delayOffset = frameCount+4*x;
    Cube newCube = new Cube(new PVector(center.x, center.y, center.z), delayOffset);
    cubes.add(newCube);
    
    String dir = axis[int(random(axis.length))];
    
    float val;
    if ((int)random(2) == 0) {
      val = cubeSize*2;
    } else {
      val = -cubeSize*2;
    }
    
    if (dir == "x") {
      center.x += val;
    } else if (dir == "y") {
      center.y += val;
    } else {
      center.z += val;
    }
  }
}


void setup() {
  size(600, 600, P3D);
  
  widthOffset = width/2;
  heightOffset = height/2;
  depthOffset = depth/2;
  
  for (int i = 0; i < bobCount; i++) {
    bobs.add(new Bob(random(0.0, width), random(0.0, height), random(0.0, depth), random(0.5, 2.0)));
  }
}


void draw() {
  background(0, 10, 15);
  
  pushMatrix();
  translate(width/2, height/2, depth/2);
  translate(cameraPos.x, cameraPos.y, cameraZoom);
  rotateY(radians(cameraRot.x));
  rotateX(radians(-cameraRot.y));
  
  for (Bob bob : bobs) {
    bob.move();
    bob.keepInBounds();
    bob.draw();
  }
  
  for (int x = 0; x < cubes.size(); x++) {
    Cube cube = cubes.get(x);
    cube.display();
  }
  
  popMatrix();
}


void mousePressed() {
  if (mouseButton == LEFT) {
    rotStart.set(cameraRot.x, cameraRot.y);
  } else if (mouseButton == CENTER) {
    posStart.set(cameraPos.x, cameraPos.y);
  } else {
    zoomStart = cameraZoom;
  }
  mouseClick.set(mouseX, mouseY);
}

void mouseDragged() {
  if (mouseButton == LEFT) {
    cameraRot.x = rotStart.x+(mouseX-mouseClick.x);
    cameraRot.y = rotStart.y+(mouseY-mouseClick.y);
  } else if (mouseButton == CENTER) {
    cameraPos.x = posStart.x+(mouseX-mouseClick.x);
    cameraPos.y = posStart.y+(mouseY-mouseClick.y);
  } else if (mouseButton == RIGHT) {
    cameraZoom = zoomStart+(mouseX-mouseClick.x)-(mouseY-mouseClick.y);
  }
}


void mouseScrolled() {
  float zoomValue = 50;
  
  if (mouseScroll > 0) {
    cameraZoom += zoomValue;
  } else {
    cameraZoom -= zoomValue;
  }
}
