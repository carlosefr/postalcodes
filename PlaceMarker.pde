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
final int MAX_RADIUS = 25;
final int STATIC_RADIUS = 5;

// Time on screen (milliseconds)...
final int REMAIN = 3600000;

// The opacity for non-animated markers...
final float STATIC_OPACITY = 128;

// The static marker, cached...
PImage marker = null;


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

  private void drawMarkerOpenGL(float radius, float opacity) {
    pushMatrix();
    translate(this.x, this.y);

    pushStyle();

    // The OpenGL renderer doesn't support stroke weights > 1...
    noStroke();

    // Higher resolution, more triangles...
    int res = 24 * round(sqrt(radius));

    // Inner circle...
    fill(this.innerColor, opacity);
    
    beginShape(TRIANGLE_STRIP);
    for (int i = 0; i <= res; i++) {
      float angle = (TWO_PI / res) * i;
      float r = (i % 2 == 0 ? radius : 0);
      
      vertex(r*cos(angle), r*sin(angle));
    }
    endShape();

    // Outer circle...        
    fill(this.outerColor, opacity);

    float outerStroke = radius/1.5;
    float outerRadius = radius*2;
    
    beginShape(TRIANGLE_STRIP);
    for (int i = 0; i <= res + 1; i++) {
      float angle = (TWO_PI / res) * i;
      float r = (i % 2 == 0 ? 1 : -1) * (outerStroke/2.0) + outerRadius;
      
      vertex(r*cos(angle), r*sin(angle));
    }      
    endShape();

    popStyle();
    popMatrix();
  }

  private void drawMarkerJava2D(float radius, float opacity, PGraphics gfx, float x, float y) {
    gfx.beginDraw();
    gfx.smooth();
    
    gfx.pushStyle();

    // Inner circle...
    gfx.noStroke();
    gfx.fill(this.innerColor, opacity);
    gfx.ellipse(x, y, radius*2, radius*2);

    // Outer circle...
    gfx.noFill();      
    gfx.stroke(this.outerColor, opacity);
    gfx.strokeWeight(radius/1.5);
    gfx.ellipse(x, y, radius*4, radius*4);

    gfx.popStyle();
    gfx.endDraw();
  }

  private void explode() {
    int elapsed = millis() - this.start;
        
    float opacity = elapsed <= DURATION - FADE ? 255 : map(DURATION - elapsed, FADE, 0, 255, 0);
    float radius = map(sqrt(2*elapsed*DURATION - sq(elapsed)), 0, DURATION, 0, MAX_RADIUS);
    
    if (glRendererEnabled()) {
      this.drawMarkerOpenGL(radius, opacity);
    } else {
      // The Java2D method can also render on an image, but not here...
      this.drawMarkerJava2D(radius, opacity, g, this.x, this.y);
    }    

    pushStyle();

    textFont(eventFont);
    textAlign(RIGHT);
    fill(this.placeColor, opacity);
    text(this.place, this.x - 2*radius*cos(radians(15)) - 10, this.y - 2*radius*sin(radians(15)) - 10);

    popStyle();
  }
  
  private void stay() {
    // The static marker is only drawn once, and then cached...
    if (marker == null) {
      // See the "drawMarkerOpenGL" method for the source of this calculation...
      int sz = 2 * ceil(STATIC_RADIUS/3.0 + STATIC_RADIUS*2.0);

      PGraphics gfx = createGraphics(sz, sz, JAVA2D);
      this.drawMarkerJava2D(STATIC_RADIUS, STATIC_OPACITY, gfx, sz/2.0, sz/2.0);

      marker = (PImage)gfx;
    }

    // Just place the cached marker on screen...
    image(marker, this.x - marker.width/2.0, this.y - marker.height/2.0);
  }  
}


/* EOF - PlaceMarker.pde */
