#!/bin/bash
# Turns each .mmd diagram here into a .png the README shows.
# GitHub's iOS app doesn't draw Mermaid, so the README uses images.
# Needs Node (npx). Run after editing a .mmd:  bash docs/diagrams/render.sh
#
# If Chrome isn't found, point Puppeteer at one:
#   PUPPETEER_EXECUTABLE_PATH=/path/to/chrome bash docs/diagrams/render.sh

cd "$(dirname "$0")" || exit 1
for src in *.mmd; do
    echo "rendering $src"
    npx -y @mermaid-js/mermaid-cli@11.4.2 \
        -i "$src" -o "${src%.mmd}.png" \
        --scale 2 --backgroundColor white ${MMDC_ARGS} || exit 1
done
