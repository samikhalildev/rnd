/*
Obj viewer

Reads data from an obj format and displays it.

Controls:
  - Drag left-click to rotate camera.
  - Drag middle-click to move camera.
  - Drag right-click to zoom.
  - "e" to toggle edges.
  - "p" to toggle points.
  - "f" to toggle faces.

To do:
  - Display mesh's stats.
  - Get lighting to work.
  - Support materials.

Author:
  Jason Labbe

Site:
  jasonlabbe3d.com
*/


Mesh mesh;

boolean showPoints = false;
boolean showEdges = true;
boolean showFaces = true;

PVector mouseClick = new PVector();

PVector rotStart = new PVector();
PVector posStart = new PVector();
PVector zoomStart = new PVector();

float rotx = 0;
float roty = 0;
float posx = 0;
float posy = 0;
float zoom = 0;


class Face {
  ArrayList<Integer> posIndexes;
  ArrayList<Integer> normalIndexes;
  
  Face(ArrayList<Integer> _posIndexes, ArrayList<Integer> _normalIndexes) {
    this.posIndexes = _posIndexes;
    this.normalIndexes = _normalIndexes;
  }
}


class Mesh {
  ArrayList<float[]> vertexes = new ArrayList<float[]>();
  ArrayList<float[]> vertexNormals = new ArrayList<float[]>();
  ArrayList<Face> faces = new ArrayList<Face>();
  PVector minPos = new PVector();
  PVector maxPos = new PVector();
  float offset = 0;
  
  void display() {
    pushMatrix();
    
    translate(width/2, height/2);
    translate(posx, posy, zoom);
    rotateY(radians(rotx));
    rotateX(radians(-roty));
    
    if (showEdges) {
      strokeWeight(1);
      stroke(200);
    } else {
      noStroke();
    }
    
    if (showFaces) {
      fill(100);
    } else {
      noFill();
    }
    
    float centerOffsetx = -this.offset*(this.minPos.x+this.maxPos.x)/2;
    float centerOffsety = -this.offset*(this.minPos.y+this.maxPos.y)/2;
    float centerOffsetz = -this.offset*(this.minPos.z+this.maxPos.z)/2;
    
    for (int i = 0; i < this.faces.size(); i++) {
      Face face = this.faces.get(i);
      
      beginShape();
      for (int x = 0; x < face.posIndexes.size(); x++) {
        int normalIndex = face.normalIndexes.get(x);
        float[] n = this.vertexNormals.get(normalIndex);
        normal(n[0], n[1], n[2]);
        
        int vertIndex = face.posIndexes.get(x);
        float[] pos = this.vertexes.get(vertIndex);
        vertex(pos[0]*this.offset+centerOffsetx, pos[1]*this.offset+centerOffsety, pos[2]*this.offset+centerOffsetz);
      }
      endShape();
    }
    
    if (showPoints) {
      strokeWeight(3);
      stroke(255, 255, 0);
      for (int i = 0; i < this.vertexes.size()-1; i++) {
        float[] pos = this.vertexes.get(i);
        point(pos[0]*this.offset+centerOffsetx, pos[1]*this.offset+centerOffsety, pos[2]*this.offset+centerOffsetz);
      }
    }
    
    popMatrix();
  }
  
  // Only works in processing.js
  void read(String path, boolean mirrorX, boolean mirrorY, boolean mirrorZ) {
    String lines[] = loadStrings(path);
    
    for (int j = 0; j < lines.length; j++) {
      String line = lines[j];
      
      if (line.startsWith("v ")) { // Get vertex positions
        String[] lineSplit = split(line, " ");
        
        float x = float(lineSplit[1]);
        float y = float(lineSplit[2]);
        float z = float(lineSplit[3]);
        
        if (mirrorX) {
          x = -x;
        }
        
        if (mirrorY) {
          y = -y;
        }
        
        if (mirrorZ) {
          z = -z;
        }
        
        if (this.vertexes.size() == 0) {
          this.minPos.set(x, y, z);
          this.maxPos.set(x, y, z);
        } else {
          this.minPos.x = min(x, this.minPos.x);
          this.minPos.y = min(y, this.minPos.y);
          this.minPos.z = min(z, this.minPos.z);
          this.maxPos.x = max(x, this.maxPos.x);
          this.maxPos.y = max(y, this.maxPos.y);
          this.maxPos.z = max(z, this.maxPos.z);
        }
        
        float[] vertPos = {x, y, z};
        this.vertexes.add(vertPos);
      } else if (line.startsWith("vn ")) { // Get vertex normals
        String[] lineSplit = split(line, " ");
        float[] vertNormals = {float(lineSplit[1]), float(lineSplit[2]), float(lineSplit[3])};
        this.vertexNormals.add(vertNormals);
      } else if (line.startsWith("f ")) { // Get face data
        String[] lineSplit = split(line, " ");
        
        ArrayList<Integer> posIndexes = new ArrayList<Integer>();
        ArrayList<Integer> normalIndexes = new ArrayList<Integer>();
        
        for (int i = 1; i < lineSplit.length; i++) {
          String[] valueSplit = split(lineSplit[i], "/");
          posIndexes.add(int(valueSplit[0])-1);
          normalIndexes.add(int(valueSplit[valueSplit.length-1])-1);
        }
        
        this.faces.add(new Face(posIndexes, normalIndexes));
      }
    }
    
    float modelHeight = dist(0, mesh.minPos.y, 0, mesh.maxPos.y);
    this.offset = (height-200)/modelHeight;
  }
}


void setup() {
  size(600, 600, P3D);
  
  mesh = new Mesh();
  String path = "dummy.txt";
  mesh.read(path, false, true, false);
}


void draw() {
  background(0);
  mesh.display();
}


void keyPressed() {
  if (keyCode == 69) {
    showEdges = ! showEdges;
  } else if (keyCode == 80) {
    showPoints = ! showPoints;
  } else if (keyCode == 70) {
    showFaces = ! showFaces;
  }
}


void mousePressed() {
  rotStart.set(rotx, roty);
  posStart.set(posx, posy);
  zoomStart.set(zoom, zoom);
  mouseClick.set(mouseX, mouseY);
}


void mouseDragged() {
  if (mouseButton == LEFT) {
    rotx = rotStart.x+(mouseX-mouseClick.x);
    roty = rotStart.y+(mouseY-mouseClick.y);
  } else if (mouseButton == CENTER) {
    posx = posStart.x+(mouseX-mouseClick.x);
    posy = posStart.y+(mouseY-mouseClick.y);
  } else if (mouseButton == RIGHT) {
    zoom = zoomStart.x+(mouseX-mouseClick.x)-(mouseY-mouseClick.y);
  }
}
