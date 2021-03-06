/*
 * PostalCode.pde - information contained in a postal code.
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


public class PostalCode {
  public String code;
  public String place;
  public int region;
  public int x;
  public int y;

  public PostalCode(String code, String place, int region, int x, int y) {
    this.code = code;
    this.place = place;
    this.region = region;
    this.x = x;
    this.y = y;
  }

  public String toString() {
    return String.format("%s %s (%s:%d,%d)", this.code, this.place, regions[this.region], this.x, this.y);
  }
}


/*
 * Takes a database file generated by the "makedb.py" script and returns the
 * postal code locations (in pixel coordinates) based on the sketch resolution...
 */
Map<String,PostalCode> loadPostalCodesDB(String filename, int[][] bounds) {
  Map<String,PostalCode> codes = new HashMap<String,PostalCode>();
  BufferedReader reader = null;

  try {
    String data;

    reader = createReader(filename);

    while ((data = reader.readLine()) != null) {
      String[] fields = split(data, '|');

      int region = int(fields[2]);

      // Convert the [0,1] ranged locations to pixel coordinates...
      int x = round(lerp(bounds[region][0], bounds[region][2], float(fields[3])));
      int y = round(lerp(bounds[region][1], bounds[region][3], float(fields[4])));

      PostalCode place = new PostalCode(fields[0], fields[1], region, x, y);

      codes.put(place.code, place);
    }
  } catch (IOException e) {
    e.printStackTrace();

    return null;
  } finally {
    try {
      if (reader != null) {
        reader.close();
      }
    } catch (IOException e) {
        e.printStackTrace();
    }
  }

  return codes;
}


/* EOF - PostalCode.pde */
