/*
 * Marker.pde - animated makers.
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
final int REMAIN = 3600000;  // Don't forget to change the text in "PostalCodes.draw()"...

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
    int elapsed = millis() - start;

    pushStyle();
    
    if (elapsed < DURATION) {
      /* Start with an animated "explosion"... */
      int opacity = elapsed <= DURATION - FADE ? 255 : round(map(DURATION - elapsed, FADE, 0, 255, 0));
      float radius = map(sqrt(2*elapsed*DURATION - sq(elapsed)), 0, DURATION, 0, MAX_RADIUS);
      
      noStroke();
      fill(INNER_COLOR, opacity);
    
      ellipse(this.x, this.y, radius, radius);
    
      stroke(OUTER_COLOR, opacity);
      strokeWeight(radius/3);
      noFill();
    
      ellipse(this.x, this.y, radius*2, radius*2);
    } else {
      /* Then stay for the remaining time as a simple marker... */
      noStroke();
      fill(INNER_COLOR, 128);
      
      ellipse(this.x, this.y, MAX_RADIUS/4, MAX_RADIUS/4);
    }
    
    popStyle();
  }
  
  public boolean finished() {
    return millis() - start > REMAIN;
  }
}


/* EOF - Marker.pde */
