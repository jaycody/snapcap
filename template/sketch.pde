/*******************************************************************
 * __PROJECT__  (__VERSION__)
 *
 * Made with snapcap __SNAPCAP_RELEASE__
 *   'r'      start/stop recording frames
 *   ENTER    snap a single frame
 *   'd'      show/hide the on-screen status (never captured)
 *   'i'      print the key list
 *******************************************************************/

Snapcap snapcap;

void setup() {
  size(1280, 720, P2D);

  // Frames come out at exactly size(), even on a Retina screen.
  // Delete this line for sharper frames at 2x the size (4x the disk space).
  pixelDensity(1);

  // Labels output with the git version of this project.
  snapcap = new Snapcap("__PROJECT__");

  background(0);
}

void draw() {
  // Your art goes here. Snapcap captures after draw() on its own.
  noStroke();
  fill(255, 40);
  ellipse(mouseX, mouseY, 40, 40);
}
