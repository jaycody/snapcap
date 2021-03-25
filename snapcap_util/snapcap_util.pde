/*******************************************************************
 * snapcap du videoalchemy
     * Util captures and organizes graphics output.
     * Snap a screenshot or record a sequence of frames 
     * Name files with timestamps and dirs with sequence start-times
     * Start and stop without overwriting previous recordings
 *
 * Copyright (c) 2021 Jason Stephens
 * The MIT License (MIT)
 *******************************************************************/

////////////////////////////////////////////////////////////
///// GLOBALS
String PROJ       = "projtest-";                                    
String VERSION    = "vertest";                                  
String SNAP_ROOT  = ("./snaps/");              
String FRAME_ROOT = ("./frames/");    
String SNAP_PATH  = SNAP_ROOT + VERSION + "/" + PROJ;      
////////////////////////////////////////////////////////////

Recorder recorder;
boolean cursorIsOn = true;

void setup() {
  size(1280, 480, P2D);
  recorder = new Recorder();
  printInstructions();
}

void draw() {
  ////////////////////
  // MAGIC HERE
  ellipse(mouseX,mouseY, mouseX, mouseY);
  ///////////////////
 
  /*******************************
  * FRAME RECORDER ////////////
    * Keep as final step in draw loop
    * Monitor the recorderIsOn boolean
    * If recorderIsOn, then saveFrame */
  recorder.ready();
  //*******************************
  
  // Check for button presses
  updateControlsFromKeyboard();
}
