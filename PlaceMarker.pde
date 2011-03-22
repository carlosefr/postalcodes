/*
 * PlaceMarker.pde - animated markers.
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


// Initial animation (times in milliseconds)...
final int DURATION = 3000;
final int FADE = 500;

// The radius for the inner circle...
final int MAX_RADIUS = 50;
final int STATIC_RADIUS = 10;

// Time on screen (milliseconds)...
final int REMAIN = 3600000;

// The opacity for non-animated markers...
final float STATIC_OPACITY = 128;


public class PlaceMarker {
  private int start;
  private color innerColor;
  private color outerColor;
  private color placeColor;
  
  public int x;
  public int y;
  public String place;
  
  public PlaceMarker(int x, int y, String place) {
    this.start = millis();
    this.x = x;
    this.y = y;
    this.place = place;
    
    // Get the colors from the global properties...
    this.innerColor = colors.get("INNER_COLOR");
    this.outerColor = colors.get("OUTER_COLOR");
    this.placeColor = colors.get("PLACE_COLOR");
  }

  public void draw() {
    if (this.exploding()) {
      this.explode();  // Begin with an animated "explosion"...
    } else {
      this.stay();     // Then stay as a simple marker...
    }
  }

  public boolean exploding() {
    return millis() < this.start + DURATION;
  }
  
  public boolean finished() {
    return millis() - this.start > REMAIN;
  }
  
  private void drawMarker(float radius, float opacity) {
    pushStyle();
    pushMatrix();

    translate(this.x, this.y);
  
    // Inner circle...
    noStroke();
    fill(this.innerColor, opacity);
    ellipse(0, 0, radius, radius);

    // Outer circle...        
    float outerWidth = radius/3.0;
    
    if (glRendererEnabled()) {
      // The OpenGL renderer doesn't support stroke weights > 1...
      noStroke();
      fill(this.outerColor, opacity);

      // Higher resolution, more triangles...
      int resolution = round(radius * 3);
      
      beginShape(TRIANGLE_STRIP);
      
      for (int i = 0; i < resolution + 3; i++) {
        float angle = (TWO_PI / resolution) * i;
        float r = radius + (outerWidth/2.0) * (i % 2 == 0 ? 1 : -1);
        
        vertex(r*cos(angle), r*sin(angle));
      }
      
      endShape();
    } else {
      // Fortunately, the other renderers do...
      stroke(this.outerColor, opacity);
      strokeWeight(outerWidth);
      noFill();
      
      ellipse(0, 0, radius*2, radius*2);
    }
    
    popMatrix();
    popStyle();
  }
  
  private void explode() {
    int elapsed = millis() - this.start;
        
    float opacity = elapsed <= DURATION - FADE ? 255 : map(DURATION - elapsed, FADE, 0, 255, 0);
    float radius = map(sqrt(2*elapsed*DURATION - sq(elapsed)), 0, DURATION, 0, MAX_RADIUS);
    
    this.drawMarker(radius, opacity);

    pushStyle();

    textFont(eventFont);
    textAlign(RIGHT);
    fill(this.placeColor, opacity);
    text(this.place, this.x - radius*cos(radians(15)) - 10, this.y - radius*sin(radians(15)) - 10);

    popStyle();
  }
  
  private void stay() {
    this.drawMarker(STATIC_RADIUS, STATIC_OPACITY);
  }
}


/* EOF - PlaceMarker.pde */
