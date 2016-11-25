/*
Enemy FOV with walls test

Controls:
  - Click and drag end points of walls to move them.
  - Hold up & down arrow keys to adjust the fov's angle.
  - Press space to toggle debug drawing.

Author:
  Jason Labbe

Site:
  jasonlabbe3d.com

Resources:
  https://www.youtube.com/watch?v=73Dc5JTCmKI
  https://legends2k.github.io/2d-fov/design.html
  http://ncase.me/sight-and-light/
*/


PVector player;
ArrayList<Enemy> enemies = new ArrayList<Enemy>();
ArrayList<Wall> walls = new ArrayList<Wall>();
PVector wallPoint = null;
boolean debug = true;

int edgeRaySampleCount = 10;
int raySampleCount = 20;

String tipString;


// Holds information about intersections
class RayInfo {
  Segment ray;
  Wall wall;
  boolean collision = false;
  PVector endPos = new PVector(0, 0);
  float angle = 0;
}


// Represents a single segment with two points
class Segment {
  PVector pos1;
  PVector pos2;
  
  Segment(float _x1, float _y1, float _x2, float _y2) {
    this.pos1 = new PVector(_x1, _y1);
    this.pos2 = new PVector(_x2, _y2);
  }
}


// A displayable segment
class Wall extends Segment {
  Wall(float _x1, float _y1, float _x2, float _y2) {
    super(_x1, _y1, _x2, _y2);
  }

  void draw() {
    stroke(100);
    strokeWeight(4);
    line(this.pos1.x, this.pos1.y, this.pos2.x, this.pos2.y);
  }
}


class Enemy {
  PVector pos;
  PVector dir = new PVector(0, 0);
  float sightDistance = 300;
  float sightAngle = 25;
  int state = 0; // 0=Normal, 1=Alert
  
  Enemy(float _x, float _y) {
    this.pos = new PVector(_x, _y);
  }
  
  // Shoots a ray at the supplied angle to check if it collides against any obstacles
  RayInfo shootRay(float angle, float mag, boolean display) {
    RayInfo rayInfo = new RayInfo();
    
    // Create a ray with supplied magnitude
    PVector rayDirection = new PVector(sin(radians(angle)), cos(radians(angle)));
    rayDirection.normalize();
    PVector rayEndPos = new PVector(this.pos.x, this.pos.y);
    rayDirection.mult(mag);
    rayEndPos.add(rayDirection);
    Segment ray = new Segment(this.pos.x, this.pos.y, rayEndPos.x, rayEndPos.y);
    
    // Gets the intersection of the closest wall
    float closestDist = 0;
    for (int i = 0; i < walls.size(); i++) {
      RayInfo wallRayInfo = getSegmentIntersection(ray, walls.get(i));
      float currentDist = dist(this.pos.x, this.pos.y, wallRayInfo.endPos.x, wallRayInfo.endPos.y);
      
      if (i == 0 || currentDist < closestDist) {
        rayInfo = wallRayInfo;
        closestDist = currentDist;
      }
    }
    rayInfo.angle = angle;
    
    if (display && debug) {
      strokeWeight(1);
      stroke(0, 100);
      line(this.pos.x, this.pos.y, rayInfo.endPos.x, rayInfo.endPos.y);
      
      if (rayInfo.collision) {
        noFill();
        stroke(150, 150, 255);
        strokeWeight(10);
        point(rayInfo.endPos.x, rayInfo.endPos.y);
      }
    }
    
    return rayInfo;
  }
  
  // Shoots multiple rays between two angles so that it helps draw better around edges instead of clipping through
  void edgeHandling(RayInfo rayInfo, RayInfo lastRayInfo, ArrayList<PVector> positions) {
    float maxAngle = max(rayInfo.angle, lastRayInfo.angle);
    float minAngle = min(rayInfo.angle, lastRayInfo.angle);
    float sampleStep = (maxAngle-minAngle)/(edgeRaySampleCount+1);
    
    for (int i = 0; i < edgeRaySampleCount; i++) {
      float newAngle = minAngle + sampleStep*(i+1);
      RayInfo newRayInfo = this.shootRay(newAngle, this.sightDistance, true);
      positions.add(positions.size()-1, newRayInfo.endPos);
    }
  }
  
