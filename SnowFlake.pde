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


public class SnowFlake {
  private float x;
  private float y;
  
  private int start;
  private float radius;
  private float wind;
  
  public SnowFlake(int x, float radius) {
    this.x = x;
    this.y = 0;
    this.radius = radius;
    this.wind = 0;

    // We'll use this as a random seed of sorts...    
    this.start = x;
  }
  
  public void setWind(float wind) {
    this.wind = wind;
  }
  
  public boolean finished() {
    return this.y >= height;
  }
  
  public void update() {
    // Falling motion...    
    this.x += this.wind;
    this.y += 2.0;

    // Introduce a little turbulence to the falling motion...
    this.x += sin((this.start + frameCount) * 0.1) * 0.4;
  }
  
  public void draw() {
    if (this.x + this.radius < 0 || this.x - this.radius > width) {
      // The flake is off the screen, do nothing...
      return;
    }
    
    pushStyle();
    
    stroke(#777777);
    fill(#ffffff);   
    ellipse(this.x, this.y, this.radius*2, this.radius*2);
    
    popStyle();
  }
}


/* EOF - SnowFlake.pde */
