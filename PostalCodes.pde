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


import hypermedia.net.*;


/* The three portuguese regions... */
final short REGION_PT = 0;
final short REGION_AZ = 1;
final short REGION_MA = 2;

/* Ratios for each region ("horizontal/vertical")... */
final float RATIO_PT = 0.4687;
final float RATIO_AC = 2.2222;
final float RATIO_MA = 1.7252;

/* "Heartbeat"... */
final color BEAT_COLOR_1 = #d72f28;
final color BEAT_COLOR_2 = #379566;
final short BEAT_RADIUS = 8;

/* The text showing the last event... */
final color EVENT_COLOR = #000000;

int[][] bounds;
Map<String,PostalCode> codes;
List<PlaceMarker> markers;

PImage artwork;
UDP server;
PrintWriter logfile;
PFont font;

String lastEvent = "";
List<Integer> events;


void setup() {
  size(1280, 768, JAVA2D);
  frameRate(30);
  smooth();
  
  /* Hide the cursor when in "present/fullscreen" mode... */
  if (frame.isUndecorated()) {
    noCursor();
  }
  
  bounds = regionBounds(50);

  codes = Collections.unmodifiableMap(loadPostalCodes("postalcodes.txt", bounds));
  markers = Collections.synchronizedList(new LinkedList<PlaceMarker>());
  events = Collections.synchronizedList(new LinkedList<Integer>());

  logfile = createWriter("postalcodes.log");

  server = new UDP(this, 15001);
  server.listen(true);
  
  artwork = loadImage(String.format("background-%dx%d.png", width, height));

  font = loadFont("Verdana-Bold-18.vlw");

  /*
   * If a suitable background image does not exist, we have to generate one with
   * the three region's boundaries clearly marked to be used as a template...
   */
  // writeTemplate(dataPath(String.format("template-%dx%d.png", width, height)), codes, bounds);
}


void draw() {
  /* On the Mac this is *much* faster than using background()... */
  image(artwork, 0, 0);

  /* Remove events older than one hour... */
  synchronized (events) {
    Iterator<Integer> iterator = events.iterator();
    int oldest = millis() - 3600000;

    while (iterator.hasNext() && iterator.next() <= oldest) {
      iterator.remove();
    }
  }
  
  /* The last event and the number of events for the last hour... */  
  textFont(font);
  textAlign(RIGHT);
  fill(EVENT_COLOR);
  text(String.format("%s / %d na última hora", lastEvent, events.size()), width - 60, height - 22);

  /* Update the animation for each active marker... */
  synchronized (markers) {
    Iterator<PlaceMarker> iterator = markers.iterator();
  
    while (iterator.hasNext()) {
      PlaceMarker marker = iterator.next();

      /* Animation finished... */
      if (marker.finished()) {
        iterator.remove();
        continue;
      }

      marker.draw();
    }
  }
  
  /* Two rotating circles ("heartbeat")... */
  noStroke();
  translate(width - 30, height - 30);
  rotate(radians(millis() / 3));

  fill(BEAT_COLOR_1);
  ellipse(-BEAT_RADIUS/2, -BEAT_RADIUS/2, BEAT_RADIUS, BEAT_RADIUS);

  fill(BEAT_COLOR_2);
  ellipse(BEAT_RADIUS/2, BEAT_RADIUS/2, BEAT_RADIUS, BEAT_RADIUS);
}


int[][] regionBounds(int margin) {
  int[][] bounds = new int[regions.length][4];
  
  /* Boundaries for Mainland Portugal... */
  bounds[REGION_PT][0] = width - margin - round((height - 2*margin) * RATIO_PT);
  bounds[REGION_PT][1] = margin;
  bounds[REGION_PT][2] = width - margin;
  bounds[REGION_PT][3] = height - margin;

  /* Base value for the spacing between regions (1/10 the height of mainland Portugal) */
  int spacing = round((bounds[REGION_PT][3]-bounds[REGION_PT][1])/10);

  /* Boundaries for the (inhabited) Madeira islands... */
  bounds[REGION_MA][0] = bounds[REGION_PT][0] - spacing - round((bounds[REGION_PT][3]-bounds[REGION_PT][1])/5 * RATIO_MA);
  bounds[REGION_MA][1] = bounds[REGION_PT][3] - spacing - round((bounds[REGION_PT][3]-bounds[REGION_PT][1])/5);
  bounds[REGION_MA][2] = bounds[REGION_PT][0] - spacing;
  bounds[REGION_MA][3] = bounds[REGION_PT][3] - spacing;

  /* Boundaries for the Azores islands... */
  bounds[REGION_AZ][0] = bounds[REGION_MA][2] - spacing - round((bounds[REGION_PT][3]-bounds[REGION_PT][1])/4 * RATIO_AC);
  bounds[REGION_AZ][1] = bounds[REGION_MA][1] - spacing - round((bounds[REGION_PT][3]-bounds[REGION_PT][1])/4);
  bounds[REGION_AZ][2] = bounds[REGION_MA][2] - spacing;
  bounds[REGION_AZ][3] = bounds[REGION_MA][1] - spacing;

  return bounds;
}


Map<String,PostalCode> loadPostalCodes(String filename, int[][] bounds) {
  Map<String,PostalCode> codes = new HashMap<String,PostalCode>();
  
  /* The file is assumed to have been correctly generated by the "makedb.py" script... */
  try {
    BufferedReader reader = createReader(filename);
    String data;
    
    while ((data = reader.readLine()) != null) {
      String[] fields = split(data, '|');
      
      int region = int(fields[2]);
      
      /* Convert the [0,1] ranged locations to screen coordinates... */
      int x = round(map(float(fields[3]), 0, 1, bounds[region][0], bounds[region][2]));
      int y = round(map(float(fields[4]), 0, 1, bounds[region][1], bounds[region][3]));
      
      PostalCode place = new PostalCode(fields[0], fields[1], region, x, y);
      
      codes.put(place.code, place);
    }
  } catch (IOException e) {
    e.printStackTrace();

    return null;
  }
  
  return codes;
}


void receive(byte[] data, String ip, int port) {
  String message = new String(data);
  
  int h = hour();
  int m = minute();
  
  String ts = String.format("%d-%02d-%02d %02d:%02d:%02d [%s:%d]", year(), month(), day(), h, m, second(), ip, port);
  
  if (!message.matches("^\\d{4}-\\d{3}$")) {
    logfile.println(ts + ": invalid data");
    logfile.flush();
    
    return;
  }
  
  PostalCode code = codes.get(message);
  
  if (code == null) {  /* Try the simplified code... */
    code = codes.get(split(message, "-")[0] + "-000");

    if (code == null) {
      logfile.println(ts + ": not found: " + message);
      logfile.flush();
      
      return;
    }

    logfile.println(ts + ": found (simple): " + code);
    logfile.flush();

  } else {
    logfile.println(ts + ": found: " + code);
    logfile.flush();
  }
  
  markers.add(new PlaceMarker(code.x, code.y));
    
  /* Update the place of the most recent marker... */
  lastEvent = String.format("%d:%02d - %s", h, m, code.place);

  /* Record the time of the event... */
  events.add(millis());
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


/* EOF - PostalCodes.pde */
