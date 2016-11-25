/*
Cloth mesh
Controls:
 - Left & right click to add wind force
 - Middle mouse click to increase gravity
 - Hold 'Q' to cut the cloth
 - Hold 'W' to paint areas to snap points
 - Hold 'E' to paint away areas to unsnap points
 - 'R' to reset the sim
 - 'T' to toggle between building triangulation
 - 'A' to increase timesteps
 - 'S' to decrease timesteps
 - 'Z' to decrease grid's resolution
 - 'X' to increase grid's resolution
 
 Author: Jason Labbe
 Site: jasonlabbe3d.com
 Script inspired by Keith Peters (youtube.com/watch?v=3HjO_RGIjCU)
*/


// Global variables
int Q_VALUE = 81;
int W_VALUE = 87;
int E_VALUE = 69;
int R_VALUE = 82;
int T_VALUE = 84;
int A_VALUE = 65;
int S_VALUE = 83;
int Z_VALUE = 90;
int X_VALUE = 88;

int TIMESTEPS_MAX = 50;
int TIMESTEPS_MIN = 1;
int GRID_RESOLUTION_MAX = 30;
int GRID_RESOLUTION_MIN = 4;

int pressedKey = -1;
int timesteps = 3;
int gridResolution = 11;
boolean doTriangulation = false;
ArrayList<Point> points = new ArrayList<Point>();
ArrayList<Segment> segments = new ArrayList<Segment>();


class Point {
  PVector oldPos = new PVector(0.0, 0.0, 0.0);
  PVector pos = new PVector(0.0, 0.0, 0.0);
  PVector forces = new PVector(0.0, 0.0, 0.0);
  boolean snap = false;
  boolean select = false; // Used for debugging to color selected verts
  float drawSize = 5.0;
  
  Point(float posX, float posY) {
    this.oldPos.set(posX, posY, 0.0);
    this.pos.set(posX, posY, 0.0);
  }
  
  void applyForce(PVector force)
  {
    this.forces.add(force);
  }
  
  void sim() {
    if (! this.snap) {
      // Add gravity
      PVector gravity = new PVector(0, 0.1, 0);
      this.applyForce(gravity);
          
      // Move point
      PVector velocity = this.pos.get();
      velocity.sub(this.oldPos);
      velocity.add(this.forces);
      float friction = 0.995;
      velocity.mult(friction);
      this.oldPos.set(this.pos);
      this.pos.add(velocity);
      this.forces.mult(0);
    }
  }
  
  // Limit position to window boundaries
  void collideToWindow() {
    float border = 10.0;
    
    float vx = this.pos.x - this.oldPos.x;
    float vy = this.pos.y - this.oldPos.y;
    
    if (this.pos.y > height - border) {
     // Bottom screen
     float bounce = 0.8;
     this.pos.y = height - border;
     this.oldPos.y = this.pos.y + vy * bounce;
    } else if (this.pos.y < 0 + border) {
     // Top screen
     this.pos.y = 0 + border;
     this.oldPos.y = this.pos.y + vy;
    }
    if (this.pos.x < 0 + border) {
     // Left screen
     this.pos.x = 0 + border;
     this.oldPos.x = this.pos.x + vx;
    } else if (this.pos.x > width - border) {
     // Right screen
     this.pos.x = width - border;
     this.oldPos.x = this.pos.x + vx;
    }    
  }
  
  void draw() {
    if (this.select) {
      fill(255, 0, 0);
    } else if (this.snap) {
      fill(0, 255, 0);
    } else {
      fill(0);
    }
    
    stroke(0);
    strokeWeight(0);
    ellipse(this.pos.x, this.pos.y, this.drawSize, this.drawSize);
  }
}


class Segment {
  Point point1;
  Point point2;
  float restLength = 0.0;
  
  Segment(Point input1, Point input2) {
    this.point1 = input1;
    this.point2 = input2;
    this.restLength = input1.pos.dist(input2.pos);
  }
  
  void sim() {
   float currentLength = this.point1.pos.dist(this.point2.pos);
   float lengthDifference = this.restLength - currentLength;
   float offsetPercent = lengthDifference / currentLength / 2.0;
   
   PVector direction = this.point2.pos.get();
   direction.sub(this.point1.pos);
   direction.mult(offsetPercent);
   
   if (! this.point1.snap) {
     this.point1.pos.sub(direction);
   }
   
   if (! this.point2.snap) {
     this.point2.pos.add(direction);
   }
  }
  
  void draw() {
    line(this.point1.pos.x, this.point1.pos.y, this.point2.pos.x, this.point2.pos.y);
  }
}


Point addPoint(float xPos, float yPos) {
  Point newPoint = new Point(xPos, yPos);
  points.add(newPoint);
  return newPoint;
}


Segment addSegment(Point point1, Point point2) {
  Segment newSegment = new Segment(point1, point2);
  segments.add(newSegment);
  return newSegment;
}


