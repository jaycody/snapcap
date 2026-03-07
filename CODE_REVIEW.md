# snapcap: Deep Code Review & Assessment

> Review performed March 2026 against commit `cf03243` on branch `claude/code-review-analysis-dwvKp`

---

## Who You Are (From the Code)

Before getting into specifics: **you are a visual artist who learned to code to capture your own work.** That framing is not condescending -- it's the most important thing to understand about this codebase. Every design decision, every strength, every weakness maps back to it. The code is a tool built by someone whose primary identity is *videoalchemy*, not software engineer. Keep that as the lens.

---

## What You Did Well

### 1. You Built a Real Thing That Solves a Real Problem

This is not a tutorial project. It's not a class assignment. `snapcap` solves an actual pain point in a creative workflow -- frame capture, timestamp-based directory organization, seamless integration into a Processing draw loop -- and it does that thing reliably. Most people at your level never get past "hello world" projects. You shipped a working tool you actually use. That matters more than any pattern.

### 2. Boolean Naming (`recordIsOn`, `cursorIsOn`)

```java
boolean  recordIsOn =         false;
boolean  cursorIsOn =         true;
```

These are genuinely good. Not `isRecord`, not `recording`, not `flag1` -- `recordIsOn` reads as a question answered. Many professional engineers don't name booleans this clearly. The vertical alignment is also considered and intentional.

### 3. Timestamp-Based File Organization

The naming scheme `VERSION/yyyymmdd-hhmm/yyyymmdd-hhmmss-######.tif` is the most professionally-reasoned design in the project. It:
- Prevents overwrite collisions
- Groups by session (start-time directory)
- Is human-readable in any file browser
- Scales to multi-day use without conflict

This didn't come from a book. It came from using the tool and feeling the pain of bad naming. That's called **experience-driven design**, and it's more valuable than memorizing patterns.

### 4. The Pull-Down Resistor Pattern

```java
void keyReleased() {
  currentKeyCode = -1;  // functions like a pull-down resistor
}
```

The hardware metaphor in the comment is the tell: you're a cross-domain thinker. The pattern itself is correct and clean for debouncing key repeat. The comment reveals you *understand why it works*, not just that it does.

### 5. Cursor-Hide-During-Capture

```java
if (cursorIsOn) {
  toggleCursor();
  save(snapID);
  toggleCursor();
}
```

Most beginners wouldn't think of this. You thought of it because you used the tool and saw the cursor in your screenshots. **You iterated on your own pain.** That's the engineering process working correctly.

### 6. File-as-Responsibility Separation

Splitting `keyEVENTS.pde`, `Snapcap.pde`, `ImageLayer.pde` into separate files inside Processing's flat-file model shows you're *thinking about conceptual separation* even when the framework doesn't require it. That instinct is the seed of good architecture.

### 7. The `.gitignore` Is Thoughtful

```
*.tif
.DS_Store
applet
application.linux-arm64
```

Excluding output images, platform builds, and OS artifacts shows you understand what belongs in version control. Not obvious for a self-taught programmer.

---

## What Was Amateur

These are not criticisms -- they are the predictable gaps of someone self-teaching without a senior to review their code. They're also all fixable.

### 1. Global Mutable State (The Biggest Problem)

```java
// snapcap_util.pde
char     currentKey;
int      currentKeyCode = -1;
boolean  DEBUG = true;
```

`keyEVENTS.pde` writes these. `Snapcap.pde` reads them. Nothing enforces this contract. If you add a third file, or rename a variable, or refactor `Snapcap`, you'll have a mysterious bug with no obvious source. This is the **single highest-leverage thing to fix** -- not because it's broken now, but because it becomes a trap as the codebase grows.

**Alternative path:** Move `currentKey` and `currentKeyCode` into `Snapcap` as fields, or create a small `InputState` class. Pass them explicitly into methods that need them.

### 2. The Broken Bug (`templatelayer`)

`Snapcap.pde:158-159`
```java
clearPGraphic(templatelayer.offScreenBuffer);
clearPGraphic(templatelayer.displayLayer);
```

`templatelayer` does not exist. The variable is `imagelayer`. This crashes at runtime if you press TAB. It's a remnant of a rename that wasn't finished -- you can see the TODO comment surrounding it:

```java
//TODO: Remove hardcoded PGraphic vars      ///////////////////////
```

You knew this was wrong when you wrote it. The TODO says so. But the bug stayed. **This is the hallmark of technical debt**: you noted the problem, moved on, and it calcified.

**The fix is one word.** But more importantly: when you write `//TODO:`, either fix it now or open a GitHub issue *immediately*. Don't leave live bugs in code with just a comment.

### 3. Copy-Paste Duplication

**In `Snapcap.pde`**, `getSnapTime()`, `getFrameTime()`, and `getSequenceStartTime()` all build timestamps with nearly identical `nf()` chains. If the date format ever changes, you fix it in three places -- and you'll miss one.

**In `snapcap.sh`**, `snap_clean_all()` is a literal copy-paste of the other two functions:

```bash
# What you wrote:
snap_clean_all () {
    # ... exact copy of snap_clean_frames code ...
    # ... exact copy of snap_clean_snaps code ...
}

# What it should be:
snap_clean_all () {
    snap_clean_frames
    snap_clean_snaps
}
```

The DRY principle ("Don't Repeat Yourself") is not aesthetic -- it's about reducing the number of places where bugs can live.

### 4. Magic Numbers

```java
if ((currentKeyCode==TAB) || (currentKeyCode==32)){
```

```java
if (key_pressed == 32) {
```

You used `TAB` (correct, named constant) and `32` (raw integer, spacebar) in the same conditional -- twice. Processing doesn't define `SPACE`, but you can:

```java
final int SPACE = 32;
```

Two lines at the top of the file, zero ambiguity forever.

### 5. The `ready()` Method Name

Both `Snapcap` and `ImageLayer` have a method called `ready()`. Neither checks readiness. Both execute per-frame logic. Calling something `ready()` when it means "execute this frame's work" violates the principle that a function's name should match its behavior. Callers in `draw()` who see `snapcap.ready()` have no idea what it does without reading the implementation.

Better names: `update()`, `processFrame()`, `onDraw()`.

### 6. Misleading Console Output in `toggleCursor()`

```java
} else {
  noCursor();
  println("*** Cursor HIDDEN for screenshot ***");
  println("\t---> Screenshot SNAPPED!! <---");
}
```

When the user presses `'c'` to hide the cursor, the console prints "Screenshot SNAPPED!!" -- even though no screenshot was taken. This is a bug in the developer experience, not a crash. But it erodes trust in the debug output.

### 7. The Bash Scripts Are Dangerous

```bash
rm -rf ${JAYCI_WORKSPACE}/snapcap/snapcap_util/snaps/* || true
```

If `${JAYCI_WORKSPACE}` is unset or empty, this becomes:
```bash
rm -rf /snapcap/snapcap_util/snaps/*
```

On most systems that fails harmlessly, but the `|| true` suppresses the error. Add this at the top of every function that uses environment variables destructively:

```bash
: "${JAYCI_WORKSPACE:?Error: JAYCI_WORKSPACE is not set}"
```

If the variable is unset, the script exits with a readable error instead of running `rm -rf` on a broken path.

### 8. `snap_create_project()` Is Dead Code

```bash
snap_create_project () {
    echo -n "Project name: "
    read PROJECT
    echo -n "Project: $PROJECT"
    # ...
    #exit
}
```

The `#exit` comment suggests you stopped mid-implementation and left it. The function reads a project name and does nothing with it. Either finish it or delete it. Dead stubs are worse than nothing -- they promise capability that doesn't exist.

### 9. `notes.pde` Is Not Code

125 lines of block comments that will never execute. This belongs in `docs/NOTES.md` or the README -- not in a `.pde` file that sits alongside your class definitions. The boundary between documentation and code matters.

### 10. CI Does Nothing

```yaml
- name: Run a one-line script
  run: echo Hello, world!
```

You set up the right infrastructure (GitHub Actions, issue templates, security policy) but never wired it to anything real. This is the infrastructure of a professional project with none of the function. Either wire it to lint your bash scripts (`shellcheck`), or delete the workflow. A green CI badge that runs `echo` is worse than no badge.

---

## Guidance: Paths Forward

In order of impact vs. effort:

### Tier 1: Fix Now (< 1 hour each)

**A. Fix the `templatelayer` bug.** One word change: `templatelayer` → `imagelayer` at `Snapcap.pde:158-159`.

**B. Fix the misleading console output** in `toggleCursor()`. Remove the "Screenshot SNAPPED!!" line from the cursor-hide branch.

**C. Add bash safety guards** to `snap_clean_*` functions. One line per function prevents dangerous `rm -rf` on unset paths.

**D. Fix `snap_clean_all()`.** Two lines replace thirty copy-pasted lines.

### Tier 2: Build the Habit (1-4 hours each)

