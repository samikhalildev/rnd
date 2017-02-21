/*
Wisps

Particles try to follow your mouse.

Controls:
	- Move the mouse to lead the particles.

Author:
  Jason Labbe

Site:
  jasonlabbe3d.com
*/

var particles = [];
var particleCount = 20;


function Particle(x, y) {
  this.pos = new p5.Vector(x, y);
  this.vel = p5.Vector.random2D();
  this.vel.mult(10);
  this.acc = new p5.Vector(0, 0);
  this.target = new p5.Vector(0, 0);
  this.history = [];
  
  this.baseHue = 200;
  
  this.variation = random(0.75, 1);
  this.speed = random(0.25, 0.75);
  this.maxSpeed = random(5, 10);
  
  this.move = function() {
    this.target.x = mouseX;
    this.target.y = mouseY;
    
    var steer = new p5.Vector(this.target.x, this.target.y);
    steer.sub(this.pos);
    steer.sub(this.vel); // Makes it come to a stop.
    steer.normalize();
    steer.mult(this.speed*this.variation);
    this.acc.add(steer);
    
    this.vel.add(this.acc);
    this.vel.limit(this.maxSpeed);
    this.pos.add(this.vel);
    this.acc.mult(0);
    
    this.history.splice(0, 0, new p5.Vector(this.pos.x, this.pos.y));
    
    var maxHistoryCount = 20;
    if (this.history.length > maxHistoryCount) {
      this.history.splice(maxHistoryCount, 1);
    }
  }
  
  this.display = function() {
    var maxSize = 8;
    
    var hueDif = 50;
    
    for (var i = this.history.length-1; i > 0; i--) {
      strokeWeight(map(i, 0, this.history.length, maxSize, 0));
      var h = map(i, 0, this.history.length, this.baseHue, this.baseHue+hueDif);
      stroke(h, 360, 360);
      
      // Using points performs faster, but lines give a more 'crisp' look.
      line(this.history[i].x, this.history[i].y, this.history[i-1].x, this.history[i-1].y);
    }
    
    // Increase hue if it's below threshold.
    if (dist(this.pos.x, this.pos.y, this.target.x, this.target.y) < 100) {
      this.baseHue += 1;
      if (this.baseHue > 360-hueDif) {
        this.baseHue = -hueDif;
      }
    }
  }
}


function setup() {
  createCanvas(windowWidth, windowHeight); 
  
  colorMode(HSB, 360);
  
  for (var i = 0; i < particleCount; i++) {
    particles.push(new Particle(random(width/4, width-width/4), 
                                random(height/4, height-height/4)));
  }
  
  // Set default target to the center.
  mouseX = width/2;
  mouseY = height/2;
} 


function draw() {
  background(0);
  
  for (var i = 0; i < particles.length; i++) {
    particles[i].move();
    particles[i].display();
  }
}
