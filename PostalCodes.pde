/*
 * PostalCodes.pde - show activity on a map of Portugal by postal code.
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


import processing.opengl.*;
import javax.media.opengl.GL;

import hypermedia.net.*;


final short TARGET_FRAMERATE = 30;

// The three portuguese regions...
final short REGION_PT = 0;
final short REGION_AZ = 1;
final short REGION_MA = 2;

// Ratios for each region ("horizontal/vertical")...
final float RATIO_PT = 0.4687;
final float RATIO_AC = 2.2222;
final float RATIO_MA = 1.7252;

// "Heartbeat"...
final short BEAT_RADIUS = 4;

// Global color palette...
Map<String,Integer> colors;

int[][] bounds;
Map<String,PostalCode> codes;
PlaceMarkers markers;

PImage artwork;
UDP server;
PrintWriter logfile;
SnowFall snow;

PFont eventFont;
PFont countFont;
PFont labelFont;

color eventColor;
color countColor;
color[] beatColors;

String lastEvent = "";


void setup() {
  size(1280, 768, OPENGL);
  frameRate(TARGET_FRAMERATE);
  smooth();
  
  // Force v-sync and anti-aliasing when using OpenGL...
  if (glRendererEnabled()) {
    glSetSync(true);
    glSetSmooth(true);
  }
  
  // Hide the cursor when in "present/fullscreen" mode...
  if (frame.isUndecorated()) {
    noCursor();
  }
  
  bounds = regionBounds(50);
  codes = Collections.unmodifiableMap(loadPostalCodes("postalcodes.txt", bounds));
  logfile = createWriter("postalcodes.log");
  
  // These two external resources define the overall look of the application...
  artwork = loadImage(String.format("background-%dx%d.png", width, height));
  colors = loadColors("colors.properties");

  // Save the colors to avoid a "get" on each draw...
  beatColors = new color[2];
  beatColors[0] = colors.get("INNER_COLOR");
  beatColors[1] = colors.get("OUTER_COLOR");
  eventColor = colors.get("EVENT_COLOR");
  countColor = colors.get("COUNT_COLOR");

  eventFont = loadFont("Verdana-Bold-18.vlw");
  countFont = loadFont("Arial-Black-144.vlw");
  labelFont = loadFont("Verdana-17.vlw");

  markers = new PlaceMarkers();

  // Enable some light snowfall...
  // snow = new SnowFall(0.15);

  server = new UDP(this, 15001);
  server.listen(true);

  /*
   * If a suitable background image does not exist, we have to generate one with
   * the three region's boundaries clearly marked to be used as a template...
   */
  // writeTemplate(dataPath(String.format("template-%dx%d.png", width, height)), codes, bounds);
}


void draw() {
  // Draw only once a second unless there's something that requires continuous drawing...
  if (frameCount > 2 && frameCount % TARGET_FRAMERATE != 0 && markers.exploding() == 0 && snow == null) {
    /*
     * There seems to be an OpenGL issue where sometimes the screen starts flashing on startup.
     * Drawing the first two frames seems to mitigate the problem, but does not eliminate it completely.
     */
    return;
  }
  
  // On the Mac this is *much* faster than using background()...
  image(artwork, 0, 0);

  // Remove the expired markers...
  markers.clean();

  // The counter of events currently displayed...
  fill(countColor);
  textAlign(LEFT);

  // The actual number of events...
  textFont(countFont);
  float baseline = height/2 + textAscent()/2;
  text(markers.count(), 50, baseline);
  
  // The time span the counter refers to...
  int minutes = millis() / 60000;
  String label = (minutes < 60) ? String.format("nos últimos %d minutos", minutes) : "na última hora";
  textFont(labelFont);
  text(label, 60, baseline + textAscent() + 15);
  
  // The last event...
  fill(eventColor);
  textAlign(RIGHT);
  textFont(eventFont);
  text(lastEvent, width - 60, height - 30 + textAscent()/2);
  
  // Two rotating circles ("heartbeat")...
  pushMatrix();
  noStroke();
  translate(width - 30, height - 30);
  rotate(frameCount/TARGET_FRAMERATE * QUARTER_PI);

  fill(beatColors[0]);
  ellipse(-BEAT_RADIUS, -BEAT_RADIUS, BEAT_RADIUS*2, BEAT_RADIUS*2);

  fill(beatColors[1]);
  ellipse(BEAT_RADIUS, BEAT_RADIUS, BEAT_RADIUS*2, BEAT_RADIUS*2);
  popMatrix();

  // Update the markers (do this last to always be on top)...
  markers.draw();

  if (snow != null) {
    // It's snowing...
    snow.update();
    snow.draw();
  }
}