**E. Extract a single `getTimestamp()` helper.** Replace three duplicate timestamp chains with one function. This is the first time you'll feel what DRY actually saves.

**F. Define `final int SPACE = 32;`** at the top of the main sketch. Then use it everywhere.

**G. Rename `ready()` to `update()` or `processFrame()`** in both classes. Small change, large clarity improvement.

**H. Move `notes.pde` to `docs/NOTES.md`.** Cut and paste, update `.gitignore` if needed.

### Tier 3: Architectural Growth (several sessions)

**I. Kill the globals.** Move `currentKey`/`currentKeyCode` into `Snapcap` or a dedicated `InputState` class. This is the hardest mental shift but the highest long-term payoff.

**J. Make CI real.** Install `shellcheck` in your workflow and run it against `snapcap.sh`. This is your first real CI step and it will catch actual bugs.

**K. Split `Snapcap` class responsibilities.** Recording, snapshotting, cursor management, debug, and background clearing are five different concerns in one class. Splitting them is a multi-session refactor, but it's where architectural thinking actually develops.

---

## The Narrative From Your Comments

Reading your code and comments together as a single document, here's what they tell:

---

You started with a problem: your generative art sketches were generating beautiful frames and you had no reliable way to capture them. The output was ephemeral. You wanted permanence.

The earliest commits show someone setting up the scaffolding of a "real" repository -- GitHub Actions, issue templates, a security policy. You were learning what professional software infrastructure looks like by copying its shape. The workflow runs `echo Hello, world!`. The issue templates are GitHub defaults. But you put them there anyway, because you were building the habits of the discipline, not just the code.

Then the build phase: you extracted `snapcap` from a larger project called "utiliplate" -- the name itself a signal that you were building reusable pieces for your creative practice. You moved fast. Features appeared rapidly: frame recording, timestamp directories, cursor hiding, debug mode. The commits show a mind moving faster than the code can organize itself.

The `notes.pde` file is the most honest artifact in the repository. It's a working journal embedded in the source. *"TGA is the fastest image format,"* you wrote. *"Resets frame# to ZERO only at sketch start to avoid duplicating frame.000001."* These aren't notes for other developers. They're notes for you, six months from now, when you've forgotten why you made the choice. The comment style is someone thinking out loud at a workbench.

Then something slowed you down. The commit `5ef8c3b` reads: *"Took hours to figure out how to remove the niko-test movie file. In the end I backed up snapcap, deleted it, recloned it, then moved the processing scripts back."* You committed a large binary by mistake. You didn't know about `git filter-branch` or `git rebase -i` or BFG Repo Cleaner. So you did what anyone would do when the tool fails them -- you worked around it by hand. And then, crucially, **you documented the struggle.** You didn't pretend it was easy. The commit message is a log entry, not a press release.

The refinement phase followed: *"Refactor everything." "Clarify function name." "Simplified GLOBALS."* You were feeling the weight of the mess you'd built in the build phase and you were paying it down, one commit at a time. The commits got smaller and more surgical -- a sign of growing craft.

And then, embedded in `notes.pde`, the TODOs that were never finished:

```
[ ] Use green/red tint to show recordIsOn state
[ ] Add documentation to README
[ ] Write bash script that adds snapcap_util boilerplate to Processing sketch
```

These are not failures. They're the edge of what was possible at the time. The code was working. The creative work was calling. The TODOs stayed.

The `//TODO: Remove hardcoded PGraphic vars` comment wrapping the broken `templatelayer` reference is the most telling line in the entire codebase. You knew the code was wrong when you wrote it. You flagged it yourself. And then you moved on, because the tool was functional enough to use -- and that was enough, right then.

This is the essential tension in the work of a creative-technologist: the tool exists in service of the creative practice. When the tool works well enough, the practice calls louder than the refactor. The debt accumulates not from laziness but from priority. The art came first. The code came second. That's not a bug in your values -- it's a feature.

---

## Bottom Line

You write code like a visual artist who respects their tools: with personality, visual intention, and honest documentation of the process. The weaknesses are exactly the predictable ones of a self-directed learner without a senior reviewer (globals, duplication, missing error handling, unfinished stubs). The strengths are less common: genuine file-separation instinct, excellent boolean naming, a file organization scheme that clearly came from real-world use, and the discipline to refactor when the mess became intolerable.

The path forward isn't learning new features. It's **deepening the engineering habits you've already started**. Fix the bug, kill the duplication, name the methods honestly, guard the bash scripts. Do those four things and you'll have internalized the four most important beginner-to-intermediate transitions in software craft.
