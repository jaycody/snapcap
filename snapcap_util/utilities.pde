////////////////////////////////////
// UTILITY FUNCTIONS
////////////////////////////////////


//////////////////////////////////////////////////
//  TOGGLE CURSOR  =  'c'
//     Exists outside of Recorder object to reduce dependency.... but?
void toggleCursor () {
  cursorIsOn = !cursorIsOn;    
  if (cursorIsOn) {
    cursor();
    println("*** Cursor VISIBLE again. ***");
  } else {
    noCursor();
    println("*** Cursor HIDDEN for screenshot ***");
    println("\t---> Screenshot SNAPPED!! <---");
  }
}
//  END: TOGGLE CURSOR
//////////////////////////////////////////////////


//////////////////////////////////////////////////
//  SET PIXELS TRANSPARENT FOR PGRAPHIC  =  'TAB'
void makePixelsClearAgain(PGraphics p) {
    p.beginDraw();
    p.clear();
    p.endDraw();
}
//  END: MAKE PIXELS CLEAR
//////////////////////////////////////////////////


//////////////////////////////////////////////////
//   PROVIDE SOME POINTERS
void printInstructions() {
  println("");
  println("                 Keyboard controls");
    println("          -----------------------------------");
     println("   ENTER  takes a snapshot and saves it to " + SNAP_ROOT);
     println("   TAB     clears pgraphic background to transparent");
     println("   'r'     toggle screen recording");
     println("   'c'     toggle cursor");
     println("   'a,s'     minDepth");
     println("   'z,x'     maxDepth");
     println("   'q'     momentary switch, stays engaged until released");
     println("   'w'     momentary switch, stays engaged until released");
     println("   '-'     ");

     println("          -----------------------------------");
     println("");
}
//////////////////////////////////////////////////
