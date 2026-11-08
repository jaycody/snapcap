/*******************************************************************
 * Snapcap: captures and organizes graphics output... in a snap ;)
 *
 * Snapcap wires itself into the sketch. Create it once in setup():
 *
 *     snapcap = new Snapcap(PROJ);
 *
 * and that's it. The version comes from git (see gitVersion() below).
 * To set it by hand instead:  new Snapcap(PROJ, "v2"). No snapcap.ready() at the bottom of draw(), and no
 * key routing from keyPressed(). Processing calls Snapcap on its own:
 *   * draw()     runs right after the sketch's draw(), so frames are
 *                always captured last.
 *   * keyEvent() sees every key press, alongside the sketch's own
 *                keyPressed().
 *
 * Keys:   'r' start/stop recording a frame sequence
 *         ENTER  snap a single frame
 *         'd' toggle the on-screen status (not captured)
 *         'i' print these instructions
 *
 * Output:
 *   snaps:   <snapRoot>/<VERSION>/<PROJ>-yyyymmdd-hhmmss-<millis>-<VERSION>.tif
 *   frames:  <frameRoot>/<VERSION>/yyyymmdd-hhmmss/yyyymmdd-hhmmss-#######.tif
 *            (one folder per recording, named by its start time)
 *******************************************************************/

// Declared public so Processing can find and call draw() and keyEvent().
public class Snapcap {
  String   project;
  String   version;
  String   snapRoot  = "./snaps/";
  String   frameRoot = "./frames/";

  boolean  recordIsOn    = false;
  boolean  showStatus    = true;
  String   sequencePath  = "";

  char     recordKey = 'r';
  boolean  keysOn    = true;

  // Version detected from git
  Snapcap(String project) {
    configure(project, gitVersion());
  }

  // Version set by hand
  Snapcap(String project, String version) {
    configure(project, version);
  }

  void configure(String project, String version) {
    this.project = project;
    this.version = version;
    println("snapcap: " + project + " @ " + version);

    registerMethod("draw", this);
    registerMethod("keyEvent", this);

    printInstructions();
  }

  /*//////////////////////////////////////////////////
   CALLED BY PROCESSING after every sketch draw() */
  public void draw() {
    if (recordIsOn) {
      saveFrame(sequencePath + timestamp(true) + "-#######.tif");
    }
    // Drawn after the save, so it shows on screen but never in a frame.
    if (showStatus) {
      drawStatus();
    }
  }

  /*//////////////////////////////////////////////////
   CALLED BY PROCESSING on every key event */
  public void keyEvent(processing.event.KeyEvent e) {
    if (!keysOn || e.getAction() != processing.event.KeyEvent.PRESS) {
      return;
    }
    char k = e.getKey();
    if (k == recordKey) {
      toggleRecording();
    } else if (k == ENTER || k == RETURN) {
      snapScreen();
    } else if (k == 'd') {
      showStatus = !showStatus;
    } else if (k == 'i') {
      printInstructions();
    }
  }

  /*//////////////////////////////////////////////////
   SETTINGS: call these from setup() if the defaults don't fit */
  void setRecordKey(char k)       { recordKey = k; }
  void keysOff()                  { keysOn = false; }
  void setSnapRoot(String path)   { snapRoot = withSlash(path); }
  void setFrameRoot(String path)  { frameRoot = withSlash(path); }

  /*//////////////////////////////////////////////////
   RECORD: each recording gets its own folder, named by its start time,
   so stopping and starting again never overwrites an earlier take. */
  void toggleRecording() {
    recordIsOn = !recordIsOn;
    if (recordIsOn) {
      sequencePath = frameRoot + version + "/" + timestamp(true) + "/";
      println("\n*** Recording ON ---> " + sequencePath + "\n");
    } else {
      println("\n*** Recording OFF ***\n");
    }
  }

  /*//////////////////////////////////////////////////
   SNAP: save the current frame as a single image */
  String snapScreen() {
    String snapID = snapRoot + version + "/" + project + "-"
      + timestamp(true) + "-" + nf(millis(), 6) + "-" + version + ".tif";
    save(snapID);
    println("\n\tOHH SNAAAP ---> " + snapID + "\n");
    return snapID;
  }

  /*//////////////////////////////////////////////////
   VERSION FROM GIT, via `git describe --tags --always --dirty`:
     v1.0.0                     exactly on a tag
     v1.0.0-3-g47fc45b          3 commits past the tag
     v1.0.0-3-g47fc45b-dirty    ...with uncommitted edits
     47fc45b                    no tags yet
   Falls back to "nogit" when git or the repo can't be found
   (an exported app, a machine without git). */
  String gitVersion() {
    try {
      Process git = new ProcessBuilder("git", "describe", "--tags", "--always", "--dirty")
        .directory(new File(sketchPath()))
        .redirectErrorStream(true)
        .start();
      String out = new BufferedReader(new InputStreamReader(git.getInputStream())).readLine();
      if (git.waitFor() == 0 && out != null && out.trim().length() > 0) {
        return out.trim().replace('/', '_');  // a tag like "release/1.0" must not add folders
      }
    }
    catch (Exception e) {
    }
    return "nogit";
  }

  /*//////////////////////////////////////////////////
   HELPERS */
  // yyyymmdd-hhmm, or yyyymmdd-hhmmss with seconds
  String timestamp(boolean withSeconds) {
    String stamp = nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + "-"
      + nf(hour(), 2) + nf(minute(), 2);
    return withSeconds ? stamp + nf(second(), 2) : stamp;
  }

  String withSlash(String path) {
    return path.endsWith("/") ? path : path + "/";
  }

  void drawStatus() {
    pushStyle();
    noStroke();
    textAlign(LEFT, TOP);
    textSize(14);
    if (recordIsOn) {
      fill(255, 0, 0);
      ellipse(16, 16, 12, 12);
      fill(255);
      text("REC  " + sequencePath, 28, 8);
    } else {
      fill(255, 120);
      text("snapcap: 'r' record, ENTER snap, 'd' hide", 10, 8);
    }
    popStyle();
  }

  void printInstructions() {
    println("");
    println("                 snapcap keys");
    println("          -----------------------------------");
    println("   '" + recordKey + "'     start/stop recording frames to " + frameRoot + version + "/");
    println("   <ENTER> snap a single frame to " + snapRoot + version + "/");
    println("   'd'     show/hide the on-screen status");
    println("   'i'     print these instructions");
    println("          -----------------------------------");
    println("");
  }
}
