//////////////////////////////
// KeyEVENTS for this demo sketch.
// Snapcap's own keys ('r', ENTER, 'd', 'i') are handled inside Snapcap,
// so this file only holds the sketch's keys.

char     currentKey;
int      currentKeyCode = -1;

////////////////////////////////////////////////////////////
// ON KEY PRESS ---> DO THIS:
void keyPressed() {
  // Remember the current key when it's pressed.
  currentKeyCode = keyCode;
  currentKey     = key;

  // <SPACE> wipes the background, <TAB> wipes the PGraphics layers
  if (key == ' ') {
    background(0);
  } else if (key == TAB) {
    clearPGraphic(imagelayer.offScreenBuffer);
    clearPGraphic(imagelayer.displayLayer);
  }
}

////////////////////////////////////////////////////////////
// ON RELEASE, CLEAR SWITCH
//      functions like a pull-down resistor
void keyReleased() {
  currentKeyCode = -1;
}

////////////////////////////////////////////////////////////
// MOMENTARY SWITCH: runs every frame while 'w' is held down
//      (good for scrubbing through source images)
void checkForRepeatingKey() {
  if (currentKeyCode == -1 || currentKey != 'w') {
    return;
  }
  // Put held-key behavior here.
}

////////////////////////////////////////////////////////////
// Make a PGraphics layer fully transparent
void clearPGraphic(PGraphics p) {
  p.beginDraw();
  p.clear();
  p.endDraw();
}
