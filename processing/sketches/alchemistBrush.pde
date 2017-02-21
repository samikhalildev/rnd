/*
Alchemist's brush

Controls:
	- Click and drag to create particles.

Author:
  Jason Labbe

Site:
  jasonlabbe3d.com
*/

var particles = [];
var globalHue = 0;
var inverse = false;

function Particle(x, y) {
  
  this.pos = new p5.Vector(x, y);
  this.life = 1.0;
  this.lifeRate = random(0.005, 0.02);
  this.angle = map(cos(radians(frameCount*5)), -1, 1, -180, 180);
  this.hue = globalHue;
  this.maxScale = max(0.25, abs(sin(radians(frameCount*5))*1.5));
  this.rotateRate = random(-200, 200);
  this.maxOffset = random(50, 300);
  
  this.display = function() {
    var offset = map(this.life, 1, 0, 0, this.maxOffset); // Pushes out along x axis.
    
    // Scales from particle's origin pivot.
    var s;
    if (inverse) {
      s = map(this.life, 1, 0, 0, this.maxScale);
    } else {
      s = map(this.life, 1, 0, this.maxScale, 0);
    }
    
    var t = map(this.life, 1, 0, 0, 1); // Represents the time of the particle's life.
    
    var opacity = map(this.life, 1, 0, 255, 0);
    
    strokeWeight(5);
    stroke(color(this.hue, 255, 200, opacity*0.5)); // Show stroke slightly darker.
    fill(color(this.hue, 255, 255, opacity*0.8));
    
    push();
    
    // Creates a spiral motion.
    translate(this.pos.x, this.pos.y);
    rotate(radians(this.angle+t*this.rotateRate));
    scale(s);
    
    ellipse(offset, 0, 20, 20);
    
    pop();
    
    this.life -= this.lifeRate;
  }
}


function setup() {
  createCanvas(windowWidth, windowHeight);
  
  colorMode(HSB, 255);
  
  textAlign(CENTER);
  textSize(14);
  
  background(0);
}


function mousePressed() {
  globalHue = random(0, 255);
}


function mouseDragged() {
  particles.push(new Particle(mouseX, mouseY));
  
  globalHue += 0.1;
  if (globalHue > 255) {
    globalHue = 0;
  }
}


function keyPressed() {
  inverse = ! inverse;
}


function draw() {
  noStroke();
  fill(0, 100);
  rect(0, 0, width*2, height*2);
  
  for (var i = particles.length-1; i > -1; i--) {
    particles[i].display();
    
    if (particles[i].life < 0) {
      particles.splice(i, 1);
    }
  }
  
  noStroke();
  fill(255);
  text("Press any key to change the type of motion.", width/2, height-30);
}
