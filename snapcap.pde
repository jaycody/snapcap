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
String PROJ       = "test_frame_location";  // Recorder class                    
String VERSION    = "prototype";                                  
String SNAP_PATH  = ("./snaps/");   //("../../../snaps/");        
String FRAME_PATH = ("./frames/"); //("../../../frames/");     
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
