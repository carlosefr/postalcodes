/*
 * SnowFlake.pde - a (simple) snow flake.
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


// The snow flake's vectorial shape...
PShape svg = null;


public class SnowFlake {
  private float x;
  private float y;
  
  private int start;
  private float radius;
  private float wind;
  
  private PImage flake;
  
  public SnowFlake(int x, float radius) {
    this.x = x;
    this.y = 0;
    this.radius = radius;
    this.wind = 0;

    // We'll use this as a random seed of sorts...    
    this.start = x;
    
    // The first flake loads the shape...
    if (svg == null) {
      svg = loadShape("snowflake.svg");
      svg.disableStyle();
    }
    
    // Draw the flake only once...        
    PGraphics pg = createGraphics(int(this.radius*2) + 4, int(this.radius*2) + 4, JAVA2D);
    
    pg.beginDraw();
    pg.smooth();
    pg.fill(#ffffff);
    pg.stroke(#aaaaaa);
    pg.translate(pg.width/2.0, pg.height/2.0);
    pg.rotate(random(TWO_PI));
    pg.shape(svg, -pg.width/2.0, -pg.height/2.0, pg.width, pg.height);
    pg.endDraw();
    
    this.flake = (PImage)pg;
  }
  
  public void setWind(float wind) {
    this.wind = wind;
  }
  
  public boolean finished() {
    return this.y >= height;
  }
  
  public void update() {
    // Falling motion (with a tiny influence of weight)...
    this.x += 4.0 * (this.wind / this.radius);
    this.y += 2.0 + (this.radius * 0.05);

    // Introduce a little turbulence to the falling motion...
    this.x += sin((this.start + frameCount) * 0.1) * 0.4;
  }
  
  public void draw() {
    if (this.x + this.radius < 0 || this.x - this.radius > width) {
      // The flake is off the screen, do nothing...
      return;
    }
    
    // Just place the cached flake on screen...
    image(this.flake, this.x - this.flake.width/2.0, this.y - this.flake.height/2.0);
  }
}


/* EOF - SnowFlake.pde */
