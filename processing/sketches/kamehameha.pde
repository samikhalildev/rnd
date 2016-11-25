/*
Kamehameha!!!
 
Controls:
- Move mouse around to rotate camera.
- Hold left-click/middle-click to zoom in & out.
 
Author: Jason Labbe
Site: jasonlabbe3d.com
*/
 
 
// Global variables
ArrayList<Particle> allParticles = new ArrayList<Particle>();
float rotx = -0.35;
float roty = 0.5;
float zoom = -410;
float mouseclickx = 0;
float prevZoomValue = 0;
 
 
class Particle {
  PVector pos = new PVector(0, 0, 0);
  PVector vel = new PVector(0, 0, 0);
  int timeOffset = 0;
  int dir = 1;
  float particleSize = 1;
  float variance = 0;
  float killOffset = 0;
  float speed = 0;
  boolean dynamic = false;
  color particleColor;
}
 
 
void setup() {
  size(800, 500, P3D);
  ellipseMode(CENTER);
  noiseSeed(0);
  smooth(1);
}
 
 
void draw() {
  background(0);
   
  // Create new set of particles for each side
  for (int x = 0; x < 10; x++) {
    Particle newParticle = new Particle();
    newParticle.particleSize = random(1.0, 5.0);
    newParticle.timeOffset = frameCount+(int)random(-25, 25);
    newParticle.variance = random(-40.0, 40.0);
    newParticle.speed = random(1.0, 5.0);
    newParticle.killOffset = random(-30.0, 30.0);
    newParticle.pos.y = noise((frameCount-newParticle.timeOffset)*0.03)*newParticle.variance;
    newParticle.pos.z = random(-25.0, 25.0);
     
    if (x % 2 == 0) {
      // Pink beam
      newParticle.dir = -1;
      newParticle.pos.x = width-width/2;
      newParticle.speed *= -1;
      float centerDist = dist(newParticle.pos.x, newParticle.pos.y, newParticle.pos.z, width-width/2, 0, 0);
      newParticle.particleColor = color(255, 255-centerDist*8, 255);
    } else {
      // Blue beam
      newParticle.dir = 1;
      newParticle.pos.x = -width/2;
      float centerDist = dist(newParticle.pos.x, newParticle.pos.y, newParticle.pos.z, -width/2, 0, 0);
      newParticle.particleColor = color(255-centerDist*10, 255-centerDist*5, 255);
    }
     
    allParticles.add(newParticle);
  }
   
  // Transform camera
  pushMatrix();
  translate(width/2, height/2, zoom);
  rotateX(rotx);
  rotateY(roty);
   
  for (int x = allParticles.size()-1; x > -1; x--) {
    Particle particle = allParticles.get(x);
     
    // Move particle
    if (particle.dynamic) {
      particle.pos.add(particle.vel);
    } else {
      particle.pos.x += particle.speed;
      particle.pos.y = noise((frameCount-particle.timeOffset)*0.03)*particle.variance;
    }
     
    if (! particle.dynamic) {
      // Check to see if it should be switched to dynamic
      float offset = 2; // Looks better if there's a slight offset
      if (particle.dir == 1 && particle.pos.x > -offset) {
        particle.dynamic = true;
      } else if (particle.dir == -1 && particle.pos.x < offset) {
        particle.dynamic = true;
      }
       
      if (particle.dynamic) {
        // Set new direction
        PVector source = new PVector((-offset*particle.dir), 0, 0);
        PVector dir = new PVector(particle.pos.x, particle.pos.y, particle.pos.z);
        dir.sub(source);
        dir.normalize();
        dir.mult(-particle.speed*0.2*particle.dir);
        particle.vel.x = dir.x;
        particle.vel.y = dir.y;
        particle.vel.z = dir.z;
      }
    }
     
    if (particle.dynamic) {
      // Kill particle if it's too far from origin
      float distance = dist(particle.pos.x, particle.pos.y, particle.pos.z, 0, 0, 0);
      if (distance > 200+particle.killOffset) {
        allParticles.remove(particle);
      }
    }
     
    // Draw particle
    strokeWeight(particle.particleSize);
    stroke(particle.particleColor);
    point(particle.pos.x, particle.pos.y, particle.pos.z);
  }
   
  popMatrix();
   
  // Draw text
  stroke(255);
  textAlign(CENTER);
  textSize(30);
  text("KAMEHAMEHA!!!", width/2+noise(frameCount)*10, height-30+noise(frameCount*0.5)*10);
}
 
 
// Rotates camera
void mouseMoved() {
  rotx = -(mouseY-height/2)/160.0;
  roty = (mouseX-width/2)/220.0;
}
 
 
// Captures values to do a relative zoom
void mousePressed() {
  mouseclickx = mouseX;
  prevZoomValue = zoom;
}
 
 
// Zooms camera
void mouseDragged() {
  if(mouseButton == LEFT || mouseButton == CENTER) {
    zoom = prevZoomValue+(mouseX-mouseclickx)*2;
  }
}

