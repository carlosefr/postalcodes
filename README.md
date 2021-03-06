What is it?
===========

**Postal Codes** is an application to show activity on a map based on postal code coordinates. It is designed for [Portugal](http://en.wikipedia.org/wiki/Portugal) specifically, but you can use it as a starting point to tailor it to another country if you wish. The code is [free](http://www.opensource.org/licenses/mit-license.php) after all.

Below you can see how it looks like in its default configuration (to fit standard widescreen TVs). However, the appearance can be easily [customized](https://github.com/carlosefr/postalcodes/wiki/Customizing) to fit your own branding just by replacing/modifying the background image and changing a couple of colors in a properties file.

![screenshot](https://raw.githubusercontent.com/carlosefr/postalcodes/master/screenshots/postalcodes.jpg)
[[video](http://www.youtube.com/watch?v=0PTb9AgNhrE)]

It works as a client-server application where the graphical portion listens on the network and one or more client agents on another (or the same) machine sends it postal codes to map on screen. The protocol is based on UDP and is very simple, so custom client agents are easy to make in whatever language you choose.

Besides the graphical application, based on [Processing](http://processing.org/), it also includes an [example client agent](more/testclient.py) and a [script](more/makedb.py) to import [GeoNames](http://www.geonames.org/postal-codes/postal-codes-portugal.html)' postal codes database into the required format.


What does it need to run?
=========================

  * [Java](https://jdk.java.net/) (either as a separate download or, preferably, the version included with Processing)
  * [Processing](http://processing.org/) Processing 3.5 (for the graphical application)
  * [UDP](http://ubaa.net/shared/processing/udp/) sockets library for Processing
  * [Python](http://python.org/) 3.7.7 or newer (optional, for the example agent and database import script)

Older versions of any of these packages may work, but haven't been tested. Newer versions should also work, and you should use them if possible.

**Postal Codes** has been tested on macOS 10.15, but it should work wherever Processing works.
