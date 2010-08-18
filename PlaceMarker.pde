/*
 * Marker.pde - animated markers.
 *
 * Copyright (c) 2010 Carlos Rodrigues <cefrodrigues@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


/* Initial animation (times in milliseconds)... */
final int DURATION = 3000;
final int FADE = 500;
final int MAX_RADIUS = 30;

/* Time on screen (milliseconds)... */
final int REMAIN = 3600000;

/* Marker colors... */
final color INNER_COLOR = #d72f28;
final color OUTER_COLOR = #379566;


public class PlaceMarker {
  private int start;
  private int x;
  private int y;
  
  public PlaceMarker(int x, int y) {
    this.start = millis();
    this.x = x;
    this.y = y;
  }

  public void draw() {
    if (millis() < this.start + DURATION) {
      this.animate();  // Begin with an animated "explosion"...
    } else {
      this.stay();     // Then stay as a simple marker...
    }
  }
  
  public boolean finished() {
    return millis() - this.start > REMAIN;
  }
  
  private void animate() {
    pushStyle();

    int elapsed = millis() - this.start;
        
    float opacity = elapsed <= DURATION - FADE ? 255 : map(DURATION - elapsed, FADE, 0, 255, 0);
    float radius = map(sqrt(2*elapsed*DURATION - sq(elapsed)), 0, DURATION, 0, MAX_RADIUS);
    
    noStroke();
    fill(INNER_COLOR, opacity);
    
    ellipse(this.x, this.y, radius, radius);
    
    stroke(OUTER_COLOR, opacity);
    strokeWeight(radius/3.0);
    noFill();
    
    ellipse(this.x, this.y, radius*2, radius*2);

    popStyle();
  }
  
  private void stay() {
    pushStyle();

    noStroke();
    fill(INNER_COLOR, 128);
    
    ellipse(this.x, this.y, MAX_RADIUS/4.0, MAX_RADIUS/4.0);
    
    stroke(OUTER_COLOR, 128);
    strokeWeight(MAX_RADIUS/8.0);
    noFill();
    
    ellipse(this.x, this.y, MAX_RADIUS/2.0, MAX_RADIUS/2.0);

    popStyle();
  }
}


/* EOF - Marker.pde */
