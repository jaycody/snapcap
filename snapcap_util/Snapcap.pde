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
 *   snaps:   <snapRoot>/<VERSION>/<PROJ>-yyyymmdd-hhmmss-<millis>-<VERSION>.png
 *   frames:  <frameRoot>/<VERSION>/yyyymmdd-hhmmss/yyyymmdd-hhmmss-#######.tga
 *            (frames .tga and snaps .png by default; snapcap.json can
 *            pick tif, tga, png or jpg. TGA saves fastest, PNG is smallest)
 *            (one folder per recording, named by its start time)
 *
 * Settings: snapcap.json in the sketch folder, if there is one, sets
 * the folders, keys, image format and overlay (see loadConfig() below).
 * Anything it leaves out keeps the default. Setters called in setup()
 * win over the file.
 *
 * Storage check: if frames/ or snaps/ is a link to a drive that isn't
 * mounted (or any root can't be reached), output goes to frames_local/
 * and snaps_local/ inside the sketch instead, with a warning in the
 * console and on screen. Checked about once a second, at every take and
 * snap, and on every recorded frame.
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
  String   takeRoot      = "";   // where the current take is going
  String   takeFolder    = "";   // <VERSION>/<start time>/

  // Fallbacks for when a storage link or drive can't be reached.
  String   localSnapRoot  = "./snaps_local/";
  String   localFrameRoot = "./frames_local/";
  boolean  storageOffline = false;
  int      lastStorageCheck = -1000;

  char     recordKey  = 'r';
  char     snapKey    = ENTER;     // RETURN works too
  char     overlayKey = 'd';
  char     helpKey    = 'i';
  boolean  keysOn     = true;

  String   frameFormat = "tga";   // lossless and fastest to save
  String   snapFormat  = "png";   // lossless, smallest, opens anywhere
  String   configFile  = "snapcap.json";

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
    registerMethod("dispose", this);

    loadConfig();
    printInstructions();
  }

  /*//////////////////////////////////////////////////
   CALLED BY PROCESSING after every sketch draw() */
  public void draw() {
    if (millis() - lastStorageCheck > 1000) {
      checkStorage();
    }
    if (recordIsOn) {
      // Drive went away mid-take: finish the take locally, same folder name.
      if (!takeRoot.equals(localFrameRoot) && !reachable(takeRoot)) {
        takeRoot = localFrameRoot;
        sequencePath = takeRoot + takeFolder;
        checkStorage();
        println("*** snapcap: rest of this take goes to " + sequencePath + "\n");
      }
      writeLater(sequencePath + timestamp(true) + "-" + nf(frameCount, 7) + "." + frameFormat);
    }
    // Drawn after the save, so it shows on screen but never in a frame.
    if (showStatus) {
      drawStatus();
    }
    // Shown even with the status hidden, and never captured.
    if (storageOffline) {
      drawStorageWarning();
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
    } else if (k == snapKey || (snapKey == ENTER && k == RETURN)) {
      snapScreen();
    } else if (k == overlayKey) {
      showStatus = !showStatus;
    } else if (k == helpKey) {
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
   SETTINGS FILE: snapcap.json in the sketch folder. snap_new_project
   writes one; with no file, or a field left out, the default stays.
     {
       "snapcap": { "release": "v0.1-beta.0-9-gcec5a2c", "created": "2026-11-08" },
       "storage": { "frames": "./frames/", "snaps": "./snaps/",
                    "framesLocal": "./frames_local/", "snapsLocal": "./snaps_local/" },
       "keys":    { "enabled": true, "record": "r", "snap": "ENTER",
                    "overlay": "d", "help": "i" },
       "format":  { "frames": "tga", "snaps": "png" },
       "overlay": { "show": true }
     }
   The version is not in the file: it always comes live from git. */
  void loadConfig() {
    File f = new File(sketchPath(configFile));
    if (!f.isFile()) {
      return;
    }
    JSONObject c;
    try {
      c = loadJSONObject(f.getAbsolutePath());
    }
    catch (Exception e) {
      c = null;
    }
    if (c == null) {
      println("snapcap: couldn't read " + configFile + ", using defaults");
      return;
    }
    JSONObject storage = cfgSection(c, "storage");
    frameRoot      = withSlash(cfgString(storage, "frames", frameRoot));
    snapRoot       = withSlash(cfgString(storage, "snaps", snapRoot));
    localFrameRoot = withSlash(cfgString(storage, "framesLocal", localFrameRoot));
    localSnapRoot  = withSlash(cfgString(storage, "snapsLocal", localSnapRoot));

    JSONObject keys = cfgSection(c, "keys");
    keysOn     = cfgFlag(keys, "enabled", keysOn);
    recordKey  = keyFrom(cfgString(keys, "record", null), recordKey);
    snapKey    = keyFrom(cfgString(keys, "snap", null), snapKey);
    overlayKey = keyFrom(cfgString(keys, "overlay", null), overlayKey);
    helpKey    = keyFrom(cfgString(keys, "help", null), helpKey);

    JSONObject format = cfgSection(c, "format");
    frameFormat = imageFormat(cfgString(format, "frames", frameFormat), frameFormat);
    snapFormat  = imageFormat(cfgString(format, "snaps", snapFormat), snapFormat);

    showStatus = cfgFlag(cfgSection(c, "overlay"), "show", showStatus);
    println("snapcap: settings from " + configFile);
  }

  // JSON helpers that fall back to the default instead of throwing.
  JSONObject cfgSection(JSONObject c, String name) {
    try {
      return c.hasKey(name) ? c.getJSONObject(name) : null;
    }
    catch (Exception e) {
      return null;
    }
  }

  String cfgString(JSONObject o, String key, String fallback) {
    try {
      return (o != null && o.hasKey(key)) ? o.getString(key) : fallback;
    }
    catch (Exception e) {
      return fallback;
    }
  }

  boolean cfgFlag(JSONObject o, String key, boolean fallback) {
    try {
      return (o != null && o.hasKey(key)) ? o.getBoolean(key) : fallback;
    }
    catch (Exception e) {
      return fallback;
    }
  }

  // "ENTER", "SPACE", "TAB" or a single character
  char keyFrom(String name, char fallback) {
    if (name == null) return fallback;
    if (name.equalsIgnoreCase("ENTER") || name.equalsIgnoreCase("RETURN")) return ENTER;
    if (name.equalsIgnoreCase("SPACE")) return ' ';
    if (name.equalsIgnoreCase("TAB")) return TAB;
    if (name.length() == 1) return name.charAt(0);
    println("snapcap: unknown key \"" + name + "\" in " + configFile + ", keeping " + keyName(fallback));
    return fallback;
  }

  String keyName(char k) {
    if (k == ENTER || k == RETURN) return "<ENTER>";
    if (k == ' ') return "<SPACE>";
    if (k == TAB) return "<TAB>";
    return "'" + k + "'";
  }

  // Formats Processing can save: tif, tga, png, jpg
  String imageFormat(String name, String fallback) {
    String f = name.toLowerCase().replace(".", "");
    if (f.equals("jpeg")) f = "jpg";
    if (f.equals("tiff")) f = "tif";
    if (f.equals("tif") || f.equals("tga") || f.equals("png") || f.equals("jpg")) return f;
    println("snapcap: unknown image format \"" + name + "\" in " + configFile + ", keeping " + fallback);
    return fallback;
  }

  /*//////////////////////////////////////////////////
   RECORD: each recording gets its own folder, named by its start time,
   so stopping and starting again never overwrites an earlier take. */
  void toggleRecording() {
    recordIsOn = !recordIsOn;
    if (recordIsOn) {
      checkStorage();
      takeRoot     = activeRoot(frameRoot, localFrameRoot);
      takeFolder   = version + "/" + timestamp(true) + "/";
      sequencePath = takeRoot + takeFolder;
      println("\n*** Recording ON ---> " + sequencePath + "\n");
    } else {
      println("\n*** Recording OFF ***\n");
    }
  }

  /*//////////////////////////////////////////////////
   SNAP: save the current frame as a single image */
  String snapScreen() {
    checkStorage();
    String snapID = activeRoot(snapRoot, localSnapRoot) + version + "/" + project + "-"
      + timestamp(true) + "-" + nf(millis(), 6) + "-" + version + "." + snapFormat;
    writeLater(snapID);
    println("\n\tOHH SNAAAP ---> " + snapID + "\n");
    return snapID;
  }

  /*//////////////////////////////////////////////////
   BACKGROUND WRITER
   Encoding and writing a big image takes far longer than one frame,
   so draw() only copies the screen and hands the copy to a few writer
   threads. If the disk falls behind and the queue fills up, draw()
   writes that frame itself: the sketch slows down, but no frame is
   ever dropped. Everything queued is written before the sketch exits. */
  int writerThreads = 3;
  int writerQueue   = 30;   // about 300 MB of frames at 2560x960
  java.util.concurrent.ThreadPoolExecutor writer;

  void writeLater(String path) {
    final PImage shot = get();          // copy of the screen, at full pixel density
    shot.format = RGB;                  // no alpha, same as saveFrame()
    final String file = savePath(path);
    createPath(file);                   // make the folders now, on this thread
    if (writer == null) {
      writer = new java.util.concurrent.ThreadPoolExecutor(
        writerThreads, writerThreads, 0L, java.util.concurrent.TimeUnit.MILLISECONDS,
        new java.util.concurrent.ArrayBlockingQueue<Runnable>(writerQueue),
        new java.util.concurrent.ThreadPoolExecutor.CallerRunsPolicy());
    }
    writer.execute(new Runnable() {
      public void run() {
        if (!shot.save(file)) {
          println("*** snapcap: couldn't write " + file);
        }
      }
    });
  }

  // Frames still waiting to be written
  int pendingWrites() {
    return writer == null ? 0 : writer.getQueue().size() + writer.getActiveCount();
  }

  // Called by Processing when the sketch closes: finish every write.
  public void dispose() {
    if (writer == null) return;
    int left = pendingWrites();
    if (left > 0) println("snapcap: finishing " + left + " frames...");
    writer.shutdown();
    try {
      writer.awaitTermination(2, java.util.concurrent.TimeUnit.MINUTES);
    }
    catch (InterruptedException e) {
    }
  }

  /*//////////////////////////////////////////////////
   STORAGE CHECK
   frames/ and snaps/ may be links into central storage, such as an
   external drive. When the drive isn't mounted the link points nowhere,
   and saving there would fail. So check first, and fall back to a
   local folder inside the sketch. */

  // Can Processing save under this root?
  boolean reachable(String root) {
    java.nio.file.Path p = java.nio.file.Paths.get(sketchPath(root));
    if (java.nio.file.Files.isDirectory(p)) {
      return true;                     // a real folder, or a link to one
    }
    if (java.nio.file.Files.isSymbolicLink(p) || java.nio.file.Files.exists(p)) {
      return false;                    // a link to nowhere, or a file in the way
    }
    // Not made yet. Processing creates it, but only if its parent exists:
    // never create a stand-in for an unmounted /Volumes/<drive>.
    File parent = p.toFile().getParentFile();
    return parent != null && parent.isDirectory();
  }

  // The root to save under right now.
  String activeRoot(String root, String localRoot) {
    return reachable(root) ? root : localRoot;
  }

  // Track whether storage is reachable, and say so when it changes.
  void checkStorage() {
    lastStorageCheck = millis();
    boolean framesOk = reachable(frameRoot);
    boolean snapsOk  = reachable(snapRoot);
    boolean offline  = !framesOk || !snapsOk;
    if (offline && !storageOffline) {
      println("\n*** snapcap: STORAGE OFFLINE ***");
      if (!framesOk) println("    " + frameRoot + " can't be reached, frames go to " + localFrameRoot);
      if (!snapsOk)  println("    " + snapRoot + " can't be reached, snaps go to " + localSnapRoot);
      println("    (drive unplugged, or the link points nowhere)\n");
    } else if (!offline && storageOffline) {
      println("\n*** snapcap: storage is back. New takes and snaps go to "
        + frameRoot + " and " + snapRoot + "\n");
    }
    storageOffline = offline;
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
      String out = new BufferedReader(new java.io.InputStreamReader(git.getInputStream())).readLine();
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
      text("snapcap: " + keyName(recordKey) + " record, " + keyName(snapKey) + " snap, "
        + keyName(overlayKey) + " hide", 10, 8);
    }
    popStyle();
  }

  void drawStorageWarning() {
    pushStyle();
    noStroke();
    textAlign(LEFT, TOP);
    textSize(14);
    fill(0, 160);
    rect(0, 28, width, 22);
    fill(255, 200, 0);
    text("STORAGE OFFLINE: saving to " + localFrameRoot + " and " + localSnapRoot, 10, 32);
    popStyle();
  }

  String pad(String s) {
    while (s.length() < 8) s += " ";
    return s;
  }

  void printInstructions() {
    println("");
    println("                 snapcap keys");
    println("          -----------------------------------");
    if (!keysOn) {
      println("   keys are off");
    }
    println("   " + pad(keyName(recordKey))  + "start/stop recording frames to " + frameRoot + version + "/");
    println("   " + pad(keyName(snapKey))    + "snap a single frame to " + snapRoot + version + "/");
    println("   " + pad(keyName(overlayKey)) + "show/hide the on-screen status");
    println("   " + pad(keyName(helpKey))    + "print these instructions");
    println("          -----------------------------------");
    println("");
  }
}
