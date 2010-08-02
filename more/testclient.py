#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# testclient.py - send random postal codes to the graphical application for testing.
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
import socket
import time
import random

from getopt import getopt, GetoptError


def print_usage():
    sys.stdout.write("USAGE: %s [-h <hostname>] [-p <port>] [-r <rate>] -f <postalcodes.txt>\n" % os.path.basename(sys.argv[0]))


def parse_args():
    try:
        options, args = getopt(sys.argv[1:], "h:p:r:f:", ["hostname=", "port=", "rate=", "file="])
    except GetoptError, e:
        sys.stderr.write("error: %s\n" % e)
        print_usage()
        sys.exit(1)

    hostname = "127.0.0.1" 
    port = 15001
    rate = 4  # ...per second
    ifile = None
        
    for option, value in options:
        if option in ("-h", "--hostname"):
            hostname = value
        elif option in ("-p", "--port"):
            port = int(value)
        elif option in ("-r", "--rate"):
            rate = float(value)
        elif option in ("-f", "--file"):
            ifile = value
    
    if ifile == None:
        sys.stderr.write("error: parameter(s) missing\n")
        print_usage()
        sys.exit(1)

    return (hostname, port, rate, ifile)


if __name__ == "__main__":
    (hostname, port, rate, ifile) = parse_args()

    f = open(ifile, "r")

    # The file is assumed to have been correctly generated by the "makedb.py" script...
    codes = []
    for line in f:
        fields = line.split("|")
        codes.append(fields[0])

    f.close()

    udp = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    address = (socket.gethostbyname(hostname), port)

    while 1:
        # In a real client we don't want it to terminate if the graphical application
        # can't be reached. We want it to keep running and recover automatically.
        try:
            udp.sendto(random.choice(codes), address)
        except socket.error:
            pass

        time.sleep(1/rate)


# vim: set expandtab ts=4 sw=4:
