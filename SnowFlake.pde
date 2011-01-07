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
  
  public SnowFlake(int x, float radius) {
    this.x = x;
    this.y = 0;
    this.radius = radius;

    // We'll use this as a random seed of sorts...    
    this.start = x;
  }
  
  public boolean finished() {
    return this.x < 0 || this.x >= width ||
           this.y < 0 || this.y >= height;
  }
  
  public void update() {    
    // Introduce a little turbulence to the falling motion...
    this.x -= (0.2 + sin((this.start + frameCount) * 0.1) * 0.4);
    this.y += 2.0;
  }
  
  public void draw() {
    pushStyle();
    
    stroke(#777777);
    fill(#ffffff);   
    ellipse(this.x, this.y, this.radius*2, this.radius*2);
    
    popStyle();
  }
}


/* EOF - SnowFlake.pde */
