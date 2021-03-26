class Recorder {
  boolean  recordIsOn =         false;
  boolean  cursorIsOn =         true;
  String   sequenceStartTime =  "";

  Recorder () {
  }

  /*//////////////////////////////////////////////////
  MONITOR and CAPTURE FRAME SEQUENCE */
  // MONITOR recordIsOn from drawloop (is recordIsOn?, is recordIsOn?,... ?)
  void ready() {
    checkRecordFrame();
  }
  // CAPTURE FRAMES if recordIsOn
  void checkRecordFrame() {
    if (recordIsOn) {
      saveFrame(getFrameID() + "#######.tif");
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
  // frameID = FRAME_ROOT + sequenceID + frameTime + frameCount
  String getFrameID() {
    return FRAME_ROOT + sequenceStartTime + getFrameTime();
  } 
 // sequenceStartTime = VERSION/timestamp/  isA PATH to sequence frames
  String getSequenceStartTime() {
    return VERSION + "/" +
      nf(year(), 4) + nf(month(), 2)  + nf(day(), 2)    + "-" + 
      nf(hour(), 2) + nf(minute(), 2) + "/";
  }
  // snapTime = timestamp-version     snap's naming convention
  String getSnapTime() {
    return 
      nf(year(), 4)   + nf(month(), 2)  + nf(day(), 2)    + "-" +  // yyyymmdd-
      nf(hour(), 2)   + nf(minute(), 2) + nf(second(), 2) + "-" +  // hrmmss-
      nf(millis(), 6) + VERSION;                                  
  }
  // frameTime = frame naming
  String getFrameTime() {
    return 
      nf(year(), 4) + nf(month(), 2)  + nf(day(), 2)    + "-" +
      nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2) + "-";
  } 
  //  END: GET IDs
  //////////////////////////////////////////////////


  /*/////////////////////////////////////////////////
  TOGGLE GLOBAL: recordIsOn
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
  //  END: TOGGLE GLOBAL recordIsOn 
  //////////////////////////////////////////////////

}