void setup() {
 size(600, 600);
 resetGrid(doTriangulation);
}

// Create grid
void resetGrid(boolean triangulation) {
 points.clear();
 segments.clear();
 
 float startX = 100.0;
 float startY = 50.0; 
 int gridSize = 400;
 int cellSize = gridSize / gridResolution;
 
 Point lastPoint = null;
 for (int y = 0; y < gridResolution; y++) {
   for (int x = 0; x < gridResolution; x++) {
     Point newPoint = addPoint(startX + (x * cellSize), startY + (y * cellSize) );
     
     if (y == 0) { // Snap points in first row
       if (x == 0 || x == gridResolution-1) {
         newPoint.snap = true;
       }
     } else { // Attach a segment on top
       addSegment(points.get(points.size()-gridResolution-1), newPoint);
       if (triangulation) {
         if (! ( (x+1) % gridResolution == 1) ) { // Add a segment for triangulation
           addSegment(points.get(points.size()-gridResolution-2), newPoint);
         }
       }
     }
     
     if (! ( (x+1) % gridResolution == 1) ) { // Attach a segment to the left
       addSegment(points.get(points.size()-2), newPoint);
     }
   }
 }
}


void draw() {
  background(200);
  
  // Sim grid
  for (Point pt : points) { pt.sim(); }
  
  for (int timestep = 0; timestep < timesteps; timestep++) {
    for (Segment segment : segments) { segment.sim(); }
    
    for (Point pt : points) { pt.collideToWindow(); }
  }
  
  // Draw grid
  for (Segment segment : segments) { segment.draw(); }
  
  for (Point pt : points) { pt.draw(); }
  
  fill(0);
  
  text("Timesteps: " + str(timesteps), 12, 20);
  text("Resolution: " + str(gridResolution), 12, 35);
  
  // User wind force
  if (mousePressed) {
    PVector wind = new PVector(0, 0, 0);
    if (mouseButton == LEFT) {
      wind.x = -0.1;
    } else if (mouseButton == RIGHT) {
      wind.x = 0.1;
    } else {
      wind.y = 0.5; 
    }
    for (Point pt : points) {
      pt.applyForce(wind); 
    }
  }
}


void keyPressed() {
  pressedKey = keyCode;
 if (keyCode == A_VALUE) {
   // Increase timesteps
   timesteps = min(TIMESTEPS_MAX, timesteps+1);
 } else if (keyCode == S_VALUE) {
   // Decrease timesteps
   timesteps = max(TIMESTEPS_MIN, timesteps-1);
 } else if (keyCode == R_VALUE) {
   // Reset sketch
   resetGrid(doTriangulation);
 } else if (keyCode == T_VALUE) {
   // Reset and toggle triangulation
   doTriangulation = ! doTriangulation;
   resetGrid(doTriangulation);
 } else if (keyCode == Z_VALUE) {
   // Increase grid resolution
   gridResolution = max(GRID_RESOLUTION_MIN, gridResolution-1);
   resetGrid(doTriangulation);
 } else if (keyCode == X_VALUE) {
   // Decrease grid resolution
   gridResolution = min(GRID_RESOLUTION_MAX, gridResolution+1);
   resetGrid(doTriangulation);   
 }
}


void keyReleased() {
  pressedKey = -1; // Reset variable
}


void mouseMoved() {
  if (! keyPressed) {
    return;
  }
  
  if (pressedKey != Q_VALUE && pressedKey != W_VALUE && pressedKey != E_VALUE) {
    return;
  }
  
  float distToBeat = 99999.0;
  float distThreshold = 15.0;
  int index = -1;
  PVector mousePos = new PVector(mouseX, mouseY, 0);
  
  if (pressedKey == Q_VALUE) {
    // Cut closest segment
    for (int i = 0; i < segments.size(); i++) {
      Segment segment = segments.get(i);
      PVector pos = segment.point1.pos.get();
      pos.add(segment.point2.pos);
      pos.div(2.0);
      float dist = mousePos.dist(pos);
      if (dist < distToBeat) {
        distToBeat = dist;
        index = i;
      }
    }
    if (index > -1 && distToBeat < distThreshold) {
      segments.remove(index);
    }
  } else if (pressedKey == W_VALUE || pressedKey == E_VALUE) {
    // Snap/unsnap closest point
    for (int i = 0; i < points.size(); i++) {
      Point pt = points.get(i);
      PVector pos = pt.pos.get();
      float dist = mousePos.dist(pos);
      if (dist < distToBeat) {
        distToBeat = dist;
        index = i;
      }
    }
    if (index > -1 && distToBeat < distThreshold) {
      if (pressedKey == W_VALUE) {
        points.get(index).snap = true;
      } else {
        points.get(index).snap = false;
      }
    }
  }
}