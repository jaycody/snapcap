//////////////////////////////
// KeyEVENTS - flipping switches!
//   and mouseEvents too


////////////////////////////////////////////////////////////
///// GLOBALS for MOMENTARY SWITCH --> pressIsOn --> releaseIsOff
char    currentKey; 
int     currentKeyCode = -1;
boolean DEBUG = true;
////////////////////////////////////////////////////////////


////////////////////////////////////////////////////
// ON MOUSE PRESS ---> DO THIS
void mousePressed() {
  if (DEBUG) {println("\n\t This is a mousePressed() event \n");}
}
////////////////////////////////////////////////////



////////////////////////////////////////////////////////////
///// MOMENTARY SWITCH: RESET  --> releaseIsOff (aka PULL-DOWN RESISTOR)
////////////////////////////////////////////////////////////
// Clear the keyPressed value from GLOBAL upon key release.
//     * Forget the current key when it's released
void keyReleased() {
  currentKeyCode = -1;
}
//////////////////////////////////////



////////////////////////////////////////////////////////////
///// MOMENTARY SWITCH: INITIATE and EVALUATE --> pressIsOn --> releaseIsOff
//       list of momentary switches so far: ENTER and TAB
////////////////////////////////////////////////////////////
void keyPressed() {
  // Remember the current key when it's pressed.
  currentKeyCode  = keyCode; 
  currentKey      = key;

  //////////////////////////////////////////////////
  //  SNAP THE SCREEN ----> PRESS <ENTER> (MOMENTARY SWITCH)
  /////////////////////////////////////////////////
  if (currentKeyCode==ENTER) {
    recorder.snapScreen();
  }

  /////////////////////////////////////////////////
  //  CLEAR the BACKGROUND ---> PRESS <TAB> (MOMENTARY SWITCH)
  /////////////////////////////////////////////////
  if (currentKeyCode==TAB) {
    background(0);
    // clear() needs a specific pgraphic
    clear(); 
    // or use utility that takes a PGraphic argument
    //makePixelsClearAgain(makePixelsClearForThisPGraphic);
  } 

  /////////////////////////////////////////////////
  ////// SWITCH CASES [MOMENTARY]
  // Handle standard keys as a switch
  switch(currentKey) {

    //////////////////////////////////////////////////
    //  TOGGLE SCREEN RECORDING  =  'r'
    case 'r':
      recorder.toggleRecording();
      break;

    //////////////////////////////////////////////////
    //  TOGGLE CURSOR  =  'c'
    case 'c':
      toggleCursor();
      break;
  }

  //////////////////////////////////////////////////
  if (DEBUG) {
    println("\nDEBUG: On key press from keyPressed() function");
    println("\t---> SYSTEM: Key pressed = '" + key + "'  \tSYSTEM: keyCode    \t  = " + keyCode);
    println("\t---> GLOBAL: currentKey  = '" + currentKey + "' \tGLOBAL: currentKeyCode = " + currentKeyCode + "\n");
  }
  //////////////////////////////////////////////////
}
////// END KEYPRESSED
////////////////////////////////////////////////////////////




/*////////////////////////////////////////////////////
//  MAKE SPECIFIC BUTTON REPEAT
//  ------> CALLED IN THE DRAW LOOP <------------------*/
void updateControlsFromKeyboard() {
  /* This function runs only if:
     * Key being pressed is specified in this function, 
  * This function shuts down when:
     * ...when keyRelease() sets currentKeyCode to -1
     * or when key pressed is not specified here 
////////////////////////////////////////////////////*/

  // ALLOW SPECIFIC KEY TO REPEAT
  if ((currentKeyCode == -1) || !(currentKey == 'w')){
    //clearButtons();
    return;
  }

  /////////////////////////////////////////////////
  //  SHOW REPEATING KEY: (good for selecting source images) 
  if (currentKey == 'w') {
    println("'" + currentKey + "' isA repeating key. Use it wisely! (eg. selecting source image)");
  }

  //////////////////////////////////////////////////
  if (DEBUG) {
    println("\nDEBUG: On draw loop, from updateControlsFromKeyboard()");
    println("\t---> SYSTEM: Key pressed = '" + key + "'  \tSYSTEM: keyCode    \t  = " + keyCode);
    println("\t---> GLOBAL: currentKey  = '" + currentKey + "' \tGLOBAL: currentKeyCode = " + currentKeyCode + "\n");
  }
  ////////////////////////////////////////////////// 
}
//  END updateControlsFromKeyboard()
/////////////////////////////////////////////////////////////





////////////////////////////////////////////////////
//  ON KEY PRESS ---> 
//      * use 'key' and 'keyCode'
//      * create MOMENTARY SWITCHS

//////////////////////////////////////
//  CREATE MOMENTARY SWITCH 
// Current keyCode for the pressed key

//   'key' ---> the 'system variable'
//      The system variable 'key' always contains the value 
//      of the most recent key on the keyboard (either pressed or released). 

//   'keyCode' --> For non-ASCII keys, use the 'keyCode' variable. 
//      The keys included in the ASCII specification 
//      (BACKSPACE, TAB, ENTER, RETURN, ESC, and DELETE) 
//      do not require checking to see if the key is coded, 
//      and you should simply use the 'key' variable instead of 'keyCode'