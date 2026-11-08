#! /bin/bash

########### BASH TOOLS FOR SNAPCAP ##############


# Where this repo lives, so the functions work from any directory.
# ${BASH_SOURCE[0]} under bash, $0 when sourced from zsh.
SNAPCAP_HOME="${SNAPCAP_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)}"


###### START A NEW PROJECT #######
# Creates a ready-to-run Processing sketch with Snapcap built in:
#
#   <parent>/<name>/
#       README.md
#       .gitignore          frames/ and snaps/ stay out of git
#       .snapcap            which snapcap release it came from
#       <name>/<name>.pde   starter sketch, already calling new Snapcap
#       <name>/Snapcap.pde  copied from snapcap_util
#
# then runs git init, commits, and tags <version>, so the very first
# frames are labeled with it.
#
# Usage:  snap_new_project [name] [version] [parent dir]
#   Anything left out is asked for. The parent defaults to
#   $SNAP_PROJECTS_DIR, then $JAY_SPACE, then the current directory.
#
# If $SNAP_STORAGE_DIR is set (say ~/Dropbox/_SNAPS), frames/ and snaps/
# are symlinks into $SNAP_STORAGE_DIR/<name>/, so big image files land in
# central storage instead of next to the code. If that folder isn't there
# (drive not mounted), no links are made. Snapcap itself also falls back
# to frames_local/ and snaps_local/ whenever a link can't be reached.
snap_new_project () {
    local name="$1" version="$2" parent="$3"
    local default_parent="${SNAP_PROJECTS_DIR:-${JAY_SPACE:-$PWD}}"

    if [ -z "$name" ]; then
        printf "Project name (letters, digits, _): "
        read -r name
    fi
    # Processing needs the sketch folder and main .pde to share this name,
    # and it must be a valid Java identifier.
    case "$name" in
        ''|[0-9]*|*[!A-Za-z0-9_]*)
            echo "snap_new_project: '$name' won't work as a Processing sketch name." >&2
            echo "  Use letters, digits and _, starting with a letter." >&2
            return 1 ;;
    esac

    if [ -z "$version" ]; then
        printf "Version [v0.1.0]: "
        read -r version
        version="${version:-v0.1.0}"
    fi
    case "$version" in
        *[!A-Za-z0-9._-]*)
            echo "snap_new_project: version '$version' can only use letters, digits, '.', '_' and '-'." >&2
            return 1 ;;
    esac

    if [ -z "$parent" ]; then
        printf "Create it in [%s]: " "$default_parent"
        read -r parent
        parent="${parent:-$default_parent}"
    fi
    if [ ! -d "$parent" ]; then
        echo "snap_new_project: no such directory: $parent" >&2
        return 1
    fi

    local dest="${parent%/}/$name"
    if [ -e "$dest" ]; then
        echo "snap_new_project: $dest already exists, leaving it alone." >&2
        return 1
    fi

    local release today
    release="$(git -C "$SNAPCAP_HOME" describe --tags --always --dirty 2>/dev/null || echo unknown)"
    today="$(date +%Y-%m-%d)"

    echo ""
    echo "Creating $dest"
    echo "  project: $name"
    echo "  version: $version"
    echo "  snapcap: $release"
    echo ""

    # Copy only the files a new sketch needs (no .git, demo layers or notes).
    mkdir -p "$dest/$name" || return 1
    cp "$SNAPCAP_HOME/snapcap_util/Snapcap.pde" "$dest/$name/Snapcap.pde" || return 1
    cp "$SNAPCAP_HOME/template/gitignore" "$dest/.gitignore" || return 1
    _snap_fill "$SNAPCAP_HOME/template/sketch.pde" "$dest/$name/$name.pde" \
        "$name" "$version" "$release" "$today" || return 1
    _snap_fill "$SNAPCAP_HOME/template/README.md" "$dest/README.md" \
        "$name" "$version" "$release" "$today" || return 1
    printf "snapcap %s\ncreated %s\n" "$release" "$today" > "$dest/.snapcap"

    if [ -n "$SNAP_STORAGE_DIR" ] && [ ! -d "$SNAP_STORAGE_DIR" ]; then
        # Don't create it: on a Mac that would put a stand-in folder where
        # an unmounted drive should be. Saving stays inside the sketch.
        echo "storage: $SNAP_STORAGE_DIR isn't there (drive not mounted?), so frames and snaps stay in the sketch." >&2
        echo "         Link them later with: ln -s <storage>/$name/frames $dest/$name/frames" >&2
    elif [ -n "$SNAP_STORAGE_DIR" ]; then
        local store="${SNAP_STORAGE_DIR%/}/$name"
        mkdir -p "$store/frames" "$store/snaps" &&
        ln -s "$store/frames" "$dest/$name/frames" &&
        ln -s "$store/snaps" "$dest/$name/snaps" &&
        echo "storage: frames/ and snaps/ link to $store/" ||
        echo "storage: couldn't link frames/ and snaps/ to $store/" >&2
    fi

    # Tag the first commit so Snapcap labels output with $version right away.
    if command -v git >/dev/null 2>&1; then
        git -C "$dest" init -q &&
        git -C "$dest" add -A &&
        git -C "$dest" commit -q -m "Start $name from snapcap $release" &&
        git -C "$dest" tag "$version" &&
        echo "git: initialized, first commit tagged $version" ||
        echo "git: repo created, but the first commit or tag failed (is git user.name/user.email set?)" >&2
    else
        echo "git not found: output will be labeled 'nogit' until the project is in a git repo." >&2
    fi

    echo ""
    echo "Open $dest/$name/$name.pde in Processing and press Run."
    echo ""
}

