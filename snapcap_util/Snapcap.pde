class Snapcap {
  boolean  recordIsOn =         false;
  boolean  cursorIsOn =         true;
  String   sequenceStartTime =  "";

  Snapcap () {
    textAlign(CENTER, CENTER);
    textSize(30);

    printInstructions();
  }

  /*//////////////////////////////////////////////////
   MONITOR and CAPTURE FRAME SEQUENCE */
  // MONITOR recordIsOn from drawloop (is recordIsOn?, is recordIsOn?,... ?)
  void ready() {
    checkRecordFrame();
    checkForRepeatingKey();
  }
  // CAPTURE FRAMES if recordIsOn
  void checkRecordFrame() {
    if (recordIsOn) {
      saveFrame(getFrameID() + "#######.tif");

      // Print text to the main graphics screen
      if (DEBUG) {
        fill(0);
        text("DEBUG: ON \nFrame Record: ON\n" + sequenceStartTime, 0, 0, width, height);
      }
    }
  }
  //  END: CAPTURE FRAME SEQUENCE
  //////////////////////////////////////////////////


  /*//////////////////////////////////////////////////
   TAKE SNAPSHOT  !!!! CALLED on <ENTER> from keyEVENTS.pde
   * snapID = SNAP_PATH + timestamp
   * TAKE SNAP, save it as <snapID>; hide cursor if needed. */
  String snapScreen() {
    return snapScreen(null);
  }
  String snapScreen(String snapID) {
    // Fetch snap's ID if none given.
    if (snapID == null) {
      snapID = getSnapID();
    }
    // Take a snap, but hide and return cursor if needed.
    if (cursorIsOn) {
      toggleCursor();
      save(snapID);       // <---------------------------TAKE SNAPSHOT
      toggleCursor();
    } else {
      save(snapID);       // <---------------------------TAKE SNAPSHOT
    }
    println("\n\tOHH SNAAAP ---> " + snapID + ".tif\n");
    return snapID;
  }
  //  END: SNAP-a-SHOT
  //////////////////////////////////////////////////


  /*//////////////////////////////////////////////////
   GET IDs for sequence, frame, and snap */
  // snapID = SNAP_PATH + snapTime
  String getSnapID() {
    return SNAP_PATH + getSnapTime();
  }

  // snapTime = timestamp + version
  String getSnapTime() {
    return
      nf(year(), 4)   + nf(month(), 2)  + nf(day(), 2)    + "-" +  // yyyymmdd-
      nf(hour(), 2)   + nf(minute(), 2) + nf(second(), 2) + "-" +  // hrmmss-
      nf(millis(), 6) + VERSION;
  }

  // frameID = FRAME_ROOT + sequenceID + frameTime + frameCount
  String getFrameID() {
    return FRAME_ROOT + sequenceStartTime + getFrameTime();
  }

  // frameTime = timestamp to the second
  String getFrameTime() {
    return
      nf(year(), 4) + nf(month(), 2)  + nf(day(), 2)    + "-" +
      nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2) + "-";
  }

  // sequenceStartTime = defines PATH VERSION/timestamp/ to sequence frames
  String getSequenceStartTime() {
    return VERSION + "/" +
      nf(year(), 4) + nf(month(), 2)  + nf(day(), 2)    + "-" +
      nf(hour(), 2) + nf(minute(), 2) + "/";
  }

  //  END: GET IDs
  //////////////////////////////////////////////////


  /*/////////////////////////////////////////////////
   TOGGLE: recordIsOn [Initiated by switch case 'r' in keyEVENTS]
   * Get sequence ID [<VERSION>/<yyyymmdd-hhmm>/<yyyymmdd-hhmmss->]
   * Toggle global: recordIsOn, then show me its state, and if on, show path too.
   * SEQUENCE START-TIME remains until next toggle; (else new dir for every frame ;)
   * Meanwhile frameID within sequence increments with frame count.*/
  void toggleRecording () {
    sequenceStartTime = getSequenceStartTime();
    recordIsOn = !recordIsOn;
    println("\n****************************");
    println("*** recordIsOn = " + recordIsOn + " ***");
    if (recordIsOn) {
      println ("PATH TO SEQUENCE FRAMES ---> " + FRAME_ROOT + sequenceStartTime);
    }
    println("****************************\n" + "\n");
  }
  //  END: TOGGLE RECORDING
  //////////////////////////////////////////////////

  //////////////////////////////////////////////////
  //  TOGGLE CURSOR  =  'c'
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
  //  TOGGLE DEBUG  =  'd'
  void toggleDEBUG () {
    DEBUG = !DEBUG;
    if (DEBUG) {
      println("*** DEBUG: ON ***");
    } else {
      println("*** DEBUG: OFF ***");
    }
  }
  //  END: TOGGLE DEBUG
  //////////////////////////////////////////////////


  //////////////////////////////////////////////////
  // <TAB> Wipe the PGraphic:: <SPACE> Wipe Background
  void clearBackground(int key_pressed) {
    // If spacebar, then clear background screen
    if (key_pressed == 32) {
      background(0);
    } else {
//TODO: Remove hardcoded PGraphic vars      ///////////////////////
      clearPGraphic(templatelayer.offScreenBuffer);
      clearPGraphic(templatelayer.displayLayer);
//TODO: Remove hardcoded PGraphic vars      ///////////////////////
    }
  }
  //////////////////////////////////////////////////

  //////////////////////////////////////////////////
  //  <TAB> = WIPE a specific PGraphics layer
  //     Can set individual layers to transparent!!!!!
  void clearPGraphic(PGraphics p) {
    p.beginDraw();
    p.clear();
    p.endDraw();
  }
  //  END: MAKE PIXELS CLEAR
  //////////////////////////////////////////////////



  //////////////////////////////////////////////////
  void printInstructions() {
    println("");
    println("                 Keyboard controls");
    println("          -----------------------------------");
    println("   <ENTER> SNAP the screen and save to " + SNAP_ROOT);
    println("   <TAB>   Make background transparent");
    println("   'r'     toggle screen recording");
    println("   'c'     toggle cursor");
    println("   'w'     momentary switch, stays engaged until released");
    println("   'i'     Print instructions to console");

    println("          -----------------------------------");
    println("");
  }
  //////////////////////////////////////////////////



  /*////////////////////////////////////////////////////
   //  CREATE REPEATING BUTTONS
   //  ------> CALLED IN THE DRAW LOOP <------------------*/
  void checkForRepeatingKey() {
    /* This function runs only if:
     * Key being pressed is specified in this function,
     * This function shuts down when:
     * ...when keyRelease() sets currentKeyCode to -1
     * or when key pressed is not specified here
     ////////////////////////////////////////////////////*/

    // ALLOW SPECIFIC KEY TO REPEAT
    //    RETURN if NO keyPressed
    //    RETURN if keyPressed but key is not 'w'
    //    EXECUTE CODE if 'w' is pressed
    if ((currentKeyCode == -1) || !(currentKey == 'w')) {
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
      println("\nDEBUG: On draw loop, from checkForRepeatingKey()");
      println("\t---> SYSTEM: Key pressed = '" + key + "'  \tSYSTEM: keyCode    \t  = " + keyCode);
      println("\t---> GLOBAL: currentKey  = '" + currentKey + "' \tGLOBAL: currentKeyCode = " + currentKeyCode + "\n");
    }
    //////////////////////////////////////////////////
  }
  //  END checkForRepeatingKey()
  /////////////////////////////////////////////////////////////
}
