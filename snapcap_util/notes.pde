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
* Recorder captures whatever is on the main drawing window prior to the saveFrame is called.
    * eg, if called first in draw, saveFrame captures blank screen
///////////////////////////////////////////////////////////*/



  ////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////
  //    RECORD FRAMES
  ////////////////////
  /* snapID pattern: VERSION/yyyymmdd-hrmm/yyyymmdd-hrmm-######.tiff
    * For each new sequence, 
        * Make new directory where
        * SEQUENCE DIRECTORY NAME = sequence START-TIME to the minute. (this should be to the seconds)
                                    <yyyymmdd-hrmm> 20210324-1023,
    * For each new frame in sequence:
        * Save frame to its sequence directory where 
        * FRAME NAME = frame's SNAP-TIME to the seconds 
                       PLUS the frame # in the current sketch where 
                           - frame # = <0-999,999> (ie ######.tif) AND
                           - frame # = ZERO at sketch start.
        
  //  * Resets frame# to ZERO only at sketch start to avoid... 
          duplicating (and rewriting) frame.000001 in the current sequence directory 
          (on condition where frame recording stops/restarts < 60secs, thus landing in the same sequence directory)
          
  // destination:      kidsPace/frames --> symlinked to Dropbox/_SNAPS/201806-kidsPace/frames      
  // symlink command:
  //        ln -s /Users/jstephens/Dropbox/_SNAPS/201806-kidsPace/snaps ./snaps
  // subdirectory:     
  //        in 'snaps/<version>' (determined by global VERSION)
  ////////////////////////////////////////////////////*/
/*************
A note about IMAGE FORMAT: .TGA is the fastest image type when using saveFrame()
 It's also uncompressed....
The bigger your output , the more it slows down your sketch. While there is no 
magic solution, the fastest image format to save an image sequence is… TGA.  
Since this is an uncompressed format it saves much faster
than for example JPG and it also provides 100% quality. 
The price you pay is the size of the output files.
*/

/*/////////////////////////////////////////////////////////////
keyCode
  Variable to detect special (non-ASCII) keys
    * the arrow keys (UP, DOWN, LEFT, and RIGHT) 
    * ALT, CONTROL, and SHIFT.

  When checking for these keys, it can be useful to first check if the key is coded. 
  This is done with the conditional if (key == CODED), as shown in the example above.
  
  if (key == CODED) {
    if (keyCode == UP) {
      fillVal = 255;
    } else if (keyCode == DOWN) {
      fillVal = 0;

  The keys included in the ASCII specification 
  (BACKSPACE, TAB, ENTER, RETURN, ESC, and DELETE) 
  do not require checking to see if the key is coded; 
  for those keys, you should simply use the key variable directly (and not keyCode).
//////////////////////////////////////////////////////////////

key
  The system variable "key" contains value of most recent key (pressed or released).

/*////////////////////////////////////////////////////////////*/



/*/////////////////////////////////////////////////////////////
key
  The system variable key always contains the value of the most recent key (either pressed or released).
  For non-ASCII keys, use the keyCode variable


/*////////////////////////////////////////////////////////////*/



////////////////////////////////////////////////////
  /************************************************
  // PER-VERTEX COLOR FILLS within beginShape-endShape
///////////////////////////////////////////////////
  beginShape();
  fill(255, 0, 0);
  vertex(height-mouseY, width-mouseX);
  vertex(100, 100);
  fill(0, 255, 0);
  vertex(400, 100);
  fill(0, 0, 255);
  vertex(mouseX, mouseY);
  endShape();
  */
