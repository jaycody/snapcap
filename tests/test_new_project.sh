#!/bin/bash
# Checks that snap_new_project builds a complete, tagged sketch.
# Run from anywhere:  bash tests/test_new_project.sh

HERE="$(cd "$(dirname "$0")/.." && pwd)"
. "$HERE/snapcap.sh"

# No terminal on stdin, so snap_new_project never stops to ask about storage.
exec < /dev/null

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com

fails=0
check () { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; fails=$((fails + 1)); fi; }

snap_new_project myArt "$TMP" > /dev/null
P="$TMP/myArt"
check "sketch folder matches name"      '[ -f "$P/myArt/myArt.pde" ]'
check "Snapcap.pde copied unchanged"    'cmp -s "$HERE/snapcap_util/Snapcap.pde" "$P/myArt/Snapcap.pde"'
check "sketch calls new Snapcap"        'grep -q "new Snapcap(\"myArt\")" "$P/myArt/myArt.pde"'
check "sketch sets pixelDensity(1)"     'grep -q "^  pixelDensity(1);" "$P/myArt/myArt.pde"'
check "no placeholders left"           '! grep -rq "__[A-Z_]*__" "$P/README.md" "$P/myArt"'
check "README names the project"        'grep -q "^# myArt" "$P/README.md"'
check "settings file is valid JSON"     'python3 -m json.tool "$P/myArt/snapcap.json" > /dev/null'
check "settings record the release"     'grep -q "\"release\": \"$(git -C "$HERE" describe --tags --always --dirty)\"" "$P/myArt/snapcap.json"'
check "no old .snapcap file"            '[ ! -e "$P/.snapcap" ]'
check "frames and snaps ignored"        'grep -q "^frames$" "$P/.gitignore"'
check "demo files not copied"           '[ ! -e "$P/myArt/ImageLayer.pde" ]'
check "git version is v0.0.1"           '[ "$(git -C "$P/myArt" describe --tags --always --dirty)" = "v0.0.1" ]'

# Central storage: frames/ and snaps/ become symlinks
mkdir -p "$TMP/store"
SNAP_STORAGE_DIR="$TMP/store" snap_new_project linked "$TMP" > /dev/null
check "frames link to storage"  '[ -L "$TMP/linked/linked/frames" ] && [ -d "$TMP/store/linked-media/frames" ]'
check "snaps link to storage"   '[ -L "$TMP/linked/linked/snaps" ] && [ -d "$TMP/store/linked-media/snaps" ]'
check "no-terminal run skips ~/snapcap-media" '[ ! -e "$TMP/myArt/myArt/frames" ] || [ ! -L "$TMP/myArt/myArt/frames" ]'
check "links kept out of git"   '[ -z "$(git -C "$TMP/linked" status --porcelain)" ]'

# Storage folder missing (drive not mounted): no links, nothing created there
SNAP_STORAGE_DIR="$TMP/unmounted/_SNAPS" snap_new_project nodrive "$TMP" > /dev/null 2>&1
check "missing storage makes no links"   '[ -d "$TMP/nodrive/nodrive" ] && [ ! -e "$TMP/nodrive/nodrive/frames" ]'
check "missing storage not created"      '[ ! -e "$TMP/unmounted" ]'
check "local fallbacks kept out of git"  'grep -q "^frames_local$" "$TMP/nodrive/.gitignore"'

# Interactive prompts: name and folder are asked, version is always v0.0.1
printf "promptArt\n%s\n" "$TMP" | snap_new_project > /dev/null
check "prompts fill in name, version v0.0.1" '[ "$(git -C "$TMP/promptArt" describe --tags)" = "v0.0.1" ]'

# The old 3-part form (name version parent) is refused, nothing created
check "refuses a version argument"       '! snap_new_project oldForm v2.0.0 "$TMP" 2>/dev/null && [ ! -e "$TMP/oldForm" ]'
check "refuses version in 2nd place"     '! snap_new_project oldForm2 v2.0.0 2>/dev/null && [ ! -e "$TMP/oldForm2" ]'

check "refuses bad name"        '! snap_new_project 9lives "$TMP" 2>/dev/null'
check "refuses name with dash"  '! snap_new_project my-art "$TMP" 2>/dev/null'
check "refuses existing folder" '! snap_new_project myArt "$TMP" 2>/dev/null'
check "refuses missing parent"  '! snap_new_project other "$TMP/nope" 2>/dev/null'

echo ""
[ "$fails" -eq 0 ] && echo "all passed" || { echo "$fails failed"; exit 1; }
