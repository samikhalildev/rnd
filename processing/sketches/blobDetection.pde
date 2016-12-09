PImage img;
ArrayList<Blob> blobs = new ArrayList<Blob>();
float brightThreshold = 80;
float distanceThreshold = 20;
ArrayList<float[]> colors = new ArrayList<float[]>();


class Blob {
  color blobColor;
  ArrayList<PVector> points = new ArrayList<PVector>();
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
          //println(recordDist);
        } else {
          if (colorDist < recordDist) {
            recordIndex = i;
            recordDist = colorDist;
          }
        }
      }
      
      float[] colorChamp = colors.get(recordIndex);
      color useColor = color(colorChamp[0], colorChamp[1], colorChamp[2]);
      
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
  
  colors.add(new float[] {127, 0, 0}); // red
  colors.add(new float[] {0, 127, 0}); // green
  colors.add(new float[] {0, 0, 127}); // blue
  colors.add(new float[] {127, 127, 0}); // yellow
  colors.add(new float[] {127, 50, 0}); // orange
  colors.add(new float[] {127, 0, 127}); // purple
  colors.add(new float[] {-25, -25, -25}); // black
  colors.add(new float[] {280, 280, 280}); // white
  
  img = loadImage("portrait1.jpg");
  img.loadPixels();
  
  saturateImage(img, 3);
  
  int[][] processed = new int[width][height];
  
  for (int y = 0; y < img.height; y+=3) {
    for (int x = 0; x < img.width; x+=3) {
      int index = x + y * img.width;
      
    } 
  }
}


void draw() {
  //image(img, 0, 0);
}
