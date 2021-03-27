/*******************************************************************
 * snapcap du videoalchemy
 * Util captures and organizes graphics output....in a snap ;)
 * Snap a screenshot or record a sequence of frames
 * Name files with timestamps and dirs with sequence start-times
 * Start and stop without overwriting previous recordings
 *
 * Copyright (c) 2021 Jason Stephens
 * The MIT License (MIT)
 *******************************************************************/

////////////////////////////////////////////////////////////
///// GLOBALS for snapcap IDs
String   PROJ           = "projtest-";
String   VERSION        = "vertest";
String   SNAP_ROOT      = ("./snaps/");
String   FRAME_ROOT     = ("./frames/");
String   SNAP_PATH      = SNAP_ROOT + VERSION + "/" + PROJ;
////////////////////////////////////////////////////////////
///// GLOBALS for keyEvents
char     currentKey;
int      currentKeyCode = -1;
boolean  DEBUG = true;
////////////////////////////////////////////////////////////

Snapcap   snapcap;

PGraphics makePixelsClear;

void setup() {
  size(1280, 480, P2D);
  noStroke();
  smooth();
  snapcap         = new Snapcap();
  makePixelsClear = createGraphics(width, height, P2D);
  makePixelsClear.fill(0);
}

void draw() {
  ////////////////////
  // MAGIC HERE
  //background(0);
  fill(255);

  ellipse(mouseX, mouseY, mouseX, mouseY);


  makePixelsClear.beginDraw();
  makePixelsClear.fill(0, 255, 0);
  makePixelsClear.ellipse(mouseX, mouseY, 60, 60);
  //test per-vertex color fills inside a beginDraw for PGaphic.
  makePixelsClear.beginShape();
  makePixelsClear.fill(0, 255, 255, 100);
  makePixelsClear.vertex(mouseX, height-mouseY);
  makePixelsClear.fill(255, 255, 0, 15);
  makePixelsClear.vertex(mouseY*1.2, mouseX);
  makePixelsClear.fill(0, 200);
  makePixelsClear.vertex(width-mouseX, mouseY);
  // end test of per-vertex color fills
  makePixelsClear.endShape();
  makePixelsClear.fill(255, 0, 255, 50);
  makePixelsClear.image(makePixelsClear, mouseX-width/2, mouseY-height/2);
  makePixelsClear.ellipse(width-mouseX, height-mouseY, 60, 60);
  //makePixelsClear.image(makePixelsClear, mouseX-width/2, mouseY-height/2);
  makePixelsClear.endDraw();


  // Per-vertex color fills within beginShape-endShape
  beginShape();
  fill(255, 0, 0);
  vertex(height-mouseY, width-mouseX);
  vertex(100, 100);
  fill(0, 255, 0);
  vertex(400, 100);
  fill(0, 0, 255);
  vertex(mouseX, mouseY);
  endShape();

  // now draw that PGraphic as a transparent layer
  image(makePixelsClear, 0, 0);
  ///////////////////



  /*******************************
   * SNAP CAPTURER ////////////
   * Keep as final step in draw loop*/
  snapcap.ready();
  //*******************************
}
