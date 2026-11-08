# __PROJECT__

A Processing sketch, version `__VERSION__`, started from [snapcap](https://github.com/jaycody/snapcap) `__SNAPCAP_RELEASE__` on __DATE__.

## Run it

Open `__PROJECT__/__PROJECT__.pde` in Processing and press Run.

| Key | Action |
| --- | --- |
| `r` | Start/stop recording a frame sequence |
| ENTER | Snap a single frame |
| `d` | Show/hide the on-screen status (never captured) |
| `i` | Print the key list |

## Output

Snapcap labels everything with this project's git version (`git describe --tags --always --dirty`), so tag a release to name your output:

```bash
git tag v0.2.0
```

- Snaps: `__PROJECT__/snaps/<version>/`
- Frames: `__PROJECT__/frames/<version>/<start time>/`

Both folders are in `.gitignore`.
