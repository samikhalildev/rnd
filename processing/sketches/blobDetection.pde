/*
To do:
   - Merge small blobs.
   - Method to get blob by pixel's position.
   - Clean up code!
*/

PImage img;
ArrayList<Blob> blobs = new ArrayList<Blob>();

ArrayList<float[]> colors = new ArrayList<float[]>();
int[][] colorIndexes;
int[][] processed;

class Blob {
  color blobColor;
  ArrayList<PVector> points = new ArrayList<PVector>();
}


class Coords {
  int x;
  int y;
  
  Coords(int _x, int _y) {
    this.x = _x;
    this.y = _y;
  }
}


void addBlob(float x, float y, color blobColor) {
  Blob newBlob = new Blob();
  newBlob.points.add(new PVector(x, y));
  newBlob.blobColor = blobColor;
  blobs.add(newBlob);
}


float distSquared(float x1, float y1, float x2, float y2) {
  return (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1);
}


float distSquared(float x1, float y1, float z1, float x2, float y2, float z2) {
  return (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) + (z2-z1)*(z2-z1);
}


// Forces pixels to their closest color
void saturateImage(PImage pImg, int steps) {  
  for (int y = 0; y < pImg.height; y+=steps) {
    for (int x = 0; x < pImg.width; x+=steps) {
      int index = x + y * pImg.width;
      
      color pixelColor = pImg.pixels[index];
      
      float r = red(pixelColor);
      float g = green(pixelColor);
      float b = blue(pixelColor);
      
      float recordDist = 0;
      int recordIndex = -1;
      
      for (int i = 0; i < colors.size(); i++) {
        float[] checkColor = colors.get(i);
        
        float colorDist = distSquared(r, g, b, checkColor[0], checkColor[1], checkColor[2]);
        
        if (recordIndex == -1) {
          recordIndex = i;
          recordDist = colorDist;
        } else {
          if (colorDist < recordDist) {
            recordIndex = i;
            recordDist = colorDist;
          }
        }
      }
      
      float[] colorChamp = colors.get(recordIndex);
      color useColor = color(colorChamp[0], colorChamp[1], colorChamp[2]);
      
      colorIndexes[x][y] = recordIndex;
      pImg.pixels[index] = color(255, 0, 0);
      
      // Un-comment to display
      stroke(useColor);
      strokeWeight(3);
      point(x, y);
    }
  }
  
  img.updatePixels();
}


