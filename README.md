[![Build Status](https://travis-ci.org/timvideos/edid_grabber_c.png?branch=master)](https://travis-ci.org/timvideos/edid_grabber_c)

EDID Grabber in C
===============

This tool grabs EDID data from the operating system and uploads them to [EDID.tv](http://edid.tv).

Supports Windows, Linux and Mac OS X.

Building Instructions
---
Makefile will download, compile and install required libraries (eg. libcurl) for compiling edid-grabber.

#### Linux
```make clean && make linux```

#### Windows
Compiling for Windows is supported with [MinGW-w64](http://mingw-w64.sourceforge.net) only, you need to install it before proceeding.

```make clean && make windows```
