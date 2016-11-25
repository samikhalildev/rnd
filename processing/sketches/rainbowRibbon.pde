/*
Rainbow ribbon
   
Author: Jason Labbe
Site: jasonlabbe3d.com
*/
 
 
float middle;
 
void setup() {
  size(800, 200);
  colorMode(HSB, 100);
  middle = height/2;
}
 
void draw() {
  background(0);
  noStroke();
   
  for (int z = 0; z < 40; z++) {
    for (int x = 0; x < width; x+=2) {
      float wave = sin((frameCount+x+z*5)*0.025)*40;
      float bump = cos(x*0.05)*10;
      float y = middle+wave+bump;
      fill(z*2, 100, 100);
      ellipse(x, y, 1, 3);
    }
  }
}