int[][] regionBounds(int margin) {
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


Map<String,PostalCode> loadPostalCodes(String filename, int[][] bounds) {
  Map<String,PostalCode> codes = new HashMap<String,PostalCode>();
  
  // The file is assumed to have been correctly generated by the "makedb.py" script...
  try {
    BufferedReader reader = createReader(filename);
    String data;
    
    while ((data = reader.readLine()) != null) {
      String[] fields = split(data, '|');
      
      int region = int(fields[2]);
      
      // Convert the [0,1] ranged locations to screen coordinates...
      int x = round(lerp(bounds[region][0], bounds[region][2], float(fields[3])));
      int y = round(lerp(bounds[region][1], bounds[region][3], float(fields[4])));
      
      PostalCode place = new PostalCode(fields[0], fields[1], region, x, y);
      
      codes.put(place.code, place);
    }
  } catch (IOException e) {
    e.printStackTrace();

    return null;
  }
  
  return codes;
}


Map<String,Integer> loadColors(String filename) {
  Map<String,Integer> colors = new HashMap<String,Integer>();
  Properties props = new Properties();

  try {
    props.load(createReader(filename));
  } catch (IOException e) {
    e.printStackTrace();
    
    return null;
  }
  
  colors.put("EVENT_COLOR", unhex(props.getProperty("event_text", "000000")) | 0xff000000);
  colors.put("COUNT_COLOR", unhex(props.getProperty("count_text", "000000")) | 0xff000000);
  colors.put("INNER_COLOR", unhex(props.getProperty("inner_marker", "d72f28")) | 0xff000000);
  colors.put("OUTER_COLOR", unhex(props.getProperty("outer_marker", "379566")) | 0xff000000);
  colors.put("PLACE_COLOR", unhex(props.getProperty("place_marker", "000000")) | 0xff000000);
  
  return colors;
}


void receive(byte[] data, String ip, int port) {
  String message = new String(data);
  
  int h = hour();
  int m = minute();
  
  String label = String.format("%d-%02d-%02d %02d:%02d:%02d [%s:%d]", year(), month(), day(), h, m, second(), ip, port);
  
  /*
   * The event is made up of two comma-separated parts:
   *
   *   1. The postal code in extended portuguese format (PT-1994);
   *   2. An optional tag identifying the source agent (eg. a PID).
   */
  if (!message.matches("^\\d{4}-\\d{3}(,\\w{1,16})?$")) {
    logfile.println(label + ": invalid data");
    logfile.flush();
    
    return;
  }
  
  String[] parts = split(message, ",");

  // Extend the logging label with the agent tag...  
  label += (parts.length > 1) ? String.format(" [%s]", parts[1]) : " []";

  // Obtain the postal code data...
  PostalCode code = codes.get(parts[0]);
  
  if (code == null) {  // Try the simplified code...
    code = codes.get(split(parts[0], "-")[0] + "-000");

    if (code == null) {
      logfile.println(label + ": not found: " + parts[0]);
      logfile.flush();
      
      return;
    }

    logfile.println(label + ": found (simple): " + code);
    logfile.flush();

  } else {
    logfile.println(label + ": found: " + code);
    logfile.flush();
  }
  
  markers.add(code.x, code.y, code.place);
    
  // Update the place of the most recent marker...
  lastEvent = String.format("%d:%02d - %s", h, m, code.place);
}


void writeTemplate(String filename, Map<String,PostalCode> codes, int[][] bounds) {
  PGraphics pg = createGraphics(width, height, JAVA2D);
  
  pg.beginDraw();
  pg.smooth();
  pg.background(#ffffff);
  
  pg.noFill();
  pg.stroke(#000000);
  
  for (int i = 0; i < bounds.length; i++) {
    pg.rect(bounds[i][0], bounds[i][1], bounds[i][2]-bounds[i][0], bounds[i][3]-bounds[i][1]);
  }

  Iterator<PostalCode> iterator = codes.values().iterator();

  pg.fill(#000000, 64);
  pg.noStroke();

  while (iterator.hasNext()) {
    PostalCode code = iterator.next();
    pg.ellipse(code.x, code.y, 2, 2);
  }

  pg.endDraw();  
  pg.save(filename);
}


void keyReleased() {
  // Save a snapshot...
  if (key == 'c') {
    saveFrame("PostalCodes-" + frameCount + ".png");
  }
}


/* EOF - PostalCodes.pde */
