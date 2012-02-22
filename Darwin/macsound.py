#!/usr/bin/python

import os
import sys
import glob
from AppKit import NSSound

# code mainly influenced by this website:
# http://nodebox.net/code/index.php/PyObjC
class MacSound:
    def __init__(self, filepath):
        self._sound = NSSound.alloc()
        self._sound.initWithContentsOfFile_byReference_(filepath, True)
    def play(self): self._sound.play()
    def stop(self): self._sound.stop()
    def is_playing(self): return self._sound.isPlaying()

def main():
    """Plays all sound files passed by the calling AppleScript."""
    soundfilepaths = sys.argv[1:]
    for soundfilepath in soundfilepaths:
        macsound = MacSound(soundfilepath.decode('utf-8'))
        macsound.play()
        while True:
            if not macsound.is_playing():
                break

if __name__ == '__main__':
    main()