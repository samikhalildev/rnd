/*
Conway's Game of Life

Controls:
- Mouse click to reset

Author: Jason Labbe
Site: jasonlabbe3d.com
*/


// Global properties
int GRID_RESOLUTION = 40; // Change this to affect the number of cells
int R_VALUE = 82;
float CELL_SIZE;

Cell[] cells = new Cell[(GRID_RESOLUTION * GRID_RESOLUTION)];
boolean[] cellsData = new boolean[(GRID_RESOLUTION * GRID_RESOLUTION)]; // Array to store values without immediately affecting cells


class Cell {
  int column;
  int row;
  int index;
  boolean isAlive = false;
  float fillValue = 255.0;
  
  // Randomly sets itself as dead or alive
  void setRandomState() {
    boolean bool = (random(1) > 0.8); // 20% chance to be alive
    this.isAlive = bool;
    if (this.isAlive) {
      this.fillValue = 0;
    } else {
      this.fillValue = 255.0;
    }
  }
  
  // Function to get a count of alive neighbouring cells
  int getNeighbours() {
    // Get surrounding cells indexes
    int leftIndex = this.index - 1;
    int rightIndex = this.index + 1;
    int upIndex = int(this.index - GRID_RESOLUTION);
    int bottomIndex = int(this.index + GRID_RESOLUTION);
    int upLeftIndex = int(this.index - GRID_RESOLUTION) - 1;
    int upRightIndex = int(this.index - GRID_RESOLUTION) + 1;
    int bottomLeftIndex = int(this.index + GRID_RESOLUTION) - 1;
    int bottomRightIndex = int(this.index + GRID_RESOLUTION) + 1;
    
    int aliveCount = 0;
    
    // Add +1 to alive count for any valid cell that is alive
    if (upLeftIndex > -1 && cells[upLeftIndex].row == this.row-1 ) {
       if (cells[upLeftIndex].isAlive) { aliveCount += 1; }
    }
    
    if (upIndex > -1) {
      if (cells[upIndex].isAlive) { aliveCount += 1; }
    }
    
    if (upRightIndex > -1 && cells[upRightIndex].row != this.row) {
      if (cells[upRightIndex].isAlive) { aliveCount += 1; }
    }
    
    if (leftIndex > -1 && cells[leftIndex].row == this.row) {
      if (cells[leftIndex].isAlive) { aliveCount += 1; }
    }
    
    if (rightIndex < cells.length && cells[rightIndex].row == this.row) {
      if (cells[rightIndex].isAlive) { aliveCount += 1; }
    }
    
    if (bottomLeftIndex < cells.length && cells[bottomLeftIndex].row != this.row) {
      if (cells[bottomLeftIndex].isAlive) { aliveCount += 1; }
    }
    
    if (bottomIndex < cells.length ) {
      if (cells[bottomIndex].isAlive) { aliveCount += 1; }
    }
    
    if (bottomRightIndex < cells.length && cells[bottomRightIndex].row == this.row+1) {
      if (cells[bottomRightIndex].isAlive) { aliveCount += 1; }
    }
    
    return aliveCount;
  }
  
  void draw() {
     // Have fill value slowly raise up or down to get a fading effect
     float fillRate = 80.0;
     if (this.isAlive) {
       this.fillValue -= fillRate;
     } else {
       this.fillValue += fillRate;
     }
     this.fillValue = min( max(this.fillValue, 0), 255.0);
     fill(this.fillValue);
     rect(this.column*CELL_SIZE, this.row*CELL_SIZE, CELL_SIZE, CELL_SIZE);
  }
}


// Goes through each cell and figures out if it should be dead or alive
// Alive state isn't changed immediately, so it won't affect the rest of the cells choice
void nextIteration() {
  for (int i = 0; i < cells.length; i++) {
    Cell cell = cells[i];
    int aliveCount = cell.getNeighbours(); // Get count of neighbouring cells that are alive
    if (cell.isAlive) {
      boolean keepAlive = (aliveCount == 2 || aliveCount == 3); // Stay alive if we are not over 3 and under 2 alive cells
      cellsData[i] = keepAlive;
    } else {
      boolean setAlive = (aliveCount == 3); // Set cell as alive if there is 3 alive cells
      cellsData[i] = setAlive;
    }
  }  
}


void setup() { 
  size(400, 400);
  CELL_SIZE = width / GRID_RESOLUTION;
  
  // Initialize cells list
  for (int y = 0; y < GRID_RESOLUTION; y++) {
    for (int x = 0; x < GRID_RESOLUTION; x++) {
       Cell newCell = new Cell();
       newCell.column = x;
       newCell.row = y;
       newCell.index = (x + y * GRID_RESOLUTION);
       newCell.setRandomState();
       cells[newCell.index] = newCell;
       cellsData[newCell.index] = false;
    }
  }
}


void draw() {
  // Step through iteration
  nextIteration();
  
  // Draw cells
  stroke(255);
  strokeWeight(0);
  for (int i = 0; i < cells.length; i++) {
    cells[i].isAlive = cellsData[i]; // Finally set alive property
    cells[i].draw();
  }
  //delay(50);
}


void mousePressed() {
  for (int i = 0; i < cells.length; i++) {
    cells[i].setRandomState();
  }
}