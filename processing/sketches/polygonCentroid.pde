function setup() {
  createCanvas(windowWidth, windowHeight); 
  
  background(0);
  
  var p1 = new p5.Vector(random(width/4, width-width/4), random(height/4, height-height/4));
  var p2 = new p5.Vector(random(width/4, width-width/4), random(height/4, height-height/4));
  var p3 = new p5.Vector(random(width/4, width-width/4), random(height/4, height-height/4));
  var centroid = new p5.Vector((p1.x+p2.x+p3.x)/3, (p1.y+p2.y+p3.y)/3);
  
  strokeWeight(1);
  
  stroke(255, 0, 0);
  line(p1.x, p1.y, centroid.x, centroid.y);
  
  stroke(0, 255, 0);
  line(p2.x, p2.y, centroid.x, centroid.y);
  
  stroke(0, 0, 255);
  line(p3.x, p3.y, centroid.x, centroid.y);
  
  strokeWeight(10);
  
  stroke(255, 255, 0);
  point(centroid.x, centroid.y);
  
  stroke(255);
  point(p1.x, p1.y);
  point(p2.x, p2.y);
  point(p3.x, p3.y);
  
  stroke(255);
  noFill();
  strokeWeight(3);
  
  beginShape();
  vertex(p1.x, p1.y);
  vertex(p2.x, p2.y);
  vertex(p3.x, p3.y);
  endShape(CLOSE);
}
