/*******************************************************************
 * snapcap du videoalchemy
 *     Boilerplate util to record and organize a sketch's output. 
 *
 * Copyright (c) 2021 Jason Stephens
 * The MIT License (MIT)
 *******************************************************************/

/*////////////////////////////////////////////////////////////
 **** USAGE
 **       < r >      start/stop recorder
 **       < ENTER >  snap single frame
 **       < c >      toggle cursor
 ///////////////////////////////////////////////////////////*/ 


////////////////////////////////////////////////////////////
///// GLOBALS
String PROJ       = "";  // Recorder class                    
String VERSION    = "";                                  
String SNAP_PATH  = ("./snaps/");   //("../../../snaps/");        
String FRAME_PATH = ("./frames/"); //("../../../frames/");     
////////////////////////////////////////////////////////////
// SNAP PATH:  "./snaps/VERSION/PROJ/yyyymmdd-hhmmss-mils+VERSION.tif"
// SNAP NAME:  "<PROJ>-yyyymmdd-hhmmss-mills-<VERSION>.tif"
//                      [test_frame_location-20210324-013416-8186-prototype.tif]
//
// FRAME SEQUENCES:  "./frames/VERSION/dirStartTime<yyyymmdd-hhmm/"
//      FRAME PATH:  "./frames/VERSION/dirStartTime<yyyymmdd-hhmm/yyyymmdd-hhmmss-######.tif"
//    dirStartTime:  "yyyymmdd-hhmm/yyyymmdd-hhmmss-"
//      FRAME NAME:  "yyyymmdd-hhmmss-" + "######.tif"  [20210324-013412-000156.tif]


Recorder recorder;

boolean cursorIsOn = true;


void setup() {
  size(1280, 480, P2D);
  recorder = new Recorder();
  printInstructions();
}

void draw() {
  
  ////////////////////
  // magic here
  ellipse(mouseX,mouseY, mouseX, mouseY);
  ///////////////////
  ///////////////////
  
  
  /*******************************
  * FRAME RECORDER ////////////
  ** --> Final step of draw loop: record the drawing
  *******************************/
  recorder.ready();
  // Check for button presses
  // updateControlsFromKeyboard();
}
