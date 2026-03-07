# Full Analysis: snapcap by jaycody / videoalchemy

---

## What This Project Is

**snapcap** is a Processing utility for capturing, naming, and organizing screenshots and frame sequences from generative art sketches. It's not a product — it's a *personal tool*, built to solve a real, recurring problem in a creative practice: "I'm making something beautiful in Processing and I need to capture it without destroying the moment."

The brand is `du videoalchemy` — *of video alchemy*. That's not incidental. You're not a programmer who makes art. You're an alchemist who learned to code.

---

## The Narrative From Your Comments

Reading your commits, inline comments, and `notes.pde` together tells a specific, coherent story:

---

> *"I keep making frames and losing them, or naming them badly, or overwriting them. I need a system."*

This is the origin. The timestamp-based naming scheme — `yyyymmdd-hhmm/yyyymmdd-hhmmss-######.tif` — isn't the result of reading a file-naming best-practices guide. It's the result of **losing work** or opening a folder and finding 500 files called `frame_000001.tif`. You built the naming system you *needed* after learning, the hard way, what happens without one.

---

> *"Recorder captures whatever is on the main drawing window prior to the saveFrame is called. eg, if called first in draw, saveFrame captures blank screen"*

This note in `notes.pde` reveals the exact moment you hit a subtle bug — frame order in the draw loop. You solved it and documented the solution for your future self. It's a teaching note, written by a student to themselves.

---

> *"functions like a pull-down resistor"*

This is the most revealing comment in the codebase. You have electronics knowledge — or at least electronics *intuition*. You're describing `keyReleased()` resetting `currentKeyCode = -1` as a pull-down resistor: a passive hardware component that returns a line to a known LOW state when no signal is active. That's not a software pattern you learned from a textbook. It's a *cross-domain translation* from physical circuits to event-driven code. This is a form of intelligence that formal CS education rarely produces.

---

> *"OHH SNAAAP ---> " + snapID + ".tif"*

Personality in a debug line. You're not just writing code — you're writing code that you enjoy *using*. The console is part of the experience.

---

> *"(else new dir for every frame ;)"*

The winking aside to your future self. You know why the `sequenceStartTime` is set once at toggle-start (not per-frame), and you're leaving a breadcrumb. This is how experienced practitioners actually write code when they're comfortable — informally, specifically, for an audience of one (themselves, later).

---

> *"Took hours to figure out how to remove the niko-test movie file. In the end I backed up snapcap, deleted it, recloned it, then moved the processing scripts back."*

This commit message is the most honest thing in the repo. You committed a large binary (likely a test video — "niko"), couldn't get `git filter-branch` or `BFG` to work, and ultimately solved the problem by brute force: destroy and rebuild. You documented this *struggle*, not just the outcome. That's rare and admirable. Most developers silently squash their failures. You logged yours. The repo is a **record of learning**, not a curated highlight reel.

---

> *"Symlink SNAP_PATH and FRAME_PATH from within this sketch to centralized Dropbox storage"*

You thought about where output actually lives and solved the local-vs-cloud storage problem via symlinks rather than by hard-coding an absolute path. That's an elegant infrastructure solution for a solo creative practice.

---

> *"A note about IMAGE FORMAT: .TGA is the fastest image type when using saveFrame()"*

You researched the performance tradeoffs. You didn't just use the default (.png or .jpg) — you found the right tool for high-frequency frame capture. This is the behavior of someone who **uses their tools intensely enough to care about the difference**.

---

## What You Did Well

### 1. You Built a Real Tool for a Real Problem
This isn't a tutorial exercise. It's something you actually use. That purpose-built quality shows in the timestamp naming logic, the cursor-hide-on-capture detail, the symlink setup instructions, and the console output personality. Real use produces good design decisions.

### 2. Boolean Naming
```java
boolean recordIsOn = false;
boolean cursorIsOn = true;
```
These read as natural-language questions: "Is record on? Is cursor on?" Many developers write `isRecording`, `showCursor`, `rec`, or `flag1`. You picked the right idiom without being told.

### 3. The Cursor-Hide Pattern
Hiding the cursor before capture, then restoring it, is a UX detail that most beginners never think of. You discovered the problem by *using* the tool and fixed it. That's the right feedback loop.

### 4. The Pull-Down Resistor Pattern
```java
void keyReleased() {
  currentKeyCode = -1;
}
```
Using `-1` as a sentinel for "no key pressed" and resetting on release is a clean debounce. Using a hardware metaphor to explain it is better than any comment a professional would write.

