/*******************************************************************
 * snapcap du videoalchemy
 -- Util captures and organizes graphics output....in a snap ;)
 -- Snap a screenshot or record a sequence of frames
 -- Name files with timestamps and dirs with sequence start-times
 -- Start and stop without overwriting previous recordings
 *
 * Copyright (c) 2021 Jason Stephens
 * The MIT License (MIT)
 *******************************************************************/

////////////////////////////////////////////////////////////
///// GLOBALS for snapcap IDs
String   PROJ           = "snapcap";
String   VERSION        = "ver1_0_0";
String   SNAP_ROOT      = ("./snaps/");
String   FRAME_ROOT     = ("./frames/");
String   SNAP_PATH      = SNAP_ROOT + VERSION + "/" + PROJ;
////////////////////////////////////////////////////////////
///// GLOBALS for keyEvents
char     currentKey;
int      currentKeyCode = -1;
boolean  DEBUG = true;
////////////////////////////////////////////////////////////

Snapcap       snapcap;
ImageLayer imagelayer;

void setup() {
  size(1280, 480, P2D);

  snapcap         = new Snapcap();
  imagelayer      = new ImageLayer();
}

void draw() {

  /*******************************
  * MAGIC HERE /////////////*/
  imagelayer.ready();
  //*******************************


  /*******************************
   * SNAP HERE ////////////
   * ----> always final draw step*/
  snapcap.ready();
  //*******************************
}
