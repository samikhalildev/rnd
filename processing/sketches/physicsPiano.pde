/*
Physics piano

Musical notes are played when a collision occurs.
Heavier balls lowers the note's pitch.

Controls:
	- Click and drag to create balls.

Author:
  Jason Labbe

Site:
  jasonlabbe3d.com
*/

var keyCount = 10;
var keyMass = 50;
var keys = [];

var balls = [];
var maxBallMass = 60;
var minBallMass = 30;


function Ball(x, y, mass) {
  
  this.pos = new p5.Vector(x, y);
  this.vel = new p5.Vector(0, 0);
  this.acc = new p5.Vector(0, 0);
  this.mass = mass;
  
  this.addForce = function(force) {
    this.acc.add(force);
  }
  
  this.move = function() {
    var gravity = new p5.Vector(0, 0.2);
    this.addForce(gravity);
    
    this.vel.add(this.acc);
    this.pos.add(this.vel);
    this.acc.mult(0);
  }
  
  this.checkCollision = function() {
    for (var i = 0; i < keys.length; i++) {
      var distance = dist(this.pos.x, this.pos.y, keys[i].pos.x, keys[i].pos.y);
      
      if (distance < this.mass/2+keyMass/2) {
        var mag = this.vel.mag();
        
        // Push ball out of key object.
        var bounce = this.pos.copy();
        bounce.sub(keys[i].pos);
        bounce.normalize();
        bounce.mult(this.mass/2+keyMass/2-distance);
        this.pos.add(bounce);
        
        // Set its new velocity with some friction.
        bounce.normalize();
        bounce.mult(mag*0.9);
        this.vel = bounce;
        
        // Change key's color and play a note.
        keys[i].strokeColor = color(random(255), random(255), random(255));
        keys[i].playSound(map(this.mass, maxBallMass, minBallMass, keys[i].freq*0.5, keys[i].freq));
        
        break;
      }
    }
  }
  
  this.display = function() {
    stroke(0);
    strokeWeight(6);
    fill(220);
    
    push();
    translate(this.pos.x, this.pos.y);
    ellipse(0, 0, this.mass, this.mass);
    pop();
  }
}


function Key(x, y, freq) {
  
  this.pos = new p5.Vector(x, y);
  this.freq = freq;
  this.strokeColor = color(0);
  
  this.osc = new p5.SinOsc();
  this.osc.start();
  this.osc.amp(0);
  this.osc.freq(0);
  
  this.env = new p5.Env();
  this.env.setADSR(0.001, 0.25, 0.1, 0.5);
  this.env.setRange(0.5, 0);
  
  this.display = function() {
    this.strokeColor = lerpColor(this.strokeColor, color(0), 0.1);
    stroke(this.strokeColor);
    strokeWeight(6);
    fill(220);
    
    push();
    translate(this.pos.x, this.pos.y);
    ellipse(0, 0, keyMass, keyMass);
    pop();
    
  }
  
  this.playSound = function(freq) {
    this.osc.freq(freq);
    this.env.play(this.osc);
  }
}


function setup() {
  createCanvas(windowWidth, windowHeight);
  
  ellipseMode(CENTER);
  
  var rowCount = 3;
  var margins = 50;
  
  // Create key objects.
  for (var i = 0; i < rowCount; i++) {
    for (var j = 0; j < keyCount; j++) {
      var x = map(j, 0, keyCount-1, margins, width-margins);
      var y = map(i, 0, rowCount-1, height/2, height-margins);
      
      var freq = random(200, 800);
      
      keys.push(new Key(x, y, freq));
    }
  }
  
  for (var i = 0; i < 5; i++) {
  	balls.push(new Ball(random(0, width), random(-100, 0), minBallMass));
  }
} 


function draw() {
  background(255, 50, 50);
  
  for (var i = balls.length-1; i > -1; i--) {
    balls[i].move();
    balls[i].checkCollision();
    balls[i].display();
    
    // Removes out of bound balls.
    if (balls[i].pos.y > height || balls[i].pos.x > width || balls[i].pos.x < 0) {
      balls.splice(i, 1);
    }
  }
  
  for (var i = 0; i < keys.length; i++) {
    keys[i].display();
  }
}


function mouseDragged() {
  // Slows down the spawn rate.
  if (frameCount % 10 != 0) {
    return;
  }
  
  var mass = random(minBallMass, maxBallMass);
  
  var newBall = new Ball(mouseX, mouseY, mass);
  
  var p1 = new p5.Vector(pmouseX, pmouseY);
  var p2 = new p5.Vector(mouseX, mouseY);
  p2.sub(p1);
  newBall.vel = p2;
  
  balls.push(newBall);
}
