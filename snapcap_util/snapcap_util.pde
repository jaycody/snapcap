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
/*////////////////////////////////////////////////////////////
 **** TODO ****
 [ ] Use green/red tint to show recordIsOn state (implement after the saveFrame)
 [ ] Add documentation to README
 [ ] Write bash script that adds snapcap_util boilerplate to Procesing sketch
 
//////////////////////////////////////////////////////////////
 **** USAGE **** 
 **       < r >      start/stop recorder
 **       < ENTER >  snap single frame
 **       < c >      toggle cursor
/////////////////////////////////////////////////////////////
 **** DATA PATHS **** 
 *       SNAP_PATH:  <SNAP_ROOT>/<VERSION>/
 *        snapTime:  PROJ- + timestamp + VERSION
 *          snapID:  SNAP_PATH + snapName
 *
 * FRAME SEQUENCES:  "./frames/VERSION/dirStartTime<yyyymmdd-hhmm/"
 *      FRAME PATH:  "./frames/VERSION/dirStartTime<yyyymmdd-hhmm/yyyymmdd-hhmmss-######.tif"
 *    dirStartTime:  "yyyymmdd-hhmm/yyyymmdd-hhmmss-"
 *      FRAME NAME:  "yyyymmdd-hhmmss-" + "######.tif"  [20210324-013412-000156.tif]
 /////////////////////////////////////////////////////////// 
 **** SETUP **** 
 * symlink SNAP_PATH and FRAME_PATH from within this sketch to centralized storage: 
     ln -s /Users/jstephens/Dropbox/_SNAPS/201806-kidsPace/frames FRAME_PATH
     ln -s /Users/jstephens/Dropbox/_SNAPS/201806-kidsPace/snaps SNAP_PATH
/////////////////////////////////////////////////////////////
***** NOTE *****
* All images saved from the main drawing window will be opaque. 
      --> To save images without a background, use createGraphics().
///////////////////////////////////////////////////////////*/

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
  ** --> Keep as final step in draw loop
  *******************************
    * Monitor the recorderIsOn boolean
    * If recorderIsOn, then saveFrame */
  recorder.ready();
  
  
  // Check for button presses
  updateControlsFromKeyboard();
}
