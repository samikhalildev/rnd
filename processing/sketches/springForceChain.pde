/*
Spring force chain
 Controls:
 - Left & right click to add wind force
 - Middle mouse click to increase gravity
 - 'Q' to increase springs elasticity
 - 'W' to decrease springs elasticity
 - 'A' to increase mass
 - 'S' to decrease mass
 
 Author: Jason Labbe
 Site: jasonlabbe3d.com
 Script inspired by Daniel Shiffman (shiffman.net)
 */


// Global variables
int Q_VALUE = 81;
int W_VALUE = 87;
int A_VALUE = 65;
int S_VALUE = 83;

int CURRENT_TIME = 0;
float MASS_DEFAULT = 2.0;
float MASS_SCALAR = 20.0;

float forceMult = 0.0;
ArrayList<Ball> balls = new ArrayList<Ball>();


class Ball {
  PVector location = new PVector();
  PVector velocity = new PVector();
  PVector acceleration = new PVector();
  float mass = MASS_DEFAULT;
  float elasticity = 0.01;
  ArrayList<Ball> springs = new ArrayList<Ball>();
  ArrayList<Float> restLengths = new ArrayList<Float>();
  boolean isStatic = false;

  void applyForce(PVector force) {
    PVector forceCopy = force.get();
    forceCopy.div(this.mass);
    this.acceleration.add(forceCopy);
  }

  void addSpringObject(Ball springObj) {
    float restLength = this.location.dist(springObj.location);
    this.springs.add(springObj);
    this.restLengths.add(restLength);
  }

  void sim() {
    if (isStatic) {
      return;
    }
    
    // Add gravity
    PVector gravity = new PVector(0.0, 0.2, 0.0);
    gravity.mult(this.mass); // Cancels out mass, as gravity should have the effect regardless of mass
    this.applyForce(gravity);

    // Add air drag
    PVector drag = new PVector(this.velocity.x, this.velocity.y, 0.0);
    float dragMag = drag.mag();
    drag.normalize();
    drag.mult(-1);
    float drag_coefficient = 0.01; // May need to play around with this depending on how many objects are influencing each other
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

    // Apply spring constraint
    for (int i = 0; i < springs.size (); i++) {
      PVector spring = new PVector(this.location.x, this.location.y, 0.0);
      spring.sub(this.springs.get(i).location);
      float currentLength = this.springs.get(i).location.dist(this.location);
      spring.normalize();
      float stretchLength = currentLength - this.restLengths.get(i);
      spring.mult(-this.elasticity * stretchLength);
      this.applyForce(spring);
    }

    // Limit ball inside window boundaries
    float objSize = this.mass * MASS_SCALAR;
    float objRadius = objSize / 2.0;
    if (this.location.y > height - objRadius) {
      // Bottom screen
      this.location.y = height - objRadius;
      this.velocity.y *= -1;
      // Apply friction on ground impact
      PVector friction = new PVector(this.velocity.x, this.velocity.y, 0.0);
      friction.normalize();
      friction.mult(-1);
      float frictionCoefficient = 0.1;
      friction.mult(frictionCoefficient);
      this.applyForce(friction);
    } else if (this.location.y < 0 + objRadius) {
      // Top screen
      this.location.y = 0 + objRadius;
      this.velocity.y *= -1;
    }
    
    if (this.location.x < 0 + objRadius) {
      // Left screen
      this.location.x = 0 + objRadius;
      this.velocity.x *= -1;
    } else if (this.location.x > width - objRadius) {
      // Right screen
      this.location.x = width - objRadius;
      this.velocity.x *= -1;
    }
  }

  void draw() {
    // First draw springs
    if (this.springs.size() > 0) {
      for (int i = 0; i < springs.size (); i++) {
        Ball springObj = springs.get(i);
        float currentLength = springObj.location.dist(this.location);
        float STRETCH_MULT = 15.0; // Need to multiply the value to make the squash and stretch more obvious
        float stretchLength = (this.mass / MASS_DEFAULT) * (this.restLengths.get(i) / currentLength) * STRETCH_MULT;
        stretchLength = min(10.0, stretchLength);
        strokeWeight(stretchLength);
        stroke(150);
        line(this.location.x, this.location.y, springObj.location.x, springObj.location.y);
      }
    }    

    // Then draw the ball
    fill(255, 0, 0);    
    strokeWeight(3.0);
    stroke(0);
    float ballSize = this.mass * MASS_SCALAR;
    ellipse(this.location.x, this.location.y, ballSize, ballSize);
  }
}


void setup() {
  // Setup sketch with balls and springs
  size(600, 500);
  
  int ballCount = 4;
  float yStart = 100.0;
  float yOffset = 20.0;
  
  for (int i = 0; i < ballCount; i++) {
    Ball newBall = addBall(width / 2.0, yStart + (i * yOffset) );
    if (i > 0) {
      newBall.addSpringObject( balls.get(i-1) );
    }
  }
  
  balls.get(0).isStatic = true;
}


void draw() {
  if (mousePressed) {
    forceMult = 1.0;
  } else {
    forceMult = 0;
  }

  // Animation to sway first ball back and forth
  float sineOffset = (width / 2);
  float sineFreq = 0.03;
  float sineAmp = 100.0;
  balls.get(0).location.x = sineOffset + sin(CURRENT_TIME * sineFreq) * sineAmp;

  // First sim objects
  for (Ball ball : balls) { 
    ball.sim();
  }

  // Now draw objects
  background(255);
  for (Ball ball : balls) {
    ball.draw();
  }
  fill(0);
  String elasticityStr = nf(balls.get(0).elasticity, 1, 3);
  text("Elasticity: " + elasticityStr, 10, 20);

  CURRENT_TIME += 1;
}


void keyPressed() {
  if (keyCode == Q_VALUE) {
    // Increase springs elasticity
    for (Ball ball : balls) {
      ball.elasticity = min(0.05, ball.elasticity + 0.001);
    }
  } else if (keyCode == W_VALUE) {
    // Decrease springs elasticity
    for (Ball ball : balls) {
      ball.elasticity = max(0.002, ball.elasticity - 0.001);
    }
  } else if (keyCode == A_VALUE) {
    // Increase ball mass
    for (Ball ball : balls) { 
      ball.mass = min(6.0, ball.mass + 0.1);
    }
  } else if (keyCode == S_VALUE) {
    // Decrease ball mass
    for (Ball ball : balls) { 
      ball.mass = max(0.5, ball.mass - 0.1);
    }
  }
}


Ball addBall(float x, float y) {
  Ball newBall = new Ball();
  newBall.location.set(x, y, 0.0);
  balls.add(newBall);
  return newBall;
}