//////////////////////////////
// KeyEVENTS

////////////////////////////////////////////////////
// ON MOUSE PRESS ---> DO THIS
void mousePressed() {
  if (DEBUG) {println("\n\t This is a mousePressed() event \n");}
}
////////////////////////////////////////////////////


////////////////////////////////////////////////////////////
// ON RELEASE, CLEAR SWITCH
//      functions like a pull-down resistor
void keyReleased() {
  currentKeyCode = -1;
}
//////////////////////////////////////


////////////////////////////////////////////////////////////
// ON KEY PRESS ---> DO THIS:
void keyPressed() {
  // Remember the current key when it's pressed.
  currentKeyCode  = keyCode; 
  currentKey      = key;

  //////////////////////////////////////////////////
  //  SNAP SCREEN ----> PRESS <ENTER>
  if (currentKeyCode==ENTER) {
    snapcap.snapScreen();
  }

  /////////////////////////////////////////////////
  //  CLEAR BACKGROUND ---> PRESS <TAB> (or SPACE BAR:32)
  if ((currentKeyCode==TAB) || (currentKeyCode==32)){
    snapcap.clearBackground(currentKeyCode);
  } 

  /////////////////////////////////////////////////
  ////// SWITCH CASES
  switch(currentKey) {
    case 'r':
      snapcap.toggleRecording();
      break;
    case 'c':
      snapcap.toggleCursor();
      break;
    case 'i':
      snapcap.printInstructions();
      break;
    case 'd':
      snapcap.toggleDEBUG();
      break;
  }
/////////////////////////////////////////////////

  /////////////**************************|||||||
  if (DEBUG) {
    println("\nDEBUG: On key press from keyPressed() function");
    println("\t---> SYSTEM: Key pressed = '" + key + "'  \tSYSTEM: keyCode    \t  = " + keyCode);
    println("\t---> GLOBAL: currentKey  = '" + currentKey + "' \tGLOBAL: currentKeyCode = " + currentKeyCode + "\n");
  }
  ////////////***************************|||||||
}
////// END KEYPRESSED
////////////////////////////////////////////////////////////
