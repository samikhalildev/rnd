/*
Pursuit and avoid
The green leader follows the target and stops when he reaches it. Both the blue and yellow agents are loyal to the leader and follow him. The yellow agents don't like the blue ones though, so they keep a distance from them.

 Controls:
 - Move or click mouse to set the target for agents to follow
 - Hold left mouse button and drag to create normal agents
 - Hold right mouse button and drag to create nervous agents
 
 Author: Jason Labbe
 Site: jasonlabbe3d.com
 Script inspired by Craig Reynolds & Daniel Shiffman
 More info at red3d.com/cwr/steer/ & shiffman.net
*/

// Global variables
ArrayList<Agent> agents = new ArrayList<Agent>();
PVector target = new PVector(0.0, 0.0, 0.0);
float proximity = 200.0; // Distance to target agents will begin to slow down
int mouseDragCount = 0;

// Global constants
int NORMAL_TYPE = 0;
int LEADER_TYPE = 1; // Doesn't avoid other agents
int NERVOUS_TYPE = 2; // Moves fast, and keeps a big distance from normal agents

class Agent {
  PVector location = new PVector();
  PVector velocity = new PVector();
  PVector acceleration = new PVector();
  float mass = 1.0;
  float drawSize = 30.0;
  float speed = 3.0;
  int type = 0;

  Agent(int _type) {
    this.type = _type;
    if (this.type == LEADER_TYPE) {
      this.speed = 20.0;
      this.drawSize = 20.0;
    } else if (this.type == NERVOUS_TYPE) {
      this.speed = 10.0;
      this.drawSize = 15.0;
    }
  }

  void applyForce(PVector force) {
    PVector forceCopy = force.get();
    force.div(this.mass);
    this.acceleration.add(force);
  }

  void sim() {
    // Seek towards target
    PVector seek = PVector.sub(target, this.location);
    float targetDist = seek.mag();
    seek.normalize();
    float proximityRad = (proximity / 2.0);
    float slowMult = 1.0;
    if (targetDist < proximityRad) { // The closer we are, the slower we make him
      slowMult = targetDist / proximityRad;
    }   
    seek.mult(this.speed * slowMult);
    PVector steer = PVector.sub(seek, this.velocity);
    float limit = this.speed / 20.0;
    if (this.type == LEADER_TYPE) { 
      limit = 2.0;
    }
    steer.limit(limit);
    this.applyForce(steer);

    // Avoid other agents
    if (this.type != LEADER_TYPE) {
      PVector avoidSum = new PVector(0.0, 0.0, 0.0);
      int avoidCount = 0;
      for (Agent agent : agents) {
        if (this != agent) {
          PVector avoid = PVector.sub(agent.location, this.location);
          float agentDist = avoid.mag();
          float avoidDist = (this.drawSize / 2.0) + (agent.drawSize / 2.0);
          if (agent.type == LEADER_TYPE) {
            avoidDist *= 2.0;
          } else if (this.type == NERVOUS_TYPE && agent.type != NERVOUS_TYPE) {
            avoidDist *= 5.0;
          }
          if (agentDist < avoidDist) {
            avoid.normalize();
            avoid.mult(100.0);
            PVector avoidSteer = PVector.sub(this.velocity, avoid);
            avoidSteer.normalize();
            avoidSum.add(avoidSteer);
            avoidCount += 1;
          }
        }
      }
      if (avoidCount > 0) {
        avoidSum.div(avoidCount);
        avoidSum.normalize();
        float avoidMult = 1.0;
        float avoidLimit = 1.0;
        if (this.type == NORMAL_TYPE) {
          avoidMult = 1.0;
          avoidLimit = 0.75;
        } else if (this.type == NERVOUS_TYPE) {
          avoidMult = 2.0;
          avoidLimit = 1.5;
        }       
        avoidSum.mult(avoidMult);
        avoidSum.limit(avoidLimit);
        this.applyForce(avoidSum);
      }
    }

    this.velocity.add(this.acceleration);
    this.location.add(this.velocity);
    this.acceleration.mult(0);
  }

  void draw() {
    strokeWeight(2);
    if (this.type == LEADER_TYPE) {
      fill(0, 255, 0);
    } else if (this.type == NERVOUS_TYPE) {
      fill(255, 255, 0);
    } else {
      fill(0, 200, 255);
    }
    ellipse(this.location.x, this.location.y, drawSize, drawSize);
  }
}

Agent addAgent(int agentType, float xPos, float yPos) {
  Agent newAgent = new Agent(agentType);
  newAgent.location.set(xPos, yPos, 0.0);
  newAgent.type = agentType;
  agents.add(newAgent);
  return newAgent;
}

void setup() {
  size(800, 800);

  // Populate scene with agents
  int agentCount = 15;
  for (int i = 0; i < agentCount; i++)
  {
    float xPos = random(0, width);
    float yPos = random(0, height);
    if (i == 0) {
      addAgent(LEADER_TYPE, xPos, yPos);
    } else {
      if (i % 3 == 1) { // We'll get a 3:1 ratio of nervous agents
        addAgent(NERVOUS_TYPE, xPos, yPos);
      } else {
        addAgent(NORMAL_TYPE, xPos, yPos);
      }
    }
  }

  target.set(width / 2, height / 2, 0);
}

void draw() {
  // First sim agents
  for (Agent v : agents) { 
    v.sim();
  }

  background(255);

  // Draw target
  strokeWeight(0);
  stroke(0);
  fill(240, 255, 240);
  ellipse(target.x, target.y, proximity, proximity);
  fill(0, 255, 0);
  ellipse(target.x, target.y, 5, 5);

  // Draw vechicles
  for (Agent v : agents) { 
    v.draw();
  }
}

void mouseDragged() {
  if (mouseDragCount % 30 == 1) {
    if (mouseButton == LEFT) {
      addAgent(NORMAL_TYPE, mouseX, mouseY);
    } else {
      addAgent(NERVOUS_TYPE, mouseX, mouseY);
    }
  }
  mouseDragCount += 1;
}

void mouseClicked() { // Including this so it can move on a mobile
  target.set(mouseX, mouseY, 0.0);
}

void mouseMoved() {
  target.set(mouseX, mouseY, 0.0);
}


