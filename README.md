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

`snap_new_project` makes a ready-to-run sketch with Snapcap already wired in:

```bash
source snapcap.sh                        # or via snapcap.cfg
snap_new_project myArt v0.1.0 ~/sketches # leave any part out to be asked
```

```
~/sketches/myArt/
    README.md
    .gitignore           frames/ and snaps/ stay out of git
    .snapcap             which snapcap release it came from
    myArt/myArt.pde      starter sketch, already calling new Snapcap("myArt")
    myArt/Snapcap.pde
```

It also runs `git init`, commits, and tags the first commit `v0.1.0`, so the first frames you record are already labeled with that version. The parent folder defaults to `$SNAP_PROJECTS_DIR`, then `$JAY_SPACE`, then the current directory.

Set `SNAP_STORAGE_DIR` (for example `~/Dropbox/_SNAPS`) and the sketch's `frames/` and `snaps/` become links into `$SNAP_STORAGE_DIR/myArt/`, so the image files land in central storage instead of next to the code. The starter files live in `template/`; edit them to change what every new project starts with.

Without sourcing: `./snapcap.sh snap_new_project myArt`.

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
