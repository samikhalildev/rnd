/*
To do:
    - Use AABB before distance.
    - Randomize collision layout.
*/

var minMass = 2;
var maxMass = 8;

var particles = [];
var collisions = [];

var spawnSlider;
var splitSlider;
var frictionSlider;
var fps;


function Collision(x, y, mass) {
  this.pos = new p5.Vector(x, y);
  this.mass = mass;
  
  this.getBoundingBox = function() {
    var radius = this.mass/2;
    
    var ax = this.pos.x-radius;
    var ay = this.pos.y-radius;
    var bx = this.pos.x+radius;
    var by = this.pos.y+radius;
    
    return [ax, ay, bx, by];
  }
  
  this.display = function() {
    noStroke();
    
    fill(255);
    ellipse(this.pos.x, this.pos.y, this.mass, this.mass);
    
    fill(0);
    ellipse(this.pos.x, this.pos.y, this.mass*0.95, this.mass*0.95);
  }
}


function Particle() {
  colorMode(HSB, 360);
  
  this.pos = new p5.Vector(random(width/2.4, width-width/2.4), 0);
  this.vel = new p5.Vector(0, 0);
  this.acc = new p5.Vector(0, 0);
  this.mass = random(minMass, maxMass);
  if (particles.length % 5 == 0) {
    this.displayColor = color(255);
  } else {
    this.displayColor = color(random(180, 210), 255, 255);
  }
  this.fallRate = map(this.mass, minMass, maxMass, 0.1, 0.05);
  
  colorMode(RGB, 255);
  
  this.getBoundingBox = function() {
    var radius = this.mass/2;
    var offset = 5; // Just to expand its bb a bit.
    
    var ax = this.pos.x-radius-offset;
    var ay = this.pos.y-radius-offset;
    var bx = this.pos.x+radius+offset;
    var by = this.pos.y+radius+offset;
    
    return [ax, ay, bx, by];
  }
  
  this.move = function() {
    var gravity = new p5.Vector(0, this.fallRate);
    this.acc.add(gravity);
    
    this.vel.add(this.acc);
    this.pos.add(this.vel);
    this.acc.mult(0);
  }
  
  this.display = function() {
    noStroke();
    fill(this.displayColor);
    ellipse(this.pos.x, this.pos.y, this.mass, this.mass);
  }
}


function do_aabb_collision(ax, ay, Ax, Ay, bx, by, Bx, By) {
  return ! ((Ax < bx) || (Bx < ax) || (Ay < by) || (By < ay));
}


function setup() {
  createCanvas(windowWidth, windowHeight);
  
  spawnSlider = createSlider(1, 10, 5, 1);
  spawnSlider.position(50, 100);
  
  splitSlider = createSlider(1, 5, 1, 1);
  splitSlider.position(50, 200);
  
  frictionSlider = createSlider(0.1, 1, 0.4, 0.1);
  frictionSlider.position(50, 300);
  
  collisions[collisions.length] = new Collision(width/2+50, height/2, 100);
  collisions[collisions.length] = new Collision(width/2-130, height/2+100, 60);
  collisions[collisions.length] = new Collision(width/2+140, height/2+170, 50);
  collisions[collisions.length] = new Collision(width/2+10, height/2+250, 60);
  collisions[collisions.length] = new Collision(width/2-120, height+30, 150);
} 


function draw() {
  background(0, 200);
  
  var spawnCount = spawnSlider.value();
  
  for (var num = 0; num < spawnCount; num++) {
    var newParticle = new Particle();
    particles[particles.length] = newParticle;
  }
  
  for (var i = particles.length-1; i > -1; i--) {
    particles[i].move();
    
    var hit_object = false;
    
    for (var c = 0; c < collisions.length; c++) {
      var col = collisions[c];
      
      var distance = dist(particles[i].pos.x, particles[i].pos.y, col.pos.x, col.pos.y);

      if (distance < col.mass/2) {
        // Push out of collision object
        var offset = particles[i].pos.copy();
        offset.sub(col.pos);
        offset.normalize();
        offset.mult(col.mass/2-distance);
        particles[i].pos.add(offset);

        var friction = frictionSlider.value();
        var dampening = map(particles[i].mass, minMass, maxMass, 1, 0.8);
        var mag = particles[i].vel.mag();

        // Get its new vector
        var bounce = particles[i].pos.copy();
        bounce.sub(col.pos);
        bounce.normalize();
        bounce.mult(mag*friction*dampening);
        particles[i].vel = bounce;
        
        if (particles[i].mass > 2) {
          particles[i].mass = max(1, particles[i].mass-2);
          
          var splitCount = splitSlider.value();
          
          for (var s = 0; s < splitCount; s++) {
            var splash = new Particle();
            splash.pos = particles[i].pos.copy();
            splash.vel = particles[i].vel.copy();
            splash.vel.rotate(radians(random(-45, 45)));
            splash.vel.mult(random(0.6, 0.9));
            splash.mass = 1;
            splash.displayColor = color(255);
            particles[particles.length] = splash;
          }
        }
        
        hit_object = true;
        
        break;
      }
    }
    
    particles[i].display();
    
    if (particles[i].pos.y > height) {
      // Delete if it's out of bounds.
      particles.splice(i, 1);
    } else if (hit_object && particles[i].vel.mag() < 0.1) {
      // Delete if it's stuck on top of a collision object.
      particles.splice(i, 1);
    }
  }
  
  for (var i = 0; i < collisions.length; i++) {
    collisions[i].display();
  }
  
  noStroke();
  
  if (frameCount % 10 == 0) {
    fps = frameRate().toFixed(2);
  }
  fill(255);
  textSize(20);
  text("FPS " + fps, 50, height-50);
  
  var spawnPos = spawnSlider.position();
  textSize(15);
  text("Spawn count", spawnPos.x, spawnPos.y-10);
  
  fill(255, 255, 0);
  text(spawnSlider.value(), spawnPos.x+spawnSlider.width+10, spawnPos.y+10);
  
  var splitPos = splitSlider.position();
  fill(255);
  textSize(15);
  text("Split count", splitPos.x, splitPos.y-10);
  
  fill(255, 255, 0);
  text(splitSlider.value(), splitPos.x+splitSlider.width+10, splitPos.y+10);
  
  var frictionPos = frictionSlider.position();
  fill(255);
  textSize(15);
  text("Friction", frictionPos.x, frictionPos.y-10);
  
  fill(255, 255, 0);
  text(frictionSlider.value(), frictionPos.x+frictionSlider.width+10, frictionPos.y+10);
}
