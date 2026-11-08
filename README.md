# snapcap
Frame recording utility.

A tool for recording, labeling, and organizing animation frames from Processing sketches.

## How it works

```mermaid
flowchart TD
    A["setup: new Snapcap with your project name"] --> G["Ask git for the version<br/>for example v1.1.0-2-g47fc45b-dirty<br/>or nogit if git is not found"]
    G --> R["Register hooks with Processing<br/>registerMethod draw and keyEvent"]

    subgraph EVERY ["Every frame, automatically"]
        D1["Your draw makes the art"] --> D2["Snapcap draw runs right after"]
        D2 --> Q{"Recording?"}
        Q -->|yes| SF["saveFrame writes one TIFF"]
        Q -->|no| OV["Draw the REC overlay<br/>after the save, so it is never captured"]
        SF --> OV
    end

    subgraph KEYS ["On key press, alongside your keyPressed"]
        K{"Which key?"}
        K -->|r| T["Start or stop a take<br/>new folder named by its start time"]
        K -->|ENTER| S["save writes one snap"]
        K -->|d or i| H["Toggle overlay or print key list"]
    end

    R --> D1
    R --> K
    T -.->|switches recording| Q

    SF --> FR[("frames / VERSION / TAKE START TIME /<br/>TIME-FRAMECOUNT.tif")]
    S --> SN[("snaps / VERSION /<br/>PROJECT-TIME-MILLIS-VERSION.tif")]
```

Snapcap runs on its own once it's created: Processing calls it after every `draw()` and on every key press. Frames are film, one folder per take, ready to turn into video. Snaps are stills, one flat folder per version. Both are labeled with the git version that made them.

## Start a new project

`snap_new_project` is a build script that stamps out a ready-to-run Processing sketch with Snapcap already wired in. Think of it as a cookie cutter: `template/` is the cutter, and every project it makes comes out the same shape, with its own name and version pressed in.

```bash
source snapcap.sh                          # or via snapcap.cfg
snap_new_project myArt v0.1.0 ~/sketches   # leave any part out to be asked
./snapcap.sh snap_new_project myArt        # also works without sourcing
```

### How the script runs

```mermaid
flowchart TD
    A["snap_new_project name version parent"] --> B{"Name given?"}
    B -->|no| B1["Ask for it"] --> C
    B -->|yes| C{"Valid sketch name?<br/>letters, digits, _"}
    C -->|no| X["Stop with a message,<br/>nothing written"]
    C -->|yes| D{"Version given?"}
    D -->|no| D1["Ask, default v0.1.0"] --> E
    D -->|yes| E{"Valid version?"}
    E -->|no| X
    E -->|yes| F{"Parent folder given?"}
    F -->|no| F1["Ask, default SNAP_PROJECTS_DIR<br/>then JAY_SPACE then here"] --> G
    F -->|yes| G{"Parent exists and<br/>project folder is new?"}
    G -->|no| X
    G -->|yes| H["Read snapcap release<br/>git describe in this repo"]

    subgraph BUILD ["Build the project folder"]
        H --> I["Copy Snapcap.pde<br/>from snapcap_util"]
        I --> J["Fill templates with name,<br/>version, release, date:<br/>sketch, README, gitignore"]
        J --> K["Write .snapcap<br/>release and date"]
    end

    K --> L{"SNAP_STORAGE_DIR set?"}
    L -->|yes| M["Link frames and snaps<br/>into central storage"] --> N
    L -->|no| N["git init, commit,<br/>tag the version"]
    N --> O["Open the .pde in Processing<br/>and press Run"]
```

Step by step:

1. **Gather.** The name, version and parent folder come from the arguments. Anything missing is asked for, with defaults in brackets.
2. **Check.** It stops before writing anything if the name isn't a valid Processing sketch name, the version has characters that would break a folder name, the parent folder doesn't exist, or the project folder already exists. Nothing gets overwritten.
3. **Build.** It copies `Snapcap.pde` and fills the files in `template/`, swapping `__PROJECT__`, `__VERSION__`, `__SNAPCAP_RELEASE__` and `__DATE__` for real values. Only the files a sketch needs are copied: no `.git`, demo layers or notes.
4. **Link storage (optional).** If `SNAP_STORAGE_DIR` is set (for example `~/Dropbox/_SNAPS`), the sketch's `frames` and `snaps` become links into `$SNAP_STORAGE_DIR/myArt/`, so big image files land in central storage instead of next to the code.
5. **Version.** It runs `git init`, commits, and tags that first commit with the version. Snapcap reads its version from git, so the first frame you record is already labeled `v0.1.0`. Tag again (`git tag v0.2.0`) and new output gets the new label.

What you get:

```
~/sketches/myArt/
    README.md            project name, version, snapcap release, date
    .gitignore           frames and snaps stay out of git
    .snapcap             which snapcap release it came from
    myArt/myArt.pde      starter sketch, already calling new Snapcap("myArt")
    myArt/Snapcap.pde    copied from snapcap_util
```

The sketch folder takes the project's name because Processing needs the folder and the main `.pde` to match. To change what every new project starts with, edit the files in `template/`. `bash tests/test_new_project.sh` checks the whole process, and CI runs it on macOS.

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

| Key | Action |
| --- | --- |
| `r` | Start/stop recording a frame sequence |
| ENTER | Snap a single frame |
| `d` | Show/hide the on-screen status (never captured) |
| `i` | Print the key list |

Output:

- Snaps: `snaps/<version>/<project>-yyyymmdd-hhmmss-<millis>-<version>.tif`
- Frames: `frames/<version>/<start time>/yyyymmdd-hhmmss-#######.tif`, one folder per recording

Options (call in `setup()`): `setRecordKey('R')`, `keysOff()`, `setSnapRoot(path)`, `setFrameRoot(path)`.