### 5. File Separation as Conceptual Organization
Splitting into `Snapcap.pde`, `keyEVENTS.pde`, `ImageLayer.pde`, and `notes.pde` shows you're thinking in responsibilities, not just in code. Processing doesn't require this — you imposed structure on a flat system because it made sense to you.

### 6. `.gitignore` Shows Production Thinking
Excluding `*.tif`, `*.tga`, `.DS_Store`, OS build artifacts — you know what belongs in version control and what doesn't. This is non-obvious to many beginners.

### 7. Method Overloading
```java
String snapScreen() {
  return snapScreen(null);
}
String snapScreen(String snapID) { ... }
```
You used method overloading correctly to provide a zero-argument convenience wrapper. This is idiomatic Java/Processing.

### 8. Visual Alignment and Intentional Formatting
```java
boolean  recordIsOn =         false;
boolean  cursorIsOn =         true;
String   sequenceStartTime =  "";
```
You treat code as visual layout. The alignment of type names, variable names, and values is done by hand. This makes declarations scannable in a way that most auto-formatted code is not.

---

## What Was Amateur

### 1. The Dead Reference Bug (Crash on TAB)
`Snapcap.pde:158-159`:
```java
clearPGraphic(templatelayer.offScreenBuffer);  // BUG
clearPGraphic(templatelayer.displayLayer);     // BUG
```
`templatelayer` doesn't exist. The variable is `imagelayer`. Press TAB and this crashes at runtime. This is a remnant of a rename that was half-completed — the exact failure mode that tests exist to catch.

### 2. Globals Coupling Independent Files
```java
// snapcap_util.pde
char    currentKey;
int     currentKeyCode = -1;
boolean DEBUG = true;
```
`keyEVENTS.pde` writes to `currentKey` and `currentKeyCode`. `Snapcap.pde` reads them. Neither file declares them. They exist in the shared global namespace. This is invisible coupling — two files that appear independent but are tightly bound through shared mutable state.

### 3. Timestamp Logic Copied Three Times
`getSnapTime()`, `getFrameTime()`, `getSequenceStartTime()` all build timestamps with nearly identical `nf()` chains. If you ever change the date format, you change it in three places — one of which you'll forget.

### 4. `snap_clean_all()` Is a Copy-Paste of the Other Two
`snapcap.sh:53-74` is `snap_clean_frames()` + `snap_clean_snaps()` pasted together. The correct implementation is:
```bash
snap_clean_all() {
  snap_clean_frames
  snap_clean_snaps
}
```

### 5. The `rm -rf` Without Guardrails
```bash
rm -rf ${JAYCI_WORKSPACE}/snapcap/snapcap_util/frames/* || true
```
If `JAYCI_WORKSPACE` is unset, this becomes `rm -rf /snapcap/...`. Needs a guard:
```bash
: "${JAYCI_WORKSPACE:?Error: JAYCI_WORKSPACE is not set}"
```

### 6. Misleading Side Effect in `toggleCursor()`
```java
noCursor();
println("*** Cursor HIDDEN for screenshot ***");
println("\t---> Screenshot SNAPPED!! <---");  // LIE
```
When you press `'c'` to toggle the cursor, this prints "Screenshot SNAPPED!!" — but no screenshot was taken. The print statement is only correct when `toggleCursor()` is called from within `snapScreen()`.

### 7. The Redundant Guard
```java
if ((currentKeyCode == -1) || !(currentKey == 'w')) {
  return;
}
if (currentKey == 'w') {  // This is always true here
  println("...");
}
```
After the early return, `currentKey == 'w'` is guaranteed. The second check is dead logic.

### 8. `ready()` Is a Misleading Name
Both `Snapcap.ready()` and `ImageLayer.ready()` don't check readiness — they execute per-frame work. `update()`, `tick()`, or `process()` describes what actually happens.

### 9. `snap_create_project()` Is Abandoned Mid-Build
```bash
snap_create_project () {
    read PROJECT
    echo "Creating directory: ..../jaycody/${PROJECT}/"
    #exit     # <-- abandoned mid-implementation
}
```
Prompts and collects input, then does nothing.

### 10. `notes.pde` Shouldn't Be a `.pde` File
It's 124 lines of block comments with zero executable code. Its content is documentation — it belongs in `docs/` or the README, not compiled with the sketch.

