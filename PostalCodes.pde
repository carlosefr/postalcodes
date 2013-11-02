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


import java.util.*;
import java.net.*;

/*
 * The "UDP" processing library can be downloaded directly from
 * the author's website at: http://ubaa.net/shared/processing/udp/
 */
import hypermedia.net.UDP;


final String PROGRAM_NAME = "PostalCodes P2.0";

final short TARGET_FRAMERATE = 30;
final short SERVER_PORT = 15001;

// Easter-egg parameters...
final short EGG_TRIGGER = 1143;   // Treaty of Zamora
final short EGG_DURATION = 5000;  // milliseconds

// How much snow to have...
final float SNOW_DENSITY = 0.15;

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

PImage egg;
float eggStart = -1;

// Debugging info...
Boolean showInfoBox = false;
String ipAddress;


void setup() {
  size(1280, 768, P3D);
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
  
  // Load the postal codes database as screen (pixel) coordinates...
  bounds = calculateRegionBounds(50);
  codes = Collections.unmodifiableMap(loadPostalCodesDB("postalcodes.txt", bounds));
  logfile = createWriter("postalcodes.log");
  
  // These two external resources define the overall look of the application...
  artwork = loadImage(String.format("background-%dx%d.png", width, height));
  colors = loadColorSettings("colors.properties");

  // Save the colors to avoid a "get" on each draw...
  beatColors = new color[2];
  beatColors[0] = colors.get("INNER_COLOR");
  beatColors[1] = colors.get("OUTER_COLOR");
  eventColor = colors.get("EVENT_COLOR");
  countColor = colors.get("COUNT_COLOR");

  eventFont = loadFont("Verdana-Bold-18.vlw");
  labelFont = loadFont("Verdana-17.vlw");
  
  /*
   * Processing 2.0 has a bug causing this font to appear corrupted if loaded from a file,
   * so it must be created on demand. This requires the font to be installed in the system...
   */
  countFont = createFont("Arial-Black", 144, true, "0123456789".toCharArray());  // loadFont("Arial-Black-144.vlw");

  markers = new PlaceMarkers();

  // Enable snowfall by default...
  // snow = new SnowFall(SNOW_DENSITY);

  server = new UDP(this, SERVER_PORT);
  server.listen(true);

  // The easter-egg image, triggered by a particular counter value...
  egg = loadImage("egg.png");

  // Obtain some info...
  try {
    ipAddress = InetAddress.getLocalHost().getHostAddress();
  } catch (UnknownHostException e) {
    e.printStackTrace();
    ipAddress = "<unknown>";
  }
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

  // Make sure expired markers aren't drawn...
  markers.clean();

  // The number of events currently on the map...
  drawEventCounter();
  
  // The last event location and "heartbeat" indicator...
  drawStatusLine();

  // A small easter-egg: show a picture upon a particular counter value...
  if (markers.count() == EGG_TRIGGER) {
    eggStart = millis();
  }
  
  // Show the easter-egg for a few seconds after the fact...
  if (eggStart > 0 && millis() < eggStart + EGG_DURATION) {
    image(egg, 0, height - egg.height);
  }

  // Place the markers on the map...
  markers.draw();

  if (snow != null) {
    // It's snowing...
    snow.update();
    snow.draw();
  }
  
  // Show some information (on top of everything)...
  if (showInfoBox) {
    drawInfoBox();
  }
}


void drawEventCounter() {
  fill(countColor);
  textAlign(LEFT);

  // The actual number of events (currently displayed)...
  textFont(countFont);
  float baseline = height/2 + textAscent()/2;
  text(markers.count(), 50, baseline);
  
  // The time span the counter refers to...
  int minutes = millis() / 60000;
  String label = (minutes < 60) ? String.format("nos últimos %d minutos", minutes) : "na última hora";
  textFont(labelFont);
  text(label, 60, baseline + textAscent() + 15);
}


void drawStatusLine() {
  // The last event placed on the map...
  fill(eventColor);
  textAlign(RIGHT);
  textFont(eventFont);
  text(lastEvent, width - 60, height - 30 + textAscent()/2);

  // The "heartbeat" indicator (two rotating circles)...
  pushMatrix();
  
  noStroke();
  translate(width - 30, height - 30);
  rotate(millis()/1500.0);

  fill(beatColors[0]);
  ellipse(-4, -4, 8, 8);

  fill(beatColors[1]);
  ellipse(4, 4, 8, 8);

  popMatrix();
}


void drawInfoBox() {
    String info = String.format("%s\nJava %s (%s)\n%dx%d@%dfps (%s)\n%s\n%s:%d/UDP",
                                PROGRAM_NAME,
                                System.getProperty("java.runtime.version"), System.getProperty("os.arch"),
                                width, height, round(frameRate), g.getClass().getName(),
                                glRendererEnabled() ? glGetInfo() : "GL info not available",
                                ipAddress, SERVER_PORT);
    
    pushStyle();
    textFont(labelFont);
    
    // Define an integer line height, to avoid blurring...
    int lineHeight = round(textAscent() + textDescent() + 6.0);
    
    // Set the leading to accurately know the line height...
    textLeading(lineHeight);
    int infoHeight = lineHeight * split(info, "\n").length;
    
    pushMatrix();
    translate(30, height - 30 - infoHeight);
    
    noStroke();
    
    fill(#ffffff);
    rectMode(CORNERS);
    rect(-15, -15, textWidth(info) + 15, infoHeight + 15);
    
    fill(#000000);
    textAlign(LEFT, BOTTOM);
    text(info, 0, infoHeight);
    
    popMatrix();
    popStyle();
}


void keyReleased() {
  // Save a snapshot...
  if (key == 'c') {
    saveFrame("PostalCodes-" + frameCount + ".png");
  }
  
  // Show/hide info...
  if (key == 'i') {
    showInfoBox = !showInfoBox;
  }
  
  // Toggle snowfall...
  if (key == 's') {
    snow = (snow == null ? new SnowFall(SNOW_DENSITY) : null);
  }
  
  if (key == 't') {
    /*
     * If a suitable background image does not exist, we have to generate one with
     * the three region's boundaries clearly marked to be used as a template...
     */
     saveArtworkTemplate(String.format("template-%dx%d.png", width, height), codes, bounds);
  }
}


/*
 * This function is called implicitly for every UDP packet received...
 */
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


Map<String,Integer> loadColorSettings(String filename) {
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


void saveArtworkTemplate(String filename, Map<String,PostalCode> codes, int[][] bounds) {
  PGraphics pg = createGraphics(width, height, JAVA2D);
  
  pg.beginDraw();
  pg.smooth();

  // Start with what's on screen right now...
  pg.image(get(), 0, 0);
  
  pg.fill(#fffd66, 128);
  pg.noStroke();
  
  for (int i = 0; i < bounds.length; i++) {
    pg.rect(bounds[i][0], bounds[i][1], 1+bounds[i][2]-bounds[i][0], 1+bounds[i][3]-bounds[i][1]);
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


/* EOF - PostalCodes.pde */
