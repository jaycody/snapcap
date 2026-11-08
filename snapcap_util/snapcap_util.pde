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
///// Project name used to label snaps and frames.
///// The version comes from git automatically.
String   PROJ    = "snapcap";
////////////////////////////////////////////////////////////

Snapcap    snapcap;
ImageLayer imagelayer;

void setup() {
  size(1280, 480, P2D);

  // One line. Snapcap hooks itself into draw() and the keyboard.
  snapcap    = new Snapcap(PROJ);
  imagelayer = new ImageLayer();
}

void draw() {
  /*******************************
   * MAGIC HERE /////////////*/
  imagelayer.ready();
  //*******************************

  // Demo of a held-down key (see keyEVENTS.pde)
  checkForRepeatingKey();

  // No snapcap call needed: it captures after draw() on its own.
}
