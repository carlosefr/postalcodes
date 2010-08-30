/*
 * PlaceMarkers.pde - animated markers management.
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


/* Maximum number of static markers at each location... */
final int MAX_MARKERS = 5;


public class PlaceMarkers {
  private List<PlaceMarker> markers;
  private int[][] counters;  // ...number of static markers at each location.
  
  public PlaceMarkers() {
    this.markers = new LinkedList<PlaceMarker>();
    this.counters = new int[width][height];
  }

  public synchronized int count() {
    return this.markers.size();
  }

  public synchronized void add(int x, int y) {
    this.markers.add(new PlaceMarker(x, y));
  }
  
  public synchronized void clean() {
    Iterator<PlaceMarker> iterator = markers.iterator();

    while (iterator.hasNext()) {
      PlaceMarker marker = iterator.next();

      /* The markers are ordered, stop on the first unfinished one... */
      if (!marker.finished()) {
        break;
      }

      iterator.remove();
    }
  }
  
  public synchronized void draw() {
    /* (Re)initialize the static marker counters... */
    for (int i = 0; i < this.counters.length; i++) {
      Arrays.fill(this.counters[i], 0);
    }
    
    Iterator<PlaceMarker> iterator = markers.iterator();

    while (iterator.hasNext()) {
      PlaceMarker marker = iterator.next();
      
      if (!marker.exploding()) {
        this.counters[marker.x][marker.y]++;

        /*
         * If there are already too many static markers at this
         * location, skip this one and save some CPU cycles...
         */
        if (this.counters[marker.x][marker.y] > MAX_MARKERS) {
          continue;
        }
      }
      
      marker.draw();
    }
  }
}


/* EOF - PlaceMarkers.pde */
