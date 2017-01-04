/*
Waterfall cascades

Author:
  Jason Labbe

Site:
  jasonlabbe3d.com
*/

var pMinMass = 2;
var pMaxMass = 8;
var cMinMass = 15;
var cMaxMass = 100;

var waterfallMin;
var waterfallMax;

var particles = [];
var collisions = [];

var spawnSlider;
var splitSlider;
var frictionSlider;
var layoutButton;

var fps;


function do_aabb_collision(ax, ay, Ax, Ay, bx, by, Bx, By) {
  return ! ((Ax < bx) || (Bx < ax) || (Ay < by) || (By < ay));
}


// Set new targets for collision objects to lerp to.
function setNewLayout() {
  for (var i = 0; i < collisions.length; i++) {
    collisions[i].target.x = random(width/2.4, width-width/2.4);
    collisions[i].target.y = random(height/2, height);
    collisions[i].targetMass = random(cMinMass, cMaxMass);
  }
}


function setup() {
  createCanvas(windowWidth, windowHeight);
  
  waterfallMin = width/2.4;
  waterfallMax = width-width/2.4;
  
  // Create ui controls.
  spawnSlider = new SliderLayout("Spawn count", 1, 10, 5, 1, 50, 100);
  splitSlider = new SliderLayout("Split count", 1, 5, 1, 1, 50, 170);
  frictionSlider = new SliderLayout("Bounce", 0.1, 1, 0.3, 0.1, 50, 240);
  layoutButton = createButton("New layout");
  layoutButton.position(50, 290);
  layoutButton.mousePressed(setNewLayout);
  
  // Create collision objects.
  for (var i = 0; i < 10; i++) {
    var x = random(waterfallMin, waterfallMax);
    var y = random(height/2, height);
    var mass = random(cMinMass, cMaxMass);
    collisions[collisions.length] = new Collision(x, y, mass);
  }
}


function draw() {
  background(0, 150);
  
  var spawnCount = spawnSlider.slider.value();
  
  colorMode(HSB, 360);
  
  // Spawn new particles.
  for (var num = 0; num < spawnCount; num++) {
    var x = random(waterfallMin, waterfallMax);
    var mass = random(pMinMass, pMaxMass);
    
    if (particles.length % 5 == 0) {
      var displayColor = color(255);
    } else {
      var displayColor = color(random(180, 210), 255, 255);
    }
    
    var newParticle = new Particle(x, 0, mass, displayColor);
    particles[particles.length] = newParticle;
  }
  
  colorMode(RGB, 255);
  
  for (var i = particles.length-1; i > -1; i--) {
    particles[i].move();
    
    var has_collision = particles[i].resolveCollisions();
    
    particles[i].display();
    
    if (particles[i].pos.y > height) {
      // Delete if it's out of bounds.
      particles.splice(i, 1);
    } else if (has_collision && particles[i].vel.mag() < 0.1) {
      // Delete if it's stuck on top of a collision object.
      particles.splice(i, 1);
    }
  }
  
  for (var i = 0; i < collisions.length; i++) {
    collisions[i].move();
    collisions[i].display();
  }
  
  // Avoid updating frame rate every frame (not as readable).
  if (frameCount % 10 == 0) {
    fps = frameRate().toFixed(2);
  }
  
  // Display all ui items.
  noStroke();
  fill(255);
  textSize(20);
  text("FPS " + fps, 50, height-50);
  
  spawnSlider.display();
  splitSlider.display();
  frictionSlider.display();
}