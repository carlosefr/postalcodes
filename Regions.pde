/*
 * Regions.pde - nonadjacent portuguese territory regions.
 *
 * Copyright (c) 2013 Carlos Rodrigues <cefrodrigues@gmail.com>
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


// The three portuguese regions...
final short REGION_PT = 0;
final short REGION_AZ = 1;
final short REGION_MA = 2;

// Ratios for each region ("horizontal/vertical")...
final float RATIO_PT = 0.4687;
final float RATIO_AC = 2.2222;
final float RATIO_MA = 1.7252;

// Readable region codes...
final String[] regions = { "PT", "AZ", "MA" };


/*
 * Returns a bounding box for each one of the three portuguese
 * regions (in pixel coordinates) based on the sketch resolution...
 */
int[][] calculateRegionBounds(int margin) {
  int[][] bounds = new int[regions.length][4];

  // Boundaries for Mainland Portugal...
  bounds[REGION_PT][0] = width - margin - round((height - 2*margin) * RATIO_PT);
  bounds[REGION_PT][1] = margin;
  bounds[REGION_PT][2] = width - margin;
  bounds[REGION_PT][3] = height - margin;

  // Base value for the spacing between regions (1/10 the height of mainland Portugal)
  int spacing = round((bounds[REGION_PT][3]-bounds[REGION_PT][1])/10);

  // Boundaries for the (inhabited) Madeira islands...
  bounds[REGION_MA][0] = bounds[REGION_PT][0] - spacing - round((bounds[REGION_PT][3]-bounds[REGION_PT][1])/5 * RATIO_MA);
  bounds[REGION_MA][1] = bounds[REGION_PT][3] - spacing - round((bounds[REGION_PT][3]-bounds[REGION_PT][1])/5);
  bounds[REGION_MA][2] = bounds[REGION_PT][0] - spacing;
  bounds[REGION_MA][3] = bounds[REGION_PT][3] - spacing;

  // Boundaries for the Azores islands...
  bounds[REGION_AZ][0] = bounds[REGION_MA][2] - spacing - round((bounds[REGION_PT][3]-bounds[REGION_PT][1])/4 * RATIO_AC);
  bounds[REGION_AZ][1] = bounds[REGION_MA][1] - spacing - round((bounds[REGION_PT][3]-bounds[REGION_PT][1])/4);
  bounds[REGION_AZ][2] = bounds[REGION_MA][2] - spacing;
  bounds[REGION_AZ][3] = bounds[REGION_MA][1] - spacing;

  return bounds;
}


/* EOF - Regions.pde */
