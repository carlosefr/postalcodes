/*
 * SnowFall.pde - snow flake management.
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


public class SnowFall {
  private List<SnowFlake> flakes;
  private int maxFlakes;

  private float skyWidth;

  public SnowFall(float density) {
    this.flakes = new LinkedList<SnowFlake>();
    this.skyWidth = width * 1.2;
    this.maxFlakes = round(this.skyWidth * density);
  }

  public void clean() {
    Iterator<SnowFlake> iterator = this.flakes.iterator();

    while (iterator.hasNext()) {
      SnowFlake flake = iterator.next();

      if (flake.finished()) {
        iterator.remove();
      }
    }
  }

  public void update() {
    // Discard offscreen flakes...
    this.clean();

    // Update the flakes' position...
    Iterator<SnowFlake> iterator = this.flakes.iterator();

    while (iterator.hasNext()) {
      SnowFlake flake = iterator.next();

      // Variable wind (always right to left)...
      flake.setWind((sin(frameCount * 0.01) - 1.0) * 0.5);
      flake.update();
    }

    // Create some new flakes...
    for (int i = 0; i < int(random(this.maxFlakes)) - this.flakes.size(); i++) {
      this.flakes.add(new SnowFlake(round(random(this.skyWidth))));
    }
  }

  public void draw() {
    Iterator<SnowFlake> iterator = this.flakes.iterator();

    while (iterator.hasNext()) {
      iterator.next().draw();
    }
  }
}


/* EOF - SnowFall.pde */
