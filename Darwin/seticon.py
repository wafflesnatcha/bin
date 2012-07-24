#!/usr/bin/env python

import sys
from AppKit import *

if len(sys.argv) < 2:
	print "Usage: " + sys.argv[0] + " ICON FILE..."
	sys.exit(2)

if sys.argv[1] == "0":
	icon = None
else:
	icon = NSImage.alloc().initWithContentsOfFile_(sys.argv[1])
	if not icon:
		print "Error: Could not load image."
		sys.exit(2)

for path in sys.argv[2:]:
	NSWorkspace.sharedWorkspace().setIcon_forFile_options_(icon, path, 0)