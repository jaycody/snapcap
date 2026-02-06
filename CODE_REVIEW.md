# Comprehensive Code Review: snapcap

> Review performed February 2026 against commit `1300ef9` on branch `claude/code-review-assessment-hmx7x`

---

## 1. Your Style

Your code has a **distinctive authorial voice** that is immediately recognizable. A few defining characteristics:

**Visual-structural formatting.** You use extensive ASCII separator lines (`//////////`, `/*****/`, `///***///|||`) to create visual "regions" in your files. This isn't a common software engineering convention -- it's the instinct of someone who thinks visually. You treat source code like a layout, not just logic. The separators create blocks that scan almost like storyboard panels.

**Narrative commenting.** Your comments don't read like dry documentation -- they read like a lab notebook or internal monologue. Examples:

- `println("\n\tOHH SNAAAP ---> " + snapID + ".tif\n");` -- personality in output strings
- `// functions like a pull-down resistor` -- hardware metaphor for a software pattern
- `// (else new dir for every frame ;)` -- the winking aside to your future self
- The entire `notes.pde` is essentially a working journal embedded in the codebase

**Intentional alignment.** You visually align variable declarations:
```java
boolean  recordIsOn =         false;
boolean  cursorIsOn =         true;
String   sequenceStartTime =  "";
```
This is manual column alignment -- you care about how code *looks* on the screen.

**File-as-responsibility separation.** Splitting `keyEVENTS.pde`, `Snapcap.pde`, `ImageLayer.pde`, and `notes.pde` into separate files shows you're thinking about conceptual separation, even within Processing's flat-file model.

**Commit messages as diary.** Your git history reads like a logbook:
> `5ef8c3b` - "Took hours to figure out how to remove the niko-test movie file. In the end I backed up snapcap, deleted it, recloned it, then moved the processing scripts back."

You document *struggle*, not just outcome. That's the signature of someone who treats the repo as a record of learning.

---

## 2. Skill Assessment

**Level: Intermediate practitioner, self-directed learner, creative-technologist orientation.**

You are not a professional software engineer by training -- and that's not a deficit. Your code reveals someone who builds tools *in service of a creative practice* (visual art, animation, video alchemy). You've internalized the Processing framework deeply and you understand event-driven programming, OOP basics, file I/O, and path construction. You know enough to build real, functional utilities that solve actual problems in your workflow.

Where you sit on specific axes:

| Dimension | Level | Evidence |
|---|---|---|
| Processing/framework fluency | **Strong** | PGraphics layers, P2D renderer, `nf()` for zero-padding, `saveFrame()` usage |
| OOP fundamentals | **Solid** | Classes with state and methods, constructor initialization, encapsulation |
| Naming discipline | **Improving** | `recordIsOn`, `cursorIsOn` are good; `ready()` is vague; commit history shows growing attention to naming |
| Architecture | **Emerging** | File separation is good instinct; but globals and cross-file coupling undermine it |
| Defensive coding | **Early** | No error handling, no null checks, no edge case consideration |
| DRY principle | **Not yet internalized** | Timestamp logic repeated 3 times; bash clean functions copy-pasted |
| Git fluency | **Learning** | Commit `5ef8c3b` shows struggling with basic git operations; but you kept at it |
| DevOps/CI | **Exploratory** | CI pipeline exists but does nothing; issue templates are GitHub defaults |

---

## 3. Expert Patterns (Things You're Doing Well)

### a. Boolean naming with semantic prefixes
`Snapcap.pde:2-3`
```java
boolean recordIsOn = false;
boolean cursorIsOn = true;
```
These read as natural-language predicates. Many experienced developers don't name booleans this clearly.

### b. Timestamp-based file organization
`Snapcap.pde:66-95`

Your snap/frame naming scheme (`VERSION/yyyymmdd-hhmm/yyyymmdd-hhmmss-######.tif`) is genuinely well-designed. It prevents overwrites, organizes by session, and is human-readable in a file browser. This is the kind of thing that comes from *using your own tool* and feeling the pain of bad naming.

### c. The "pull-down resistor" pattern
`keyEVENTS.pde:14-17`
```java
void keyReleased() {
  currentKeyCode = -1;
}
```
Using `keyReleased` to clear state is a clean debounce pattern. The hardware metaphor in the comment shows you're mapping concepts across domains -- that's creative engineering thinking.

### d. Cursor-hide-during-capture
`Snapcap.pde:49-55`

Hiding the cursor before a screenshot and restoring it after is a thoughtful UX detail that most beginners wouldn't think of. You encountered this problem in practice and solved it.

### e. Separation of snap vs. frame-sequence concerns
The mental model of "a snap is a single capture; a frame sequence is a recording session with a start-time directory" is clearly designed. The directory structure reflects the conceptual model.

### f. Well-configured `.gitignore`
Excluding `*.tif`, platform builds, and `.DS_Store` shows you've thought about what belongs in version control.

---

## 4. Novice Patterns (Things That Reveal Inexperience)

### a. Global mutable state
`snapcap_util.pde:21-23`
```java
char     currentKey;
int      currentKeyCode = -1;
boolean  DEBUG = true;
```
These globals are read and written from multiple files (`keyEVENTS.pde` writes them, `Snapcap.pde` reads them). This creates invisible coupling between files. If the codebase grew even slightly, this would become a source of bugs that are extremely hard to trace.

### b. Magic numbers
`keyEVENTS.pde:36`, `Snapcap.pde:154`
```java
if ((currentKeyCode==TAB) || (currentKeyCode==32)){  // 32 = spacebar
```
```java
if (key_pressed == 32) {  // again, spacebar
```
You use Processing's named constant `TAB` in one place but the raw integer `32` for spacebar. Processing doesn't define a `SPACE` constant, but you could define your own: `final int SPACE = 32;`

### c. Dead/broken reference (BUG)
`Snapcap.pde:158-159`
```java
clearPGraphic(templatelayer.offScreenBuffer);
clearPGraphic(templatelayer.displayLayer);
```
`templatelayer` does not exist anywhere in this codebase. The actual variable is `imagelayer` (declared in `snapcap_util.pde:27`). This code will crash at runtime if you press TAB. This is a **bug** -- likely a remnant from a rename that wasn't completed.

### d. Copy-paste duplication -- timestamp formatting
`Snapcap.pde:72-95`

`getSnapTime()`, `getFrameTime()`, and `getSequenceStartTime()` all build timestamps with nearly identical `nf()` chains. If you ever change the date format, you'd need to change it in three places. A single `getTimestamp()` helper would eliminate this.

### e. Copy-paste duplication -- bash clean functions
`snapcap.sh:53-74`

`snap_clean_all()` is a literal copy-paste of `snap_clean_frames()` + `snap_clean_snaps()` instead of:
```bash
snap_clean_all() {
  snap_clean_frames
  snap_clean_snaps
}
```

### f. Misleading side effects in `toggleCursor()`
`Snapcap.pde:128-131`
```java
noCursor();
println("*** Cursor HIDDEN for screenshot ***");
println("\t---> Screenshot SNAPPED!! <---");
```
This prints "Screenshot SNAPPED!!" when the cursor is hidden -- but hiding the cursor isn't the same as taking a screenshot. When `toggleCursor()` is called from the `'c'` key handler, the user sees "Screenshot SNAPPED!!" even though no screenshot was taken.

### g. The `ready()` method name
`Snapcap.pde:16`, `ImageLayer.pde:11`

Both classes have a `ready()` method, but they don't check readiness -- they *execute per-frame logic*. A name like `update()`, `process()`, or `drawFrame()` would convey what the method actually does.

### h. Redundant guard in `checkForRepeatingKey()`
`Snapcap.pde:212-219`
```java
if ((currentKeyCode == -1) || !(currentKey == 'w')) {
  return;
}
if (currentKey == 'w') {  // <-- this is always true here
```
After the early return, `currentKey` is *guaranteed* to be `'w'`. The second `if` is dead logic.

### i. Unfinished stub functions
`snapcap.sh:7-17`

`snap_create_project()` reads input but never creates a directory. The `#exit` comment suggests it was abandoned mid-implementation.

### j. No tests
Zero. The CI pipeline runs `echo Hello, world!`. There's no validation that any of this code works beyond manual testing.

---

## 5. Weaknesses to Address

### Structural
- **No error handling anywhere.** What happens if the snaps directory doesn't exist? If disk is full? If path is invalid? Currently: unhandled exceptions.
- **No input validation.** The bash scripts use `rm -rf` on paths constructed from environment variables (`${JAYCI_WORKSPACE}`). If that variable is unset, `rm -rf` runs on a partial path. This is genuinely dangerous.
- **Hardcoded environment assumptions.** `snapcap.cfg` references `${JAY_SPACE}`, `snapcap.sh` references `${JAYCI_WORKSPACE}`. These are personal environment variables that make the tools unusable by anyone else.

### Architectural
- **The `notes.pde` file.** It's a 124-line file that contains zero executable code -- it's all block comments. This should be a markdown file or a wiki page, not a `.pde` file that gets compiled (even if Processing ignores it in comments). It obscures the boundary between documentation and code.
- **Mixed responsibility in `Snapcap` class.** The `Snapcap` class handles: recording, snapshotting, cursor toggling, debug toggling, background clearing, PGraphics clearing, instruction printing, *and* key-repeat detection. That's at least 5 different responsibilities in one class.

### Process
- **No versioning strategy.** `VERSION = "ver1_0_0"` is a hardcoded string. There's no mechanism to bump it, and the SECURITY.md references versions that don't match this scheme (`0.0-alpha.0`).
- **CI does nothing.** The GitHub Actions workflow is scaffolding from 2021 that was never developed further.

---

## 6. The Narrative: What the Comments Tell Me

Reading your code and commits together, a clear story emerges:

**You are a visual artist who learned to code in order to capture your own work.**

The project name "snapcap" -- snap + capture -- and the brand "videoalchemy" tell me your primary identity is as a creator of visual/generative art, likely using Processing as your creative medium. You needed a way to record and organize the output of your sketches, and rather than use someone else's tool, you built your own. This is a *tool-maker's instinct* -- the same impulse that makes a woodworker build their own jigs.

Your `notes.pde` is a **working journal**. The detailed notes about TGA vs. JPG performance, the symlink setup instructions, the frame-naming conventions -- these aren't written for other developers. They're written for *you, six months from now*, when you've forgotten how this works. The comment style is someone thinking out loud while they build.

The commit history tells a **learning arc**:

1. **Discovery phase** (`Initial commit` through `Create act01.yml`): Setting up GitHub, trying Actions, adding issue templates, writing a security policy -- you were exploring what a "real" repo looks like.
2. **Build phase** (`Repurpose utiliplate` through `Add per-vertex fill`): Extracting this tool from a larger project ("utiliplate"), building out features, learning by doing.
3. **Refinement phase** (`Refactor everything` through `Simplified GLOBALS`): Growing dissatisfaction with mess, refactoring passes, renaming for clarity. The commit "Refactor everything" is particularly telling -- it's the moment where accumulated technical debt became intolerable and you did a big cleanup. The later, more surgical commits ("Clarify function name", "Simplified GLOBALS") show you learning to make smaller, more focused changes.

The `5ef8c3b` commit -- *"Took hours to figure out how to remove the niko-test movie file"* -- is the most human moment in the repo. You committed a large binary, couldn't undo it, and eventually resorted to backing up, deleting the repo, recloning, and manually restoring files. You documented this struggle honestly instead of hiding it. That honesty is a strength.

The TODOs scattered through the code (`green/red tint for recording state`, `bash boilerplate generator`, `Add documentation to README`) are a roadmap of aspirations that haven't been realized. The gap between intention and execution is normal -- but the number of unfinished items suggests a pattern of starting new ideas before finishing existing ones.

---

## 7. Options for Next Steps

Here are paths forward, ordered from most impactful to most ambitious:

### A. Fix the Bug
The `templatelayer` reference in `Snapcap.pde:158-159` is broken. This should be `imagelayer`. This is a one-line fix that prevents a runtime crash.

### B. Eliminate Duplication
Extract a shared `getTimestamp(int precision)` method to replace the three copy-pasted `nf()` chains. Refactor `snap_clean_all()` to call the other two functions. This builds the DRY habit.

### C. Kill the Globals
Move `currentKey` and `currentKeyCode` into the `Snapcap` class (or a dedicated `InputState` class). Pass them explicitly instead of sharing through global scope. This is the single highest-leverage architectural improvement.

### D. Add Safety to Bash Scripts
Add checks for unset environment variables before `rm -rf`:
```bash
: "${JAYCI_WORKSPACE:?Error: JAYCI_WORKSPACE not set}"
```
This prevents a dangerous partial-path deletion.

### E. Move `notes.pde` to Documentation
Convert the content to a proper `docs/` markdown file or the README. Remove the 124-line comment file from the compiled codebase.

### F. Make CI Real
Either remove the GitHub Actions workflow or make it do something -- even just syntax checking the `.pde` files or linting the bash scripts.

### G. Refactor `Snapcap` Class Responsibilities
Split recording, screenshot, cursor management, and debug into separate concerns. This is the most ambitious refactor but would make the code meaningfully more maintainable.

### H. Add a Testing Strategy
Processing doesn't have a built-in test framework, but you could write integration tests that verify file output, directory creation, and naming conventions using a bash test script.

---

## Bottom Line

You write code like an artist who respects their tools -- with personality, visual intention, and honest documentation of the process. The weaknesses are the predictable ones of a self-taught coder (globals, duplication, missing error handling, no tests). The strengths are less common: genuine separation of concerns instinct, excellent naming for booleans, a file organization scheme that clearly comes from real-world use, and the discipline to refactor when things get messy. The path forward is less about learning new features and more about deepening the engineering habits you've already started developing.
