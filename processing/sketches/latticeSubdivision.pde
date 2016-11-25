/*
Bin-Lattice Spatial Subdivision
 Move the mouse to activate different cells, and mouse click to randomize all positions of the particles. Press up & down arrow keys to change the resoution.
 Splits up the window into a grid, and each particle is stored into a cell. Instead of calling on each particle, it will call the particles that are in the active cell to try and save processing time. This could be more robust if it includes the neighbouring cells.
 
 Author: Jason Labbe
 Site: jasonlabbe3d.com
 
 For more info check out shiffman.net/
 */

int resolution; // A lower value works best so there aren't too many cells to track
int targetCount = 100;

float resolutionWidth;
float resolutionHeight;
int columnCount;
ArrayList<ArrayList<particle[]>> cells = new ArrayList<ArrayList<particle[]>>(); // 2D arrayList for each cell to keep track of what particles are in it
ArrayList<particle> targets = new ArrayList<particle>();
particle source = addParticle(false);

void setup() {
  size(500, 500);

  // Create particles
  for (int i = 0; i < targetCount; i++) {
    particle newTarget = addParticle(true);
    newTarget.pos[0] = int( random(0, width) );
    newTarget.pos[1] = int( random(0, height) );
  }

  // Setup grid
  updateResolution(4);
}

// Our particle class that will help manage themselves
class particle {
  int[] pos = new int[2];
  float size = 20;
  int gridIndex = -1;

  // Finds out where it belongs in the grid
  int getGridIndex() {
    int column = int(pos[0] / resolutionWidth);
    int row = int(pos[1] / resolutionHeight);
    return ( column + row * columnCount);
  }

  // Updates cells array to its current position
  void updateCell() {
    int newGridIndex = getGridIndex();

    // If gridIndex changed, then remove it from previous cell
    if (newGridIndex != gridIndex) {
      if (gridIndex > -1) {
        int cellIndex = cells.get(gridIndex).indexOf(this);
        if (cellIndex >= 0) {
          cells.get(gridIndex).remove(cellIndex);
        }
      }
      // Update cells array with new index
      ArrayList cell = cells.get(newGridIndex);
      cell.add(this);
      gridIndex = newGridIndex;
    }
  }
}

// Function to add a particle to the scene
particle addParticle(boolean append) {
  particle newParticle = new particle();
  if (append) {
    targets.add(newParticle);
  }
  return newParticle;
}

// Updates particles to work with a new resolution
void updateResolution(int res) {
  cells.clear();
  resolution = res;
  resolutionWidth = width / float(resolution);
  resolutionHeight = height / float(resolution);
  columnCount = int(width / resolutionWidth); 

  int rowCount = int(height / resolutionHeight);
  for (int i = 0; i < columnCount*rowCount; i++) {
    cells.add(new ArrayList<particle[]>());
  }
  source.gridIndex = -1;
  source.updateCell();
  for (particle target : targets) {
    target.gridIndex = -1;
    target.updateCell();
  }
}

void draw() {
  // Draw grid
  strokeWeight(1);
  int currentCellIndex = source.gridIndex;
  for (int x = 0; x < resolution; x++) {
    for (int y = 0; y < resolution; y++) {
      fill(255);
      int cellIndex = x + y * columnCount;
      if (cellIndex == currentCellIndex) {
        fill(200, 200, 200);
      }
      rect(x * resolutionWidth, y * resolutionHeight, resolutionWidth, resolutionHeight);
    }
  }

  // Draw particles
  strokeWeight(2);
  for (particle target : targets) {
    if (cells.get(currentCellIndex).contains(target) ) {
      fill(255, 255, 0);
    } else {
      fill(0, 255, 0);
    }
    ellipse(target.pos[0], target.pos[1], target.size, target.size);
  }  

  fill(255, 0, 0);
  ellipse(source.pos[0], source.pos[1], source.size, source.size);
}

// Update active cell
void mouseMoved() {
  source.pos[0] = mouseX;
  source.pos[1] = mouseY;
  source.updateCell();
  for (particle target : targets) {
    target.updateCell();
  }
}

// Randomize all positions
void mousePressed() {
  for (particle target : targets) {
    target.pos[0] = int( random(0, width) );
    target.pos[1] = int( random(0, height) );
    target.updateCell();
  }
}

// Change resolution
void keyPressed() {
  int newResolution = resolution;
  if (keyCode == 38) {
    newResolution += 1;
  } else if (keyCode == 40) {
    newResolution -= 1;
  }
  newResolution = max(min(10, newResolution), 2);
  updateResolution(newResolution);
}


