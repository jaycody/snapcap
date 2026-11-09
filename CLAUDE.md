# snapcap

A Processing (Java) tool that records and snaps frames from sketches, plus
`snap_new_project`, a script that stamps out new sketches with Snapcap built in.

## Layout

- `snapcap_util/Snapcap.pde`: the library. `snap_new_project` copies it into
  every new project unchanged, so changes here ship to all future projects.
- `snapcap_util/*.pde` (other tabs): the demo sketch. Never copied into projects.
- `template/`: the new-project starter (`sketch.pde`, `snapcap.json`, README, gitignore).
- `snapcap.sh`: shell tools, including `snap_new_project`.
- `tests/`: `test_new_project.sh` and `test_storage_check.sh`.
- `docs/diagrams/*.mmd`: Mermaid sources for the README images.

## Running

- Processing 4 lives at `/Applications/Processing.app`. Run a sketch headlessly:
  `/Applications/Processing.app/Contents/MacOS/Processing cli --sketch=<folder> --run`
  The sketch keeps running until its window closes; for checks, run a copy in a
  scratch folder that calls `exit()` after a few frames.
- Java comes from Processing's bundled JDK (`JAVA_HOME` is set in `~/.zshrc`).

## Tests

```bash
bash tests/test_new_project.sh
bash tests/test_storage_check.sh
```

`test_storage_check.sh` compiles `Snapcap.pde` as plain Java, without
Processing's automatic imports. In `Snapcap.pde`, write `java.util.ArrayList`,
`java.io.InputStreamReader` and so on in full, or the test (and older
Processing versions) won't compile it.

## Conventions

- Frames save as TGA and snaps as PNG by default; TIFF is still allowed in `snapcap.json`.
- Frames are written on background threads; `draw()` only copies the screen.
- Sketches set `pixelDensity(1)` so frames match `size()` on Retina screens.
- Snapcap's overlay and anything drawn after `get()` never end up in a frame.
- The demo's `ImageLayer` has a deliberately homemade look. Keep changes to it
  small and in Jason's style rather than polishing it.

## Working with Jason

- If the sketch is open in the Processing IDE, it may not reload files changed
  on disk. Saving from the IDE then overwrites edits made outside it.
- Commit locally on a branch; don't push or open a PR until Jason asks.
- `docs/diagrams/render.sh` needs Node, which this Mac doesn't have.