# Copy a template, swapping in the project's details.
# Inputs are already validated, so they're safe inside sed.
_snap_fill () {
    sed -e "s|__PROJECT__|$3|g" \
        -e "s|__VERSION__|$4|g" \
        -e "s|__SNAPCAP_RELEASE__|$5|g" \
        -e "s|__DATE__|$6|g" \
        "$1" > "$2"
}


# TODO: Allow user input to determine path.
#           - Path needs to be project specific, not hardcoded
snap_clean_snaps () {
    # Clean the local ./snaps/ directory
    echo ""
    treela ${JAYCI_WORKSPACE}/snapcap/snapcap_util/snaps/ 
    rm -rf ${JAYCI_WORKSPACE}/snapcap/snapcap_util/snaps/* || true 
    echo ""
    echo "Deleting snaps from snapcap/snapcap_util/snaps/"
    echo ""
    treela ${JAYCI_WORKSPACE}/snapcap/snapcap_util/snaps/ 
    echo "snaps deleted"
    echo ""
}




snap_clean_frames () {
    # Clean the local ./frames/ directory
    echo ""
    treela ${JAYCI_WORKSPACE}/snapcap/snapcap_util/frames/ 
    rm -rf ${JAYCI_WORKSPACE}/snapcap/snapcap_util/frames/* || true 
    echo ""
    echo "Deleting frames from snapcap/snapcap_util/frames/"
    echo ""
    treela ${JAYCI_WORKSPACE}/snapcap/snapcap_util/frames/ 
    echo "frames deleted"
    echo ""
}



snap_clean_all () {
    # Clean the local ./frames/ and ./snaps/ directories
    echo ""
    treela ${JAYCI_WORKSPACE}/snapcap/snapcap_util/frames/ 
    rm -rf ${JAYCI_WORKSPACE}/snapcap/snapcap_util/frames/* || true 
    echo ""
    echo "Deleting frames from snapcap/snapcap_util/frames/"
    echo ""
    treela ${JAYCI_WORKSPACE}/snapcap/snapcap_util/frames/ 
    echo "frames deleted"
    echo ""

    echo ""
    treela ${JAYCI_WORKSPACE}/snapcap/snapcap_util/snaps/ 
    rm -rf ${JAYCI_WORKSPACE}/snapcap/snapcap_util/snaps/* || true 
    echo ""
    echo "Deleting snaps from snapcap/snapcap_util/snaps/"
    echo ""
    treela ${JAYCI_WORKSPACE}/snapcap/snapcap_util/snaps/ 
    echo "snaps deleted"
    echo ""
}



# Run directly instead of sourced:  ./snapcap.sh snap_new_project myProj
if [ "${BASH_SOURCE[0]:-}" = "$0" ] && [ $# -gt 0 ]; then
    "$@"
fi