---

## Alternative Paths to the Same Goal

### Path A: External Screen Recording (OBS, QuickTime)
Lowest effort. But you lose: frame-perfect capture, per-frame filenames, transparency (can't capture alpha from the window), and integration with sketch events. For a visual artist who cares about artifact quality, this matters. The right call was to build your own.

### Path B: Existing Processing Library
[gifAnimation](https://github.com/extrapixel/gif-animation) or the built-in `saveFrame()` with ffmpeg post-processing could handle recording. You'd lose the naming scheme, session organization, and cursor-hide behavior. Building your own was right for your specific needs.

### Path C: Processing Library (packaged, not a utility sketch)
Instead of a `.pde` utility you copy into projects, package this as a Processing library (`snapcap.jar`). Add it via the Contribution Manager, call `import snapcap.*;`, use it in any sketch without copying files. The downside: library packaging is considerably more complex. Overkill for a solo practice tool.

### Path D: Evolve What You Have — Close the Globals
The correct next evolution: move `currentKey`, `currentKeyCode`, and `DEBUG` into the `Snapcap` class (or a dedicated `InputState` struct). Pass them explicitly. Retain the same file structure and `.pde` approach. This is the minimal improvement with the maximum architectural benefit.

---

## Skill Assessment

| Dimension | Level | Evidence |
|---|---|---|
| Processing framework fluency | **Strong** | PGraphics, P2D, `nf()`, `saveFrame()`, event handlers, `beginDraw/endDraw` |
| Creative tool design | **Strong** | Naming scheme, cursor UX, session directories — all from real use |
| OOP fundamentals | **Solid** | Classes, constructors, method encapsulation, overloading |
| Cross-domain thinking | **Distinctive** | Hardware metaphors applied to software patterns |
| DRY principle | **Not yet internalized** | Three timestamp duplications, bash copy-paste |
| Defensive coding | **Early stage** | No null checks, no error handling, dangerous `rm -rf` |
| Global state management | **Problematic** | Globals coupling files that should be independent |
| Git fluency | **Learning** | Large binary committed, resolved by brute force; commit messages are honest and descriptive |
| Testing | **Absent** | CI runs `echo Hello, world!`; zero validation |
| Documentation | **Split personality** | `notes.pde` is excellent; README is two lines |

**Overall:** Intermediate creative technologist. Strong intuitions, real domain expertise in the creative/visual space, gaps in the engineering habits that prevent code from breaking as it grows.

---

## Next Steps, In Order of Impact

1. **Fix the TAB crash** — `templatelayer` → `imagelayer` in `Snapcap.pde:158-159`. One line. Prevents runtime crash.

2. **Extract `getTimestamp()`** — Consolidate the three `nf()` timestamp chains into one method. First DRY exercise in this codebase.

3. **Fix `snap_clean_all()`** — Call `snap_clean_frames` and `snap_clean_snaps` instead of copy-pasting their bodies.

4. **Guard the `rm -rf`** — Add `": ${JAYCI_WORKSPACE:?Error: not set}"` before the delete. Prevents potential data loss.

5. **Fix the misleading `println` in `toggleCursor()`** — Remove "Screenshot SNAPPED!!" from the toggle function. It belongs only in `snapScreen()`.

6. **Move `notes.pde` to docs** — Convert to `docs/notes.md`. Keep all content. It's valuable — just not as source code.

7. **Kill the globals** — Move `currentKey`, `currentKeyCode`, `DEBUG` into `Snapcap`. Pass state explicitly. This is the architectural inflection point.

8. **Rename `ready()`** — To `update()` or `process()`. Costs nothing. Prevents future confusion.

---

## Bottom Line

You write code like an artist who took their tools seriously. The distinctive voice — `OHH SNAAAP`, `functions like a pull-down resistor`, a commit message that honestly documents a multi-hour git disaster — is not amateur. It's *authentic*, and it makes this codebase more readable, not less.

The weaknesses are the predictable gaps of self-directed learning: globals, duplication, no tests, no error handling. These aren't failures of intelligence — they're just things nobody taught you, and that didn't bite you badly enough yet to force a fix.

The strength that's harder to teach: you built something real, for yourself, in service of a creative practice, and you kept refining it when it bothered you. The commit arc from `Repurpose utiliplate` → `Refactor everything` → `Simplified GLOBALS` → surgical naming commits tells the story of a developer growing into engineering discipline. You're on the right trajectory.
