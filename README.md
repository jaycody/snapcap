# snapcap
Frame recording utility.

A tool for recording, labeling, and organizing animation frames from Processing sketches.

## How it works

![How Snapcap works: setup, every frame, and key presses](docs/diagrams/how-it-works.png)

<sub>Source: [docs/diagrams/how-it-works.mmd](docs/diagrams/how-it-works.mmd). After editing it, run `bash docs/diagrams/render.sh`.</sub>

Snapcap runs on its own once it's created: Processing calls it after every `draw()` and on every key press. Frames are film, one folder per take, ready to turn into video. Snaps are stills, one flat folder per version. Both are labeled with the git version that made them.

## Help

```bash
snapcap --help        # with jayci; also snap_help
./snapcap.sh --help   # without jayci (or just ./snapcap.sh)
```

Lists the shell commands, the keys inside a sketch, and the settings, with the
current snapcap release at the top.

## Start a new project

`snap_new_project` is a build script that stamps out a ready-to-run Processing sketch with Snapcap already wired in. Think of it as a cookie cutter: `template/` is the cutter, and every project it makes comes out the same shape, with its own name and version pressed in.

```bash
snap_new_project myArt
```

**That's the whole command.** It asks where to put the project and where the big image files should go, then builds `myArt`: a sketch that's ready to run, with recording built in. Every new project starts at version `v0.0.1`.

Two variations:

```bash
snap_new_project myArt ~/sketches       # put it in a folder you choose
./snapcap.sh snap_new_project myArt     # from the snapcap folder, before step 5 below
```

### First time? Two ways to get set up

You'll need a **Mac** (the script is built and tested on macOS), **[Processing 4](https://processing.org/download)** in your Applications folder, and a little comfort pasting lines into Terminal.

- **Option A:** follow the steps yourself. About 15 minutes.
- **Option B:** give this repo to an AI assistant. It checks the code, sets everything up, and walks you through it by asking you questions.

#### Option A: step by step

Each gray box is something to paste into **Terminal** (press Cmd-Space, type `Terminal`, press Return). Paste one box at a time and press Return after each.

1. **Check that git is installed.** git keeps track of your sketch's versions, and Snapcap uses it to label every image.

   ```bash
   git --version
   ```

   If a window offers to install the "command line developer tools", click **Install**, wait for it to finish, and run the line again. You should see `git version ...`.

2. **Tell git who you are.** This only stays on your computer unless you share a project. Skip this step if `git config user.name` already prints your name.

   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "you@example.com"
   ```

3. **Download snapcap** into your home folder:

   ```bash
   cd ~
   git clone https://github.com/jaycody/snapcap.git
   ```

4. **Make the command available in every Terminal window.** This adds one line to `~/.zshrc`, the file Terminal reads when it opens:

   ```bash
   echo 'source ~/snapcap/snapcap.sh' >> ~/.zshrc
   source ~/.zshrc
   snap_help
   ```

   `snap_help` should print a list of commands. (If `echo $SHELL` says `bash`, use `~/.bash_profile` instead of `~/.zshrc`.)

5. **Make your first project** in Processing's sketch folder:

   ```bash
   cd ~/Documents/Processing
   snap_new_project myArt
   ```

   Use letters, numbers and `_` for the name, with no spaces, and don't start it with a number. It asks two questions:
   - *New project will be created at ...* Press **Return**.
   - *Frames and snaps will be saved outside the project, in ~/snapcap-media/myArt-media/...* Press **Return** to accept. This keeps the big image files apart from your code. You can type an external drive instead, like `/Volumes/MyDrive/snapcap-media`, or type `n` to keep the images inside the sketch.

   When it finishes, your Terminal is inside the new `myArt` folder.

6. **Open it in Processing and press Run (▶):**

   ```bash
   open myArt/myArt.pde
   ```

   A window opens with a soft circle that follows your mouse. Click the window so it hears your keys, then:

   | Key | What it does |
   | --- | --- |
   | `r` | Start recording. Press `r` again to stop. |
   | Return | Take a single still ("snap") |
   | `d` | Hide or show the status text. It never ends up in your images. |
   | `i` | Print the key list in Processing's console |

7. **Find your images.** In Processing, choose **Sketch > Show Sketch Folder**, or from Terminal:

   ```bash
   open myArt/frames myArt/snaps
   ```

   Each recording is its own folder of numbered `.tga` images, one per frame. Snaps are `.png`. To turn a recording into a video, use Processing's **Tools > Movie Maker** and drag the recording's folder in.

8. **Make it yours.** Replace what's inside `draw()` in `myArt.pde` with your own art. Keep the `snapcap = new Snapcap("myArt");` line in `setup()`: that's what turns recording on.

9. **Mark a version** when you like where it's going:

   ```bash
   git add -A
   git commit -m "what changed"
   git tag v0.0.2
   ```

   New images are labeled `v0.0.2`, so you'll always know which version of the code made which picture. Until you commit, labels end in `-dirty`, which means "changed since the last saved version".

To get a newer snapcap later, run `cd ~/snapcap && git pull`. Projects you already made keep their own copy, so they don't change. Already have a sketch you want to record? See [Use it in a sketch](#use-it-in-a-sketch).

#### Option B: let your AI assistant set it up

This works best with an assistant that can run commands on your computer, such as Claude Code or another AI coding tool with Terminal access. A chat-only assistant can follow the same prompt: you paste each command it gives you into Terminal and paste back what it prints.

Copy this whole prompt into your assistant:

```text
I'm an artist with basic coding skills. I want to use snapcap, a frame-recording
tool for Processing sketches: https://github.com/jaycody/snapcap

Do this in order. Before each step, tell me in plain language what you're about
to do and why. Don't install or change anything without asking me first.

1. Read the repo before running anything: README.md, snapcap.sh,
   snapcap_util/Snapcap.pde, template/ and tests/. In a few sentences, tell me
   what the tool does, what it will create or change on my computer, and
   anything that worries you. In particular, check that it doesn't download
   anything, doesn't use sudo, and doesn't write outside the folders the README
   describes.

2. Check my computer: macOS version, Processing 4 in /Applications, git (and
   whether git user.name and user.email are set), my shell, and Java. Tell me
   what's missing and how to get it.

3. Clone the repo (ask me where; ~/snapcap is the default) and run its tests:
     bash tests/test_new_project.sh
     bash tests/test_storage_check.sh
   The second one needs Java; Processing's own JDK works, at
   /Applications/Processing.app/Contents/app/resources/jdk (put its bin folder
   on PATH for the test). Tell me whether they passed and what they check.

