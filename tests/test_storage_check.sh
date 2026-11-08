#!/bin/bash
# Compiles Snapcap.pde against Processing's core.jar and checks the storage
# fallback (broken links, unmounted drives, storage coming back) and the
# snapcap.json settings file.
# Needs Java and network access (downloads core.jar once into tests/.cache).
# Run from anywhere:  bash tests/test_storage_check.sh

HERE="$(cd "$(dirname "$0")/.." && pwd)"
CACHE="$HERE/tests/.cache"
JAR="$CACHE/core-3.3.7.jar"
mkdir -p "$CACHE"
if [ ! -f "$JAR" ]; then
    curl -sSfL -o "$JAR" https://repo1.maven.org/maven2/org/processing/core/3.3.7/core-3.3.7.jar || exit 1
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
{
    echo 'import processing.core.*; import processing.data.*; import java.io.*; import java.nio.file.*;'
    echo 'public class T extends PApplet {'
    cat "$HERE/snapcap_util/Snapcap.pde"
    cat "$HERE/tests/StorageCheck.java.in"
    echo '}'
} > "$WORK/T.java"

javac -nowarn -cp "$JAR" -d "$WORK" "$WORK/T.java" || exit 1
mkdir "$WORK/sketch"
cd "$WORK/sketch" && java -Dtemplate="$HERE/template/snapcap.json" -cp "$JAR:$WORK" T | grep -E '^(ok|FAIL) '
exit "${PIPESTATUS[0]}"