void setup() {
  size(950, 700);
  
  background(255);
  
  int method = 1;
  
  if (method == 1) {
    int totalSteps = 6;
    for (int i = 0; i < totalSteps; i++) {
      float hue = map(i, 0, totalSteps, 0, 360);
      
      colorMode(HSB, 360);
      color newColor1 = color(hue, 360, 360);
      color newColor2 = color(hue, 360, 180);
      color newColor3 = color(hue, 360, 90);
      colorMode(RGB, 255);
      
      colors.add(new float[] {red(newColor1), green(newColor1), blue(newColor1)});
      colors.add(new float[] {red(newColor2), green(newColor2), blue(newColor2)});
      colors.add(new float[] {red(newColor3), green(newColor3), blue(newColor3)});
    }
    
    colors.add(new float[] {-25, -25, -25}); // black
    colors.add(new float[] {280, 280, 280}); // white
  } else {
    colors.add(new float[] {128, 0, 0}); // red
    colors.add(new float[] {128, 43, 0}); // dark orange
    colors.add(new float[] {128, 85, 0}); // orange
    colors.add(new float[] {128, 128, 0}); // yellow
    colors.add(new float[] {85, 128, 0}); // yellow-green
    colors.add(new float[] {43, 128, 0}); // dark-green
    colors.add(new float[] {0, 128, 0}); // green
    colors.add(new float[] {0, 128, 42}); // orange
    colors.add(new float[] {0, 128, 85}); // orange
    colors.add(new float[] {0, 128, 128}); // orange
    colors.add(new float[] {0, 85, 128}); // orange
    colors.add(new float[] {0, 42, 128}); // orange
    colors.add(new float[] {0, 0, 128}); // orange
    colors.add(new float[] {43, 0, 128}); // orange
    colors.add(new float[] {85, 0, 128}); // orange
    colors.add(new float[] {128, 0, 128}); // orange
    colors.add(new float[] {128, 0, 85}); // orange
    colors.add(new float[] {128, 0, 43}); // orange
    colors.add(new float[] {-25, -25, -25}); // black
    colors.add(new float[] {280, 280, 280}); // white
  }
  
  img = loadImage("twaf.jpg");
  img.loadPixels();
  
  colorIndexes = new int[img.width][img.height];
  
  saturateImage(img, 3);
  
  processed = new int[img.width][img.height];
  
  for (int y = 0; y < img.height; y+=3) {
    for (int x = 0; x < img.width; x+=3) {
      // Skip any pixels that already belong to a blob
      if (processed[x][y] == 1) {
        continue;
      }
      
      int index = x + y * img.width;
      
      int colorIndex = colorIndexes[x][y];
      
      float[] colorValues = colors.get(colorIndex);
      color currentColor = color(colorValues[0], colorValues[1], colorValues[2]);
      
      addBlob(x, y, currentColor);
      
      ArrayList<Coords> coordsToResolve = getVertNeighbors(new Coords(x, y), 3);
      int[][] resolved = new int[img.width][img.height];
      processed[x][y] = 1;
      resolved[x][y] = 1;
      
      while(coordsToResolve.size() > 0) {
        ArrayList<Coords> newCoords = new ArrayList<Coords>();
        
        for (int i = coordsToResolve.size()-1; i > -1; i--) {
          Coords c = coordsToResolve.get(i);
          coordsToResolve.remove(i);
          
          if (resolved[c.x][c.y] == 0) {
            if (colorIndexes[c.x][c.y] == colorIndex) {
              processed[c.x][c.y] = 1;
              blobs.get(blobs.size()-1).points.add(new PVector(c.x, c.y));
              
              ArrayList<Coords> vertNeighbors = getVertNeighbors(c, 3);
              
              for (Coords v : vertNeighbors) {
                if (resolved[v.x][v.y] == 0) {
                  newCoords.add(v);
                }
              }
            }
          }
          
          resolved[c.x][c.y] = 1;
        }
        
        if (newCoords.size() > 0) {
          coordsToResolve.addAll(newCoords);
        }
      }
    }
  }
  
  
  //println(blobs.size());
}


ArrayList<Coords> getVertNeighbors(Coords coords, int steps) {
  Coords upLeft = new Coords(coords.x-steps, coords.y-steps);
  Coords up = new Coords(coords.x, coords.y-steps);
  Coords upRight = new Coords(coords.x+steps, coords.y-steps);
  Coords downLeft = new Coords(coords.x-steps, coords.y+steps);
  Coords down = new Coords(coords.x, coords.y+steps);
  Coords downRight = new Coords(coords.x-steps, coords.y+steps);
  Coords left = new Coords(coords.x-steps, coords.y);
  Coords right = new Coords(coords.x+steps, coords.y);
  
  ArrayList<Coords> finalNeighbors = new ArrayList<Coords>();
  
  Coords[] neighbors = {upLeft, up, upRight, downLeft, down, downRight, left, right};
  
  for (int i = 0; i < neighbors.length; i++) {
    if (neighbors[i].x < 0 || neighbors[i].x >= img.width) {
      continue;
    }
    
    if (neighbors[i].y < 0 || neighbors[i].y >= img.height) {
      continue;
    }
    
    if (processed[neighbors[i].x][neighbors[i].y] == 1) {
      continue;
    }
    
    finalNeighbors.add(neighbors[i]);
  }
  
  return finalNeighbors;
}


void draw() {
  /*colorMode(HSB, 360);
  
  for (int i = 0; i < blobs.size(); i++) {
    if (blobs.get(i).points.size() < 20) {
      continue;
    }
    
    //stroke(map(i, 0, blobs.size(), 0, 360), 255, 255);
    stroke(random(0, 360), 255, 255);
    strokeWeight(3);
    for (PVector p : blobs.get(i).points) {
      point(p.x, p.y);
    }
  }
  
  colorMode(RGB, 255);*/
}
