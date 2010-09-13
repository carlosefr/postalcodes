#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# makedb.py - download and convert GeoNames' postal codes database for Portugal.
#
# Copyright (c) 2010, Carlos Rodrigues <cefrodrigues@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#


from __future__ import division;

import os, os.path
import sys

from getopt import getopt, GetoptError
from urllib2 import urlopen, Request
from zipfile import ZipFile


# Coordinate boundaries for each of the three portuguese regions...
boundaries = { 0: (42.1541, -9.5091, 36.9624, -6.1885),     # Mainland Portugal
               1: (39.7312, -31.2920, 36.9272, -25.0084),   # Azores islands
               2: (33.1142, -17.2830, 32.6321, -16.2833) }  # Madeira islands (inhabited)


def print_usage():
    sys.stdout.write("USAGE: %s -o <postalcodes.txt>\n" % os.path.basename(sys.argv[0]))


def parse_args():
    try:
        options, args = getopt(sys.argv[1:], "o:", ["output="])
    except GetoptError, e:
        sys.stderr.write("error: %s\n" % e)
        print_usage()
        sys.exit(1)

    ofile = None
        
    for option, value in options:
        if option in ("-o", "--output"):
            ofile = value
    
    if ofile == None:
        sys.stderr.write("error: parameter(s) missing\n")
        print_usage()
        sys.exit(1)

    return (ofile,)


def find_region(latitude, longitude):
    for region in boundaries.keys():
        (max_lat, min_lon, min_lat, max_lon) = boundaries[region]

        if (latitude < max_lat and latitude > min_lat and
            longitude < max_lon and longitude > min_lon):
            return region

    return None 


def normalize(value, stop, start):
    return (value - start) / (stop - start)


def download(url):
    filename = os.path.basename(url)
    datafile = ("%s.txt") % filename.split(".")[0]

    response = urlopen(Request(url))
    f = open(filename, "wb")

    while 1:
        chunk = response.read(4096)
        if not chunk:
            break
        
        f.write(chunk)

    f.close()
    response.close()

    zfile = ZipFile(filename);

    f = open(datafile, "wb")
    f.write(zfile.read(datafile))
    f.close()

    zfile.close()
    os.remove(filename)

    return datafile


def process(ifile, ofile, efile):
    codes = {}

    # Gather the codes from the errata...
    f = open(efile, "r")

    for line in f:
        line.rstrip()
        fields = line.split("|")

        codes[fields[0]] = (fields[1], float(fields[2]), float(fields[3]))

    f.close()

    # Gather the codes from the main database...
    f = open(ifile, "r")

    for line in f:
        line.rstrip("\r\n")
        fields = line.split("\t")

        # Skip codes without coordinates...
        if not len(fields[9]) or not len(fields[10]):
            continue

        if fields[1] in codes:
            continue

        codes[fields[1]] = (fields[2], float(fields[9]), float(fields[10]))

    f.close()

    output = set()
    plain_codes = set()

    for code in sorted(codes.iterkeys()):
        place, lat, lon = codes[code]
        region = find_region(lat, lon)

        # Skip codes outside valid regions...
        if region is None:
            continue

        # Normalize and remap the coodinates to a [0,1] range...
        x = normalize(lon, boundaries[region][3], boundaries[region][1]) 
        y = normalize(lat, boundaries[region][2], boundaries[region][0])

        output.add("%s|%s|%d|%g|%g" % (code, place, region, x, y))

        # Hack: improve the data by adding simple/shortened codes...
        plain_code = code.split("-")[0] + "-000"

        if plain_code not in codes and plain_code not in plain_codes:
            plain_codes.add(plain_code)
            output.add("%s|%s|%d|%g|%g" % (plain_code, place, region, x, y))

    f = open(ofile, "w")

    for line in sorted(output):
        f.write(line + "\n")

    f.close()


if __name__ == "__main__":
    (ofile,) = parse_args()

    sys.stdout.write("Downloading GeoNames' postal codes database for Portugal...\n")
    datafile = download("http://download.geonames.org/export/zip/PT.zip")

    datafile = "PT.txt"
    sys.stdout.write("Generating the file \"%s\"...\n" % ofile)
    process(datafile, ofile, "errata.txt")

    os.remove(datafile)
    sys.stdout.write("Finished!\n");


# vim: set expandtab ts=4 sw=4:
