#!/bin/bash
# Turns each .mmd diagram here into a .png the README shows.
# GitHub's iOS app doesn't draw Mermaid, so the README uses images.
# Needs Node (npx). Run after editing a .mmd:  bash docs/diagrams/render.sh
#
# If Chrome isn't found, point Puppeteer at one:
#   PUPPETEER_EXECUTABLE_PATH=/path/to/chrome bash docs/diagrams/render.sh

cd "$(dirname "$0")" || exit 1

# Use the installed Chrome if Puppeteer hasn't downloaded its own
MAC_CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
if [ -z "$PUPPETEER_EXECUTABLE_PATH" ] && [ -x "$MAC_CHROME" ]; then
    export PUPPETEER_EXECUTABLE_PATH="$MAC_CHROME"
fi
for src in *.mmd; do
    echo "rendering $src"
    npx -y @mermaid-js/mermaid-cli@11.4.2 \
        -i "$src" -o "${src%.mmd}.png" \
        --scale 2 --backgroundColor white ${MMDC_ARGS} || exit 1
done
