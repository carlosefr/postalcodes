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


/*
 * Processing an SVG is a bit slow and consumes some memory. This leads
 * to stuttering in the animation because of GC activity and sometimes
 * excessive memory usage and very long pauses. So, we limit the number
 * of possible flake shapes and pre-generate them all beforehand.
 */
PImage[] shapes = new PImage[32];


public class SnowFlake {
  private float x;
  private float y;
  
  private int start;
  private float wind;
  
  private PImage flake;
  
  public SnowFlake(int x) {
    this.x = x;
    this.y = 0;
    this.wind = 0;

    // We'll use this as a random seed of sorts...    
    this.start = x;
    
    // The first flake generates all possible flake shapes...
    if (shapes[0] == null) {
      PShape svg = loadShape("snowflake.svg");
      svg.disableStyle();
      
      // The snow flakes won't be bigger than this...
      float maxRadius = width / 60.0;

      for (int i = 0; i < shapes.length; i++) {  
        float radius = lerp(0.25, 1.0, noise(i, frameCount)) * maxRadius;
        
        PGraphics pg = createGraphics(int(radius*2) + 4, int(radius*2) + 4, JAVA2D);
        
        pg.beginDraw();
    
        pg.smooth();
        pg.shapeMode(CENTER);
    
        pg.fill(#ffffff);
        pg.stroke(#aaaaaa);
        pg.translate(pg.width/2.0, pg.height/2.0);
        pg.rotate(random(TWO_PI));
        
        // Maintain the shape aspect ratio...
        pg.shape(svg, 0, 0, (svg.width < svg.height ? svg.width/svg.height : 1.0) * pg.width,
                            (svg.width > svg.height ? svg.height/svg.width : 1.0) * pg.height);
    
        pg.endDraw();
        
        shapes[i] = (PImage)pg;
      }
    }
    
    // Choose one of the pre-generated flake shapes...
    this.flake = shapes[round(random(0, shapes.length - 1))];
  }
  
  public void setWind(float wind) {
    this.wind = wind;
  }
  
  public boolean finished() {
    return this.y >= height;
  }
  
  public void update() {
    // Falling motion (with a tiny influence of weight)...
    this.x += 4.0 * (this.wind / (this.flake.width/2.0));
    this.y += 2.0 + (this.flake.width/2.0 * 0.05);

    // Introduce a little turbulence to the falling motion...
    this.x += sin((this.start + frameCount) * 0.1) * 0.4;
  }
  
  public void draw() {
    if (this.x + this.flake.width/2.0 < 0 || this.x - this.flake.width/2.0 > width) {
      // The flake is off the screen, do nothing...
      return;
    }
    
    // Just place the cached flake on screen...
    image(this.flake, this.x - this.flake.width/2.0, this.y - this.flake.height/2.0);
  }
}


/* EOF - SnowFlake.pde */
