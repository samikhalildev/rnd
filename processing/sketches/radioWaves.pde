/*
Radio waves

Author:
  Jason Labbe

Site:
  jasonlabbe3d.com
*/


var count = 200;
var timeOffset = 2.5;
var posOffset = 2.5;


function setup() {
  createCanvas(windowWidth, windowHeight); 
} 


function draw() {
  background(50);
  
  noFill();
  strokeWeight(2);
  
  colorMode(HSB, 360);
  
  translate(width/2-count, height/2);
  
  for (var z = 0; z < 2; z++) {
    if (z == 1) {
      scale(1, -1);
    }
    
    for (var i = 0; i < count; i++) {
      var h = map(i, 0, count, 200, 300);
      var s = map(i, 0, count, 0, 360);
      var b = map(i, 0, count, 141, 360);
      var a = map(i, 0, count, 0, 255);
      
      stroke(h, 360, 360, a);
      
      var value = sin(radians(frameCount+i*timeOffset));
      var end = map(abs(value), 0, 1, PI, TWO_PI);
      var waveHeight = map(abs(value), 0, 1, 0, 300*cos(radians(frameCount+i)))
      
      arc(i*posOffset, 0, 200, waveHeight, PI, end, PIE);
    }
  }
  
  colorMode(RGB, 255);
}