  // Draws enemy's fov without clipping through walls
  void drawFieldOfView() {
    float angleStep = this.sightAngle/(raySampleCount-1)*2;
    float currentAngle = degrees(atan2(this.dir.x, this.dir.y));
    ArrayList<PVector> positions = new ArrayList<PVector>();
    RayInfo lastRayInfo = null;
    
    for (int i = 0; i < raySampleCount; i ++) {
      // Cast ray at supplied angle
      float angle = currentAngle+i*angleStep-this.sightAngle;
      RayInfo rayInfo = this.shootRay(angle, this.sightDistance, true);
      positions.add(rayInfo.endPos);
      
      if (lastRayInfo != null) {
        // If a ray was hit and another missed then it must be an edge
        if (rayInfo.collision != lastRayInfo.collision || (rayInfo.collision && lastRayInfo.collision && rayInfo.wall != lastRayInfo.wall)) {
          this.edgeHandling(rayInfo, lastRayInfo, positions);
        }
      }
      
      lastRayInfo = rayInfo;
    }
    
    // Draw polygons from collected positions
    if (this.state == 1) {
      fill(255, 0, 0, 50);
    } else {
      fill(0, 0, 255, 50);
    }
    noStroke();
    
    beginShape();
    for (int i = 0; i < positions.size ()-1; i++) {
      vertex(this.pos.x, this.pos.y);

      PVector p1 = positions.get(i);
      vertex(p1.x, p1.y);

      PVector p2 = positions.get(i+1);
      vertex(p2.x, p2.y);
    }
    endShape();
  }
  
  // Checks if the player outside of its fov or is blocked by an obstacle
  void findPlayer() {
    this.state = 0;
    
    float distance = dist(player.x, player.y, this.pos.x, this.pos.y);
    
    if (distance > this.sightDistance) {
      return;
    }
    
    // Point direction to player
    PVector dirToPlayer = new PVector(player.x, player.y);
    dirToPlayer.sub(this.pos);
    dirToPlayer.normalize();
    
    // Check if it's within fov's angle cone
    float relativeAngle = degrees(acos(dirToPlayer.dot(this.dir)));
    if (relativeAngle < this.sightAngle) {
      // Shoot a ray to see if it hits any obstacles
      float angle = degrees(atan2(dirToPlayer.x, dirToPlayer.y));
      RayInfo rayInfo = this.shootRay(angle, this.sightDistance, false);
      float rayDistance = dist(rayInfo.endPos.x, rayInfo.endPos.y, this.pos.x, this.pos.y);
      
      if (debug) {
        strokeWeight(2);
        stroke(0);
        line(this.pos.x, this.pos.y, rayInfo.endPos.x, rayInfo.endPos.y);
        
        if (rayInfo.collision) {
          noFill();
          ellipse(rayInfo.endPos.x, rayInfo.endPos.y, 15, 15);
        }
      }
      
      if (distance < rayDistance) {
        this.state = 1;
      }
    }
  }
  
  void draw() {
    // Draw fov
    this.drawFieldOfView();
    
    // Draw enemy
    stroke(255, 0, 0);
    strokeWeight(1);
    fill(255, 100, 100);
    ellipse(this.pos.x, this.pos.y, 10, 10);
    
    // Draw text
    if (this.state == 1) {
      fill(0);
      textAlign(CENTER);
      textSize(30);
      text("!", this.pos.x, this.pos.y-10);
    }
  }
}


