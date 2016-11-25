/*
Accidental Fractals

Controls:
- Press any key to change between drawing with fill or stroke.

Author: Jason Labbe
Site: jasonlabbe3d.com
*/


// Global variables
ArrayList<FractalPiece> allFractals = new ArrayList<FractalPiece>();
HashMap <Integer, Integer[]> fractalData = new HashMap <Integer, Integer[]>();
boolean drawFill = true;
int currentIndex = 0;
int currentNestedIndex = 0;
int currentDrawStyle = 0;
float currentHue = 0;


class FractalPiece {
  ArrayList<FractalPiece> children = new ArrayList<FractalPiece>();
  FractalPiece parent;
  PVector pos = new PVector();
  float size = 0;
  float angle = 0;
  boolean renderable = false;
  int drawStyle = 0;
  
  FractalPiece(float sizeInput) {
    this.size = sizeInput;
  }
  
  /**
   * Apply its world position and displays it.
   */
  void draw() {
    // Generate a color
    float hue = max(0, random(currentHue-10, currentHue+10) ); // Script will crash if value is below 0
    float alpha = random(50, 100);
    color currentColor = color(hue, 100, 100, alpha);
    
    // Determine draw style
    if (drawFill) {
      noStroke();
      fill(currentColor);
    } else {
      noFill();
      stroke(currentColor);
    }
    
    pushMatrix();
    
    // Collect this fractal's hierarchy
    ArrayList<FractalPiece> fractalHierarchy = new ArrayList<FractalPiece>();
    
    FractalPiece parentFractal = this.parent;
    while (parentFractal != null) {
      fractalHierarchy.add(0, parentFractal);
      parentFractal = parentFractal.parent;
    }
    
    // Work down the hierarchy and each parent's transformations
    for (FractalPiece fractal : fractalHierarchy) {
      rotate(fractal.angle);
      translate(fractal.pos.x, fractal.pos.y);
    }
    
    // Move out the fractal so it rests along side its parent
    if (this.parent != null) {
      this.pos.x = (this.size + this.parent.size) / 2;
    }
    
    rotate(this.angle);
    translate(this.pos.x, this.pos.y);
    
    if (this.renderable) {
      int blurCount = 4;
      float sizeMult = 0.5;
      float blurAlpha = random(20, 60);
      
      // Loop through a few times to get a blur effect
      for (int i = 0; i < blurCount; i++) {
        if (drawFill) {
          fill(color(hue, 100, 100, blurAlpha));
        } else {
          stroke(color(hue, 100, 100, blurAlpha));
        }
        
        switch(this.drawStyle) {
          case 0:
            ellipse(0, 0, this.size*sizeMult, this.size*sizeMult);
            break;
          case 1:
            rect(0, 0, this.size*sizeMult, this.size*sizeMult);
            break;
          case 2:
            triangle(-this.size*sizeMult, this.size*sizeMult, 0, -this.size*sizeMult, this.size*sizeMult, this.size*sizeMult);
            break;
          case 3:
            quad(-this.size*sizeMult, 0, 0, this.size*sizeMult, this.size*sizeMult, 0, 0, -this.size*sizeMult);
            break;
        }
        
        sizeMult /= 0.85;
        alpha *= 0.1;
      }
    }
    
    popMatrix();
  }
  
  /**
   * Adds new fractals to itself that will orbit it.
   * Args:
   *   fractalCount: The number of new children to add.
   * Returns:
   *   A list of the new fractals.
   */
  ArrayList<FractalPiece> addChildren(int fractalCount) {
    ArrayList<FractalPiece> newChildren = new ArrayList<FractalPiece>();
    
    float newSize = this.size / 2;
    
    for (int i = 0; i < fractalCount; i++) {
      // Create a new fractal with its own starting angle
      FractalPiece newFractal = new FractalPiece(newSize);
      newFractal.parent = this;
      float startAngle = radians( (360/fractalCount)*(i+1) );
      newFractal.angle = startAngle;
      this.children.add(newFractal);
      newChildren.add(newFractal);
    }
    
    return newChildren;
  }
}


void setup() {
  // Fill in data to determine the fractals' structure
  Integer[] fractal1 = {8, 2};
  Integer[] fractal2 = {8, 3};
  Integer[] fractal3 = {7, 4};
  Integer[] fractal4 = {7, 5};
  Integer[] fractal5 = {6, 6};
  Integer[] fractal6 = {6, 7};
  Integer[] fractal7 = {5, 8};
  
  fractalData.put(0, fractal1);
  fractalData.put(1, fractal2);
  fractalData.put(2, fractal3);
  fractalData.put(3, fractal4);
  fractalData.put(4, fractal5);
  fractalData.put(5, fractal6);
  fractalData.put(6, fractal7);
  
  size(750, 750);
  rectMode(CENTER);
  background(0);
}


void draw() {
  if (currentNestedIndex == 0) { frameRate(9); }
  
  // Get current fractal's data
  Integer[] data = fractalData.get(currentIndex);
  int maxNestedCount = data[0];
  int childCount = data[1];
  
  // Stop fractal and go to the next one if it reached its max count
  if (currentNestedIndex > maxNestedCount-1) {    
    frameRate(2); // Cheap trick to get a delay in javascript mode 
    nextFractal();
    return;
  }
  
  // Display tip
  colorMode(RGB, 255);
  fill(0, 150);
  rect(0, 0, width*2, height*2);
  drawTip();
  
  // Create level of fractal and draw it
  colorMode(HSB, 100);
  allFractals.clear();
  createFractal(currentNestedIndex, childCount, currentDrawStyle);
  currentNestedIndex += 1;
  
  for (FractalPiece p : allFractals) { p.draw(); }
}


void nextFractal() {
  currentNestedIndex = 0;
  currentDrawStyle = int( random(0, 4) );
  currentHue = random(0, 100);
  currentIndex += 1;
  if (currentIndex > fractalData.size()-1) { currentIndex = 0; }
}


void keyPressed() {
  drawFill = ! drawFill;
}


/** Displays control tips on top of the screen. */
void drawTip() {
  textSize(11);
  textAlign(CENTER);
  fill(255);
  String tip = "Press any key to swtich between fill and wireframe.";
  text(tip, width/2, 30);
}


/**
 * Creates a new fractal.
 * Args:
 *   nestedCount: The amount of levels of fractals to create.
 *   childCount: The amount of children a fractal should have.
 *   drawStyle: 0=ellipse, 1=rect, 2=triangle, 3=diamond.
 */
void createFractal(int nestedCount, int childCount, int drawStyle) {
  allFractals.clear();
  
  // Create the first fractal in the window's center
  FractalPiece masterFractal = new FractalPiece(200);
  masterFractal.pos.set(width/2, height/2);
  
  ArrayList<FractalPiece> newFractals = new ArrayList<FractalPiece>();
  newFractals.add(masterFractal);
  
  for (int i = 0; i < nestedCount; i++) {
    ArrayList<FractalPiece> tempChildren = new ArrayList<FractalPiece>();
    
    for (FractalPiece p : newFractals) {
      ArrayList<FractalPiece> children = p.addChildren(childCount);
      tempChildren.addAll(children);
    }
    
    if (i == nestedCount-2) {
      for (FractalPiece p : tempChildren) {
        p.renderable = true;
        p.drawStyle = drawStyle;
      }
    }
    
    allFractals.addAll(newFractals);
    
    newFractals.clear();
    newFractals = tempChildren;
  }
}