4. Ask me these one at a time, and wait for each answer:
   - Where do I keep my sketches? (Processing's default is ~/Documents/Processing)
   - Where should the big image files go: ~/snapcap-media (the default), an
     external drive, or inside each sketch?
   - Should the snap_new_project command work in every Terminal window?
     (adds one line, source ~/snapcap/snapcap.sh, to my ~/.zshrc)
   - What should my first project be called? (letters, numbers and _ only,
     not starting with a number)

5. Create my first project with:  snap_new_project <name> <sketch folder>
   Don't give it a version number: new projects start at v0.0.1. In a real
   terminal it asks where the images go. If you're running it without one, it
   skips that question and uses SNAP_STORAGE_DIR, so create my chosen storage
   folder and set SNAP_STORAGE_DIR to it for that command. If I chose "inside
   each sketch", leave it unset.

6. Open the sketch in Processing (open <project>/<name>/<name>.pde), then walk
   me through using it one step at a time, checking with me after each: press
   Run, record a few seconds with r, take a snap with Return, find the files,
   and turn a recording into a video with Processing's Tools > Movie Maker.

7. Show me how to save a new version (git commit, then git tag v0.0.2) so new
   images get the new label.

Keep your explanations short, and explain any technical word you use.
```

### How the script runs

![How snap_new_project runs](docs/diagrams/new-project.png)

<sub>Source: [docs/diagrams/new-project.mmd](docs/diagrams/new-project.mmd). After editing it, run `bash docs/diagrams/render.sh`.</sub>

Step by step:

1. **Gather.** The name and parent folder come from the arguments; anything missing is asked for. Every project starts at `v0.0.1`. For the folder, it shows the full path the project will get (for example `~/jaycode/myArt`) and asks you to press Enter, type `n` to cancel, or type a different folder. Then it shows where frames and snaps will go (see step 4) and asks you to confirm.
2. **Check.** It stops before writing anything if the name isn't a valid Processing sketch name, the parent folder doesn't exist, the project folder already exists, or the storage folder already has a `<name>-media` folder (it asks before sharing it). Nothing gets overwritten.
3. **Build.** It copies `Snapcap.pde` and fills the files in `template/`, swapping `__PROJECT__`, `__VERSION__`, `__SNAPCAP_RELEASE__` and `__DATE__` for real values. Only the files a sketch needs are copied: no `.git`, demo layers or notes.
4. **Link storage.** The project (`<parent>/<name>`, code and git) and its media are kept in two different places. Media goes in `<storage>/<name>-media/frames` and `/snaps`, where `<storage>` is `SNAP_STORAGE_DIR` if you set one, otherwise `~/snapcap-media`. The script shows the full paths: press **Enter** to use them, **n** to keep frames and snaps inside the sketch folder instead, or type a different storage folder (it can save that one to jayci's `.jayrc` so it becomes the default). The sketch's `frames` and `snaps` folders become links to the media folders, so big image files stay out of the code: open `frames/` in the sketch and you see the real images. If `SNAP_STORAGE_DIR` points at a drive that isn't mounted, no links are made, nothing is created in its place, and output stays in the sketch. Run without a terminal (scripts, tests), only a set `SNAP_STORAGE_DIR` is used; `~/snapcap-media` is never created on its own.
5. **Version.** It runs `git init`, commits, and tags that first commit with the version. Snapcap reads its version from git, so the first frame you record is already labeled `v0.0.1`. Tag again (`git tag v0.0.2`) and new output gets the new label.
6. **Move in.** Your terminal ends up in the new project folder. (Run as `./snapcap.sh snap_new_project`, it prints the `cd` instead: a script can't move your terminal.)

What you get:

```
~/sketches/myArt/
    README.md            project name, version, snapcap release, date
    .gitignore           frames and snaps stay out of git
    myArt/myArt.pde      starter sketch, already calling new Snapcap("myArt")
    myArt/Snapcap.pde    copied from snapcap_util
    myArt/snapcap.json   settings, plus the snapcap release and date it came from
```

The sketch folder takes the project's name because Processing needs the folder and the main `.pde` to match. To change what every new project starts with, edit the files in `template/`. `bash tests/test_new_project.sh` checks the whole process, and CI runs it on macOS.

## Start fresh: clean the media folders

```bash
snap_clean_frames    # empties snapcap_util/frames and frames_local
snap_clean_snaps     # empties snapcap_util/snaps and snaps_local
snap_clean_all       # both
./snapcap.sh snap_clean_all   # also works without sourcing
```

These only empty snapcap's own media folders. A folder that's a link to external
storage (like `~/Dropbox/_SNAPS`) is skipped, and projects made by `snap_new_project`
are never touched.

![How the clean commands work](docs/diagrams/clean.png)

<sub>Source: [docs/diagrams/clean.mmd](docs/diagrams/clean.mmd). After editing it, run `bash docs/diagrams/render.sh`.</sub>

## Use it in a sketch

Copy `snapcap_util/Snapcap.pde` into your sketch folder as a new tab, then add one line to `setup()`:

```java
Snapcap snapcap;

void setup() {
  size(1280, 480, P2D);
  snapcap = new Snapcap("myProject");
}

void draw() {
  // your art; no snapcap call needed
}
```

The version is read from git (`git describe --tags --always --dirty`), so output is labeled with the exact commit that made it, for example `v1.1.0-2-g47fc45b-dirty`. Outside a git repo it falls back to `nogit`. To set it by hand: `new Snapcap("myProject", "v2")`.

Snapcap hooks itself into the sketch with `registerMethod`, so it always captures after your `draw()` and reads keys without touching your `keyPressed()`.

| Key (default) | Action |
| --- | --- |
| `r` | Start/stop recording a frame sequence |
| ENTER | Snap a single frame |
| `d` | Show/hide the on-screen status (never captured) |
| `i` | Print the key list |

Output:

- Snaps: `snaps/<version>/<project>-yyyymmdd-hhmmss-<millis>-<version>.png`
- Frames: `frames/<version>/<start time>/yyyymmdd-hhmmss-#######.tga`, one folder per recording

### Settings: snapcap.json

Put a `snapcap.json` next to your `.pde` and Snapcap reads it at startup. `snap_new_project` writes one for every new project:

```json
{
  "snapcap": { "release": "v0.1-beta.0-9-gcec5a2c", "created": "2026-11-08" },
  "storage": {
    "frames": "./frames/",
    "snaps": "./snaps/",
    "framesLocal": "./frames_local/",
    "snapsLocal": "./snaps_local/"
  },
  "keys": { "enabled": true, "record": "r", "snap": "ENTER", "overlay": "d", "help": "i" },
  "format": { "frames": "tga", "snaps": "png" },
  "overlay": { "show": true }
}
```

| Field | What it does |
| --- | --- |
| `snapcap.release`, `snapcap.created` | The snapcap version and date the project was made from. A record only: Snapcap doesn't act on them. |
| `storage.frames`, `storage.snaps` | Where frames and snaps go. Relative to the sketch, or absolute, such as `/Volumes/Art/frames`. |
| `storage.framesLocal`, `storage.snapsLocal` | Where they go instead when storage can't be reached. |
| `keys.enabled` | `false` turns off all Snapcap keys. |
| `keys.record`, `keys.snap`, `keys.overlay`, `keys.help` | A single character, or `ENTER`, `SPACE` or `TAB`. |
| `format.frames`, `format.snaps` | `tif`, `tga`, `png` or `jpg`. Defaults: `tga` for frames (lossless, fastest to save, about half the size of TIFF) and `png` for snaps (lossless, smallest, opens anywhere). JPG is smallest but loses quality. |
| `overlay.show` | Whether the on-screen status starts visible. |

Every field is optional. Anything missing, misspelled or invalid keeps its default, and a sketch with no `snapcap.json` at all works exactly as before. The version is never in the file: it always comes live from git, so it can't go stale.

The sketch only reads `snapcap.json`; it never writes one. New projects get it from `snap_new_project`. For an older sketch, copy `template/snapcap.json` next to its `.pde` and remove the `snapcap` section, or keep it and fill it in by hand.

Options (call in `setup()`; they win over `snapcap.json`): `setRecordKey('R')`, `keysOff()`, `setSnapRoot(path)`, `setFrameRoot(path)`.

### When the storage drive is unplugged

If `frames/` or `snaps/` is a link to a drive that isn't mounted, the link points nowhere and saving there would fail. Snapcap checks first. It checks about once a second, at the start of every take and snap, and on every recorded frame. When storage can't be reached:

- frames go to `frames_local/` and snaps to `snaps_local/`, inside the sketch, with the same folder and file names
- the console prints `STORAGE OFFLINE` and says which folder is missing
- a yellow `STORAGE OFFLINE` bar shows on screen, even with the status hidden, and is never captured
- if the drive disappears in the middle of a take, the rest of that take goes to `frames_local/` under the same take folder

When the drive comes back, the console says so and new takes and snaps go back to storage. Anything saved locally stays in `frames_local/` and `snaps_local/` for you to move over. Both folders are in the new-project `.gitignore`. The same check covers an absolute root set with `setFrameRoot("/Volumes/MyDrive/frames")`: Snapcap never creates a stand-in folder for a missing drive.