RayInfo getSegmentIntersection(Segment seg, Wall wall) {
  RayInfo rayInfo = new RayInfo();
  rayInfo.ray = seg;
  rayInfo.wall = wall;
  
  float sx1 = seg.pos2.x-seg.pos1.x;
  float sy1 = seg.pos2.y-seg.pos1.y;
  float sx2 = wall.pos2.x-wall.pos1.x;
  float sy2 = wall.pos2.y-wall.pos1.y;

  // Check if they are parallel
  if (sx1 == sx2 || sy1 == sy2) {
    return rayInfo;
  }

  // Gets value along each segment
  float s = (-sy1 * (seg.pos1.x-wall.pos1.x) + sx1 * (seg.pos1.y-wall.pos1.y)) / (-sx2*sy1+sx1*sy2);
  float t = (sx2 * (seg.pos1.y-wall.pos1.y) - sy2 * (seg.pos1.x-wall.pos1.x)) / (-sx2*sy1+sx1*sy2);

  // If both values are between 0.0-1.0 then it's a hit
  if (s >= 0 && s <= 1 && t >= 0 && t <= 1) {
    rayInfo.collision = true;
    rayInfo.endPos.x = seg.pos1.x + (t*sx1);
    rayInfo.endPos.y = seg.pos1.y + (t*sy1);
  } else {
    rayInfo.endPos.x = seg.pos2.x;
    rayInfo.endPos.y = seg.pos2.y;
  }

  return rayInfo;
}


void setup() {
  size(800, 550);
  
  tipString = "Click and drag end points of walls to move them.\n";
  tipString += "Hold up & down arrow keys to adjust the fov's angle.\n";
  tipString += "Press space to toggle debug drawing.";
  
  player = new PVector(0, 0);
  
  enemies.add(new Enemy(100, 100));
  enemies.add(new Enemy(580, 100));
  enemies.add(new Enemy(710, 445));
  enemies.get(2).dir.x = sin(radians(-110));
  enemies.get(2).dir.y = cos(radians(-110));
  
  walls.add(new Wall(200, 320, 270, 250));
  walls.add(new Wall(480, 280, 575, 430));
  walls.add(new Wall(285, 180, 385, 120));
  walls.add(new Wall(555, 240, 620, 240));
  walls.add(new Wall(455, 150, 455, 230));
}


void draw() {
  background(255);
  
  player.x = mouseX;
  player.y = mouseY;
  
  float enemyAngle1 = 45+sin(frameCount*0.005)*45;
  enemies.get(0).dir.x = sin(radians(enemyAngle1));
  enemies.get(0).dir.y = cos(radians(enemyAngle1));
  
  float enemyAngle2 = -20+sin(1+frameCount*0.005)*25;
  enemies.get(1).dir.x = sin(radians(enemyAngle2));
  enemies.get(1).dir.y = cos(radians(enemyAngle2));
  
  for (Enemy enemy : enemies) {
    enemy.findPlayer();
    enemy.draw();
  }
  
  stroke(0, 255, 0);
  strokeWeight(1);
  fill(100, 255, 100);
  ellipse(player.x, player.y, 10, 10);
  
  for (Wall wall : walls) {
    wall.draw();
  }
  
  fill(0);
  textAlign(CENTER);
  textSize(10);
  text(tipString, width/2, height-50);
}


// Gets nearest wall point
void mousePressed() {
  for (Wall wall : walls) {
    float dist1 = dist(wall.pos1.x, wall.pos1.y, mouseX, mouseY);
    if (dist1 < 20) {
      wallPoint = wall.pos1;
      break;
    }
    
    float dist2 = dist(wall.pos2.x, wall.pos2.y, mouseX, mouseY);
    if (dist2 < 20) {
      wallPoint = wall.pos2;
      break;
    }
  }
}


void mouseReleased() {
  wallPoint = null;
}


// Move wall's point
void mouseDragged() {
  if (wallPoint != null) {
    wallPoint.x = mouseX;
    wallPoint.y = mouseY;
  }
}


void keyPressed() {
  if (keyCode == 32) {
    debug = ! debug;
  } else if (keyCode == 38) {
    for (Enemy enemy : enemies) {
      enemy.sightAngle = min(enemy.sightAngle+1, 45);
    }
  } else if (keyCode == 40) {
    for (Enemy enemy : enemies) {
      enemy.sightAngle = max(10, enemy.sightAngle-1);
    }
  }
}

