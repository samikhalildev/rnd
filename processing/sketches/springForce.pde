/*
Spring force
 Controls:
 - Left & right click to add wind force
 - Middle mouse click to increase gravity
 - 'Q' to add a new spring
 - 'W' to remove last spring
 - 'A' to increase mass
 - 'S' to decrease mass
 - 'Z' to increase springs elasticity
 - 'X' to decrease springs elasticity
 
 Author: Jason Labbe
 Site: jasonlabbe3d.com
 Script inspired by Daniel Shiffman
 More info at shiffman.net
 */

// Global constants
int Q_VALUE = 81;
int W_VALUE = 87;
int A_VALUE = 65;
int S_VALUE = 83;
int Z_VALUE = 90;
int X_VALUE = 88;
int SPRING_LIMIT = 50;
float ELASTICITY_MIN = 0.001;
float ELASTICITY_MAX = 0.3;
float MASS_SCALAR = 20.0;

// Global variables
float forceMult = 0.0;
ArrayList<Ball> balls = new ArrayList<Ball>();
ArrayList<SpringConstraint> springs = new ArrayList<SpringConstraint>();

class Ball {
  PVector location = new PVector();
  PVector velocity = new PVector();
  PVector acceleration = new PVector();
  float mass = 1.0;  

  void applyForce(PVector force) {
    PVector forceCopy = force.get();
    forceCopy.div(this.mass);
    this.acceleration.add(forceCopy);
  }

  void sim() {
    // Add gravity
    PVector gravity = new PVector(0.0, 0.2, 0.0);
    gravity.mult(this.mass); // Cancels out mass, as gravity should have the effect regardless of mass
    this.applyForce(gravity);

    // Add air drag
    PVector drag = new PVector(this.velocity.x, this.velocity.y, 0.0);
    float dragMag = drag.mag();
    drag.normalize();
    drag.mult(-1);
    float drag_coefficient = 0.001;
    drag.mult( (drag_coefficient * dragMag * dragMag * this.mass) );
    this.applyForce(drag);

    // Add wind when using is holding down mouse button
    if (mousePressed) {
      PVector wind = new PVector(0.0, 0.0, 0.0);
      if (mouseButton == LEFT) {
        wind.x = -forceMult;
      }
      if (mouseButton == RIGHT) {
        wind.x = forceMult;
      }
      if (mouseButton == CENTER) {
        wind.y = forceMult;
      }
      this.applyForce(wind);
    } 

    // Move object
    this.velocity.add(this.acceleration);
    this.location.add(this.velocity);
    this.acceleration.mult(0.0); // Reset for next iteration

    // Respect window boundaries
    float objSize = this.mass * MASS_SCALAR;
    float objRadius = objSize / 2.0;
    if (this.location.y > height - objRadius) { // Bottom
      this.location.y = height - objRadius;
      this.velocity.y *= -1;
      // Apply friction on ground impact
      PVector friction = new PVector(this.velocity.x, this.velocity.y, 0.0);
      friction.normalize();
      friction.mult(-1);
      float frictionCoefficient = 0.1;
      friction.mult(frictionCoefficient);
      this.applyForce(friction);
    } else if (this.location.y < 0 + objRadius) { // Top
      this.location.y = 0 + objRadius;
      this.velocity.y *= -1;
    }
    if (this.location.x < 0 + objRadius) { // Left
      this.location.x = 0 + objRadius;
      this.velocity.x *= -1;
    } else if (this.location.x > width - objRadius) { // Right
      this.location.x = width - objRadius;
      this.velocity.x *= -1;
    }
  }

  void draw() {
    fill(255, 0, 0);
    strokeWeight(3);
    stroke(0);
    float ballSize = this.mass * MASS_SCALAR;
    ellipse(this.location.x, this.location.y, ballSize, ballSize);
  }
}

class SpringConstraint {
  PVector location = new PVector();
  PVector velocity = new PVector();
  PVector acceleration = new PVector();
  float mass = 1.0;  

  Ball target;
  float restLength;
  float elasticity = 0.1;

  SpringConstraint(Ball targetObj) {
    this.assignTarget(targetObj);
  }

  void assignTarget(Ball obj) {
    this.restLength = this.location.dist(obj.location) * 0.5; // Shorten length to get some pre-tension
    this.target = obj;
  }

  void sim() {
    PVector spring = new PVector(this.target.location.x, this.target.location.y, 0.0);
    spring.sub(this.location);
    float currentLength = this.location.dist(this.target.location);
    spring.normalize();
    float stretchLength = currentLength - this.restLength;
    spring.mult(-this.elasticity * stretchLength);
    this.target.applyForce(spring);
  }

  void draw() {
    float thickness = ( map(springs.get(0).elasticity, ELASTICITY_MIN, ELASTICITY_MAX, 0.1, 1.0) ) * 5.0; // The stronger the elasticity, the thicker the line
    strokeWeight(thickness);
    stroke(150);
    line(this.location.x, this.location.y, this.target.location.x, this.target.location.y);
  }
}

void setup() {
  size(600, 600);
  addBall(width / 2.0, 100.0);
  addSpring(width / 2.0, 0.0, balls.get(0) );
}

void draw() {
  // Force gets stronger the longer user holds down the button
  if (mousePressed) {
    forceMult += 0.25;
  } else {
    forceMult = 0;
  }

  // First sim objects
  for (SpringConstraint spring : springs) { 
    spring.sim();
  }
  for (Ball ball : balls) { 
    ball.sim();
  }

  // Now draw objects
  background(255);
  for (SpringConstraint spring : springs) {
    spring.draw();
  }
  for (Ball ball : balls) {
    ball.draw();
  }
}

void keyPressed() {
  if (keyCode == Q_VALUE) { // Add spring at mouse
    if (springs.size() < SPRING_LIMIT) {
      addSpring(mouseX, mouseY, balls.get(0) );
    }
  } else if (keyCode == W_VALUE) { // Remove last spring
    if (springs.size() > 0) {
      springs.remove(springs.size() - 1);
    }
  } else if (keyCode == A_VALUE) { // Increase mass
    for (Ball ball : balls) { 
      ball.mass = min(14, ball.mass + 1);
    }
  } else if (keyCode == S_VALUE) { // Decrease mass
    for (Ball ball : balls) { 
      ball.mass = max(1, ball.mass - 1);
    }
  } else if (keyCode == Z_VALUE) { // Increase elasticity
    for (SpringConstraint spring : springs) { 
      spring.elasticity = min(ELASTICITY_MAX, spring.elasticity + 0.01);
    }
  } else if (keyCode == X_VALUE) { // Decrease elasticity
    for (SpringConstraint spring : springs) { 
      spring.elasticity = max(ELASTICITY_MIN, spring.elasticity - 0.01);
    }
  }
}

void addBall(float x, float y) {
  Ball newBall = new Ball();
  newBall.location.set(x, y, 0.0);
  newBall.mass = 5.0;
  balls.add(newBall);
}

void addSpring(float x, float y, Ball ball) {
  SpringConstraint newSpring = new SpringConstraint(ball);
  newSpring.location.set(x, y, 0.0);
  springs.add(newSpring);
}


