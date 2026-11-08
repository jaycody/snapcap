#!/bin/bash
# Checks that snap_new_project builds a complete, tagged sketch.
# Run from anywhere:  bash tests/test_new_project.sh

HERE="$(cd "$(dirname "$0")/.." && pwd)"
. "$HERE/snapcap.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com

fails=0
check () { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; fails=$((fails + 1)); fi; }

snap_new_project myArt v0.3.0 "$TMP" > /dev/null
P="$TMP/myArt"
check "sketch folder matches name"      '[ -f "$P/myArt/myArt.pde" ]'
check "Snapcap.pde copied unchanged"    'cmp -s "$HERE/snapcap_util/Snapcap.pde" "$P/myArt/Snapcap.pde"'
check "sketch calls new Snapcap"        'grep -q "new Snapcap(\"myArt\")" "$P/myArt/myArt.pde"'
check "no placeholders left"            '! grep -rq "__[A-Z_]*__" "$P/README.md" "$P/myArt"'
check "README names the project"        'grep -q "^# myArt" "$P/README.md"'
check "snapcap release recorded"        'grep -q "^snapcap " "$P/.snapcap"'
check "frames and snaps ignored"        'grep -q "^frames$" "$P/.gitignore"'
check "demo files not copied"           '[ ! -e "$P/myArt/ImageLayer.pde" ]'
check "git version is the tag"          '[ "$(git -C "$P/myArt" describe --tags --always --dirty)" = "v0.3.0" ]'

# Central storage: frames/ and snaps/ become symlinks
SNAP_STORAGE_DIR="$TMP/store" snap_new_project linked v1 "$TMP" > /dev/null
check "frames link to storage"  '[ -L "$TMP/linked/linked/frames" ] && [ -d "$TMP/store/linked/frames" ]'
check "snaps link to storage"   '[ -L "$TMP/linked/linked/snaps" ] && [ -d "$TMP/store/linked/snaps" ]'
check "links kept out of git"   '[ -z "$(git -C "$TMP/linked" status --porcelain)" ]'

# Interactive prompts, using the default version
printf "promptArt\n\n%s\n" "$TMP" | snap_new_project > /dev/null
check "prompts fill in name and version" '[ "$(git -C "$TMP/promptArt" describe --tags)" = "v0.1.0" ]'

check "refuses bad name"        '! snap_new_project 9lives v1 "$TMP" 2>/dev/null'
check "refuses name with dash"  '! snap_new_project my-art v1 "$TMP" 2>/dev/null'
check "refuses bad version"     '! snap_new_project okName "v1/2" "$TMP" 2>/dev/null'
check "refuses existing folder" '! snap_new_project myArt v1 "$TMP" 2>/dev/null'
check "refuses missing parent"  '! snap_new_project other v1 "$TMP/nope" 2>/dev/null'

echo ""
[ "$fails" -eq 0 ] && echo "all passed" || { echo "$fails failed"; exit 1; }
