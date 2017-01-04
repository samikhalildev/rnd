// Displays the slider's label and value.
function SliderLayout(label, minValue, maxValue, defaultValue, steps, posx, posy) {
  
  this.label = label;
  this.slider = createSlider(minValue, maxValue, defaultValue, steps);
  this.slider.position(posx, posy);
  
  this.display = function() {
    var sliderPos = this.slider.position();
    
    noStroke();
    fill(255);
    textSize(15);
    text(this.label, sliderPos.x, sliderPos.y-10);

    fill(255, 255, 0);
    text(this.slider.value(), sliderPos.x+this.slider.width+10, sliderPos.y+10);
  }
}