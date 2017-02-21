/*
Erratic electron

Controls:
	- MouseX changes the angle count.
    - MouseY changes the point count.

Author:
  Jason Labbe

Site:
  jasonlabbe3d.com
*/


var baseSize = 250;
var baseHue = 0;
var asShape = false;


function setup() {
  createCanvas(windowWidth, windowHeight);
  
  colorMode(HSB, 360);
  
  textAlign(CENTER);
} 


function draw() {
  // Background color should always be complimentary to the current stroke.
  bgHue = baseHue+150;
  if (bgHue > 360) {
    bgHue = bgHue-360;
  }
  
  background(bgHue, 255, 255);
  
  push();
  
  translate(width/2, height/2);
  rotate(radians(-frameCount)*0.25);
  
  var angleSteps = map(mouseX, 0, width, 15, 4);
  
  var count = map(mouseY, 0, height, 20, 1);
  
  if (asShape) {
  	beginShape();
  }
  
  noFill();
  
  for (var angle = 0; angle < 360; angle += angleSteps) {
    var freq = 0.1;
    var amp = sin(frameCount*freq)*20+15;
    var mult = map(sin(frameCount*freq-angle)*0.7, -1, 1, 50, baseSize);
    
    // Get its end point.
  	var pos = new p5.Vector(sin(radians(angle)), cos(radians(angle)));
    pos.mult(sin(frameCount*freq-angle)*amp+mult);
    
    stroke(baseHue, 300, 300);
    
    // Create points from its start to end points.
    for (var i = 1; i < count; i++) {
      if (asShape) {
        strokeWeight(3);
      } else {
      	strokeWeight(map(i, 0, count, 0, 12));
      }
      
      var x = map(i, 0, count, 0, pos.x);
      var y = map(i, 0, count, 0, pos.y);
      
      if (asShape) {
        vertex(x, y);
      } else {
      	point(x, y);
      }
    }
  }
  
  if (asShape) {
  	endShape();
  }
  
  pop();
  
  fill(360);
  text("Mouse click to change its render mode.", width/2, height-50);
}


// Increase hue every time the mouse moves.
function mouseMoved() {
  baseHue += 0.5;

  if (baseHue > 360) {
    baseHue = 0;
  }
}


function mousePressed() {
  asShape = ! asShape;
}
