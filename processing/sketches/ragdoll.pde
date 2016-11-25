/*
2D ragdoll
    
Controls:
- Click and drag any point from the ragdoll to move it.

Bugs:
- Fast velocities will break its original shape, making it unstable!
- Only points collide against repulsions (not segments).

Wishlist:
- Should have the ability to limit rotation range for a segment.
- A more flexible spine.

Author: Jason Labbe
Site: jasonlabbe3d.com
Script inspired by Keith Peters (youtube.com/watch?v=3HjO_RGIjCU)
*/


ArrayList<Point> points = new ArrayList<Point>();
ArrayList<Segment> segments = new ArrayList<Segment>();
ArrayList<Repulsion> repulsions = new ArrayList<Repulsion>();
Point pinnedObj = null;


class Point {
  PVector oldPos = new PVector(0.0, 0.0, 0.0);
  PVector pos = new PVector(0.0, 0.0, 0.0);
  PVector forces = new PVector(0.0, 0.0, 0.0);
  boolean snap = false;
  float displaySize = 6.0;
  color fillColor = color(0);
  
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
      float friction = 0.99;
      velocity.mult(friction);
      this.oldPos.set(this.pos);
      this.pos.add(velocity);
      this.forces.mult(0);
    } else {
      // Need to update old position otherwise it would pop once snap is released
      this.oldPos.set(this.pos);
    }
  }
  
  // Limit position to window boundaries
  void collideToWindow() {
    float border = 10;
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
  
  // Collide against repulsion bodies
  void collideToRepulsions() {
     for (Repulsion rep : repulsions) {
       float intersection = dist(this.pos.x, this.pos.y, rep.pos.x, rep.pos.y);
       if (intersection < rep.displaySize/2) {
         PVector collisionPos = new PVector(rep.pos.x, rep.pos.y);
         collisionPos.sub(this.pos);
         collisionPos.normalize();
         this.pos.sub(collisionPos);
         break;
       }
     }
  }
  
  void draw() {
    noStroke();
    fill(this.fillColor);
    ellipse(this.pos.x, this.pos.y, this.displaySize, this.displaySize);
  }
}


class Segment {
  Point point1;
  Point point2;
  float restLength = 0.0;
  boolean visible = true;
  color strokeColor = color(0);
  
  Segment(Point inputPoint1, Point inputPoint2) {
    this.point1 = inputPoint1;
    this.point2 = inputPoint2;
    this.restLength = inputPoint1.pos.dist(inputPoint2.pos);
  }
  
  // Attempt to reposition points to its original rest length
  void sim() {
   float currentLength = this.point1.pos.dist(this.point2.pos);
   float lengthDifference = this.restLength - currentLength;
   float offsetPercent = lengthDifference / currentLength / 2.0;
   
   PVector direction = this.point2.pos.get();
   direction.sub(this.point1.pos);
   direction.mult(offsetPercent);
   
   if (! this.point1.snap) { this.point1.pos.sub(direction); }
   if (! this.point2.snap) { this.point2.pos.add(direction); }
  }
  
  void draw() {
    if (this.visible) {
      stroke(this.strokeColor);
      strokeWeight(2);
      line(this.point1.pos.x, this.point1.pos.y, this.point2.pos.x, this.point2.pos.y);
    }
  }
}


class Repulsion {
  PVector pos = new PVector(0, 0);
  float displaySize = 0;
  color fillColor = color(200, 200);
  
  Repulsion(float posX, float posY, float inputSize) {
    this.pos.set(posX, posY);
    this.displaySize = inputSize;
  }
  
  void draw() {
    fill(this.fillColor);
    ellipse(this.pos.x, this.pos.y, this.displaySize, this.displaySize);
  }
}


Point addPoint(float posX, float posY, color fillColor) {
  Point newPoint = new Point(posX, posY);
  newPoint.fillColor = fillColor;
  points.add(newPoint);
  return newPoint;
}


Segment addSegment(Point point1, Point point2, boolean isVisible, color strokeColor) {
  Segment newSegment = new Segment(point1, point2);
  newSegment.visible = isVisible;
  newSegment.strokeColor = strokeColor;
  segments.add(newSegment);
  return newSegment;
}


Repulsion addRepulsion(float posX, float posY, float displaySize) {
  Repulsion newRepulsion = new Repulsion(posX, posY, displaySize);
  repulsions.add(newRepulsion);
  return newRepulsion;
}


void setup() {
  size(500, 500);
  
  // Create bipedal ragdoll
  // Some segments are hidden. I found these ones helped make it more stable.
  Point body1 = addPoint(width/2-10, height/2, color(0, 50, 100));
  Point body2 = addPoint(width/2+10, height/2, color(0, 50, 100));
  Point body3 = addPoint(width/2-10, height/2+40, color(200, 200, 0));
  Point body4 = addPoint(width/2+10, height/2+40, color(200, 200, 0));
  addSegment(body1, body2, true, color(0, 50, 100));
  addSegment(body1, body3, true, color(200, 200, 0));
  addSegment(body2, body4, true, color(200, 200, 0));
  addSegment(body3, body4, true, color(200, 200, 0));
  addSegment(body1, body4, false, color(0));
  addSegment(body2, body3, false, color(0));
  
  Point hips1 = addPoint(width/2-10, height/2+55, color(200, 100, 0));
  Point hips2 = addPoint(width/2+10, height/2+55, color(200, 100, 0));
  addSegment(body3, hips1, true, color(200, 100, 0));
  addSegment(body4, hips2, true, color(200, 100, 0));
  addSegment(hips1, hips2, true, color(200, 100, 0));
  addSegment(body3, hips2, false, color(0));
  
  Point head1 = addPoint(width/2-10, height/2-30, color(0, 50, 100));
  Point head2 = addPoint(width/2+10, height/2-30, color(0, 50, 100));
  addSegment(head1, head2, true, color(0, 50, 100));
  addSegment(body1, head1, true, color(0, 50, 100));
  addSegment(body2, head2, true, color(0, 50, 100));
  addSegment(body2, head1, false, color(0));
  
  Point leftArm = addPoint(width/2-20, height/2, color(0, 100, 0));
  Point leftElbow = addPoint(width/2-45, height/2+5, color(0, 100, 0));
  Point leftHand = addPoint(width/2-70, height/2+20, color(0, 100, 0));
  Point leftHandTip = addPoint(width/2-80, height/2+30, color(0, 100, 0));
  
  addSegment(body1, leftArm, true, color(0, 100, 0));
  addSegment(body3, leftArm, false, color(0));
  addSegment(leftArm, leftElbow, true, color(0, 100, 0));
  addSegment(leftElbow, leftHand, true, color(0, 100, 0));
  addSegment(leftHand, leftHandTip, true, color(0, 100, 0));
  
  Point rightArm = addPoint(width/2+20, height/2, color(100, 0, 0));
  Point rightElbow = addPoint(width/2+45, height/2+5, color(100, 0, 0));
  Point rightHand = addPoint(width/2+70, height/2+20, color(100, 0, 0));
  Point rightHandTip = addPoint(width/2+80, height/2+30, color(100, 0, 0));
  addSegment(body2, rightArm, true, color(100, 0, 0));
  addSegment(body4, rightArm, false, color(0));
  addSegment(rightArm, rightElbow, true, color(100, 0, 0));
  addSegment(rightElbow, rightHand, true, color(100, 0, 0));
  addSegment(rightHand, rightHandTip, true, color(100, 0, 0));
  
  Point leftLeg = addPoint(width/2-20, height/2+50, color(0, 100, 0));
  Point leftKnee = addPoint(width/2-25, height/2+90, color(0, 100, 0));
  Point leftFoot = addPoint(width/2-20, height/2+130, color(0, 100, 0));
  Point leftFootTip = addPoint(width/2-25, height/2+140, color(0, 100, 0));
  addSegment(body4, leftLeg, false, color(0));
  addSegment(body3, leftLeg, true, color(0, 100, 0));
  addSegment(hips1, leftLeg, true, color(0, 100, 0));
  addSegment(leftLeg, leftKnee, true, color(0, 100, 0));
  addSegment(leftKnee, leftFoot, true, color(0, 100, 0));
  addSegment(leftFoot, leftFootTip, true, color(0, 100, 0));
  addSegment(leftLeg, leftFoot, false, color(0));
  
  Point rightLeg = addPoint(width/2+20, height/2+50, color(100, 0, 0));
  Point rightKnee = addPoint(width/2+25, height/2+90, color(100, 0, 0));
  Point rightFoot = addPoint(width/2+20, height/2+130, color(100, 0, 0));
  Point rightFootTip = addPoint(width/2+25, height/2+140, color(100, 0, 0));
  addSegment(body3, rightLeg, false, color(0));
  addSegment(body4, rightLeg, true, color(100, 0, 0));
  addSegment(hips2, rightLeg, true, color(100, 0, 0));
  addSegment(rightLeg, rightKnee, true, color(100, 0, 0));
  addSegment(rightKnee, rightFoot, true, color(100, 0, 0));
  addSegment(rightFoot, rightFootTip, true, color(100, 0, 0));
  addSegment(rightLeg, rightFoot, false, color(0));
  
  // Add collision objects
  addRepulsion(140, 200, 120);
  addRepulsion(430, 150, 50);
  addRepulsion(350, 240, 60);
  addRepulsion(420, 330, 50);
  
  // Just to give it some initial spin
  body1.oldPos.x += 20;
}


void draw() {
  // Set background and motion blur
  fill(255, 150);
  rect(0, 0, width*2, height*2);
  
  // Sim ragdoll
  for (Point pt : points) { pt.sim(); }
  
  for (int timestep = 0; timestep < 6; timestep++) {
    for (Segment segment : segments) { segment.sim(); }
    
    for (Point pt : points) { 
      pt.collideToWindow(); 
      pt.collideToRepulsions(); 
    }
  }
  
  // Display ragdoll and collisions
  for (Segment segment : segments) { segment.draw(); }
  for (Point pt : points) { pt.draw(); }
  for (Repulsion rep : repulsions) { rep.draw(); }
  
  // Display text
  fill(255, 0, 0);
  textAlign(CENTER);
  text("Pick me up and drag me around with the left-mouse button!", width/2, 20);
  
  // Move collision object
  repulsions.get(0).pos.x = 140+sin(frameCount*0.02)*60;
}


// Get object to pin
void mousePressed() {
  for (Point pt : points) {
    if (dist(pt.pos.x, pt.pos.y, mouseX, mouseY) < 10) {
      pinnedObj = pt;
      pt.snap = true;
      break;
    }
  }
}


// Release object from pinning
void mouseReleased() {
  if (pinnedObj != null) {
    pinnedObj.snap = false;
    pinnedObj = null;
  }
}


// Move pinned object
void mouseDragged() {
  if (pinnedObj != null) {
    pinnedObj.pos.x = mouseX;
    pinnedObj.pos.y = mouseY;
  }
}

