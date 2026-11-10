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
#       <name>/<name>.pde   starter sketch, already calling new Snapcap
#       <name>/Snapcap.pde  copied from snapcap_util
#       <name>/snapcap.json settings Snapcap reads at startup, plus the
#                           snapcap release and date the project came from
#
# then runs git init, commits, and tags <version>, so the very first
# frames are labeled with it.
#
# Usage:  snap_new_project [name] [parent dir]
#   2026-11-10: no version argument. Every project starts at v0.0.1: the
#   script tags the first commit, and Snapcap reads the version from git.
#   Later versions come from git tag (git tag v0.0.2). Old usage in FOSSIL RECORD.
#   Anything left out is asked for. The parent defaults to
#   $SNAP_PROJECTS_DIR, then $JAY_SPACE, then the current directory.
#
# If $SNAP_STORAGE_DIR is set (say ~/Dropbox/_SNAPS), frames/ and snaps/
# are symlinks into $SNAP_STORAGE_DIR/<name>-media/ (2026-11-09: was <name>/;
# in a terminal ~/snapcap-media is offered when it isn't set), so big image files land in
# central storage instead of next to the code. If that folder isn't there
# (drive not mounted), no links are made. Snapcap itself also falls back
# to frames_local/ and snaps_local/ whenever a link can't be reached.
snap_new_project () {
    # 2026-11-09: --help / -h shows help instead of failing as a sketch name
    case "$1" in -h|--help) snap_help; return 0 ;; esac
    # 2026-11-10: just name and parent. The version is always v0.0.1.
    # Old 3-part form (name version parent) is refused, not guessed at.
    local name="$1" parent="$2" version="v0.0.1"
    if [ $# -gt 2 ] || { [ -n "$parent" ] && [ ! -d "$parent" ] && case "$parent" in v[0-9]*) true ;; *) false ;; esac; }; then
        echo "snap_new_project: there's no version argument anymore." >&2
        echo "  Use: snap_new_project [name] [parent folder]. Every project starts at v0.0.1;" >&2
        echo "  later, inside the project: git tag v0.0.2" >&2
        return 1
    fi
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

    # 2026-11-09: every new project starts at v0.0.1 -- no question.
    # 2026-11-10: version check moved to FOSSIL RECORD (nobody passes one now).

    if [ -z "$parent" ]; then
        # 2026-11-09: was "Create it in [dir]: ", which read like a yes/no
        # question -- answering "yes" made it look for a folder named yes.
        # Show the real path and ask a real yes/no. The default parent comes
        # from SNAP_PROJECTS_DIR, then JAY_SPACE, then here -- that's what
        # makes this work on other machines.
        echo "New project will be created at:"
        echo "  ${default_parent%/}/$name"
        printf "Press Enter (or y) to create it, n to cancel, or type a different folder to put it in: "
        read -r parent
        case "$parent" in
            ''|[Yy]|[Yy][Ee][Ss]) parent="$default_parent" ;;
            [Nn]|[Nn][Oo]) echo "Cancelled, nothing created."; return 1 ;;
        esac
    fi
    # A typed ~ isn't expanded by read, so ~/sketches would fail. Expand it.
    case "$parent" in
        "~")   parent="$HOME" ;;
        "~/"*) parent="$HOME/${parent#\~/}" ;;
    esac
    if [ ! -d "$parent" ]; then
        echo "snap_new_project: no such directory: $parent" >&2
        return 1
    fi

    local dest="${parent%/}/$name"
    if [ -e "$dest" ]; then
        echo "snap_new_project: $dest already exists, leaving it alone." >&2
        return 1
    fi

    # ---- Where frames and snaps go (2026-11-09) ----
    # Two different places: the PROJECT goes in <parent>/<name> (code, git);
    # its MEDIA goes in <storage>/<name>-media/frames and /snaps.
    # <storage> = SNAP_STORAGE_DIR if set, else ~/snapcap-media.
    # In a terminal you confirm it: Enter = use it, n = keep media in the
    # sketch, or type another storage folder. Without a terminal (tests,
    # pipes) only a set SNAP_STORAGE_DIR is used, so scripts never write
    # into ~/snapcap-media on their own.
    local default_storage="${SNAP_STORAGE_DIR:-$HOME/snapcap-media}"
    local storage="$SNAP_STORAGE_DIR"
    if [ -t 0 ]; then
        local answer
        storage="$default_storage"
        echo ""
        echo "Frames and snaps (the big image files) will be saved outside the project, in:"
        echo "  ${storage%/}/$name-media/frames"
        echo "  ${storage%/}/$name-media/snaps"
        printf "Press Enter to use this, n to keep them inside the sketch folder instead, or type a different storage folder: "
        read -r answer
        case "$answer" in
            ''|[Yy]|[Yy][Ee][Ss]) ;;
            [Nn]|[Nn][Oo]) storage="" ;;
            "~")   storage="$HOME" ;;
            "~/"*) storage="$HOME/${answer#\~/}" ;;
            *)     storage="$answer" ;;
        esac

        if [ -n "$storage" ] && [ ! -d "$storage" ]; then
            if [ "$storage" = "$HOME/snapcap-media" ]; then
                mkdir -p "$storage" || return 1      # the default: just make it
            else
                local make_it
                printf "%s doesn't exist. Create it? (y/n): " "$storage"
                read -r make_it
                case "$make_it" in
                    [Yy]|[Yy][Ee][Ss]) mkdir -p "$storage" || return 1 ;;
                    *) echo "Keeping frames and snaps inside the sketch."; storage="" ;;
                esac
            fi
        fi
        # Typed a new storage folder? Offer to make it the default.
        if [ -n "$storage" ] && [ "$storage" != "$default_storage" ]; then
            _snap_remember_storage "$storage"
        fi
    fi

    # Same name used before? Its media folder would be shared.
    if [ -n "$storage" ] && [ -e "${storage%/}/$name-media" ]; then
        echo "storage: ${storage%/}/$name-media already exists (a project with this name was made before?)." >&2
        local reuse=""
        if [ -t 0 ]; then
            printf "Reuse it? Frames from both projects would share it. (y/n): "
            read -r reuse
        fi
        case "$reuse" in
            [Yy]|[Yy][Ee][Ss]) ;;
            *) echo "Cancelled, nothing created. Try a different name." >&2; return 1 ;;
        esac
    fi

    local release today
    release="$(git -C "$SNAPCAP_HOME" describe --tags --always --dirty 2>/dev/null || echo unknown)"
    today="$(date +%Y-%m-%d)"

    echo ""
    echo "Creating $dest"
    echo "  project: $name"
    echo "  version: $version"
    echo "  snapcap: $release"
    if [ -n "$storage" ]; then
        echo "  frames, snaps: ${storage%/}/$name-media/"
    else
        echo "  frames, snaps: inside the sketch"
    fi
    echo ""

    # Copy only the files a new sketch needs (no .git, demo layers or notes).
    mkdir -p "$dest/$name" || return 1
    cp "$SNAPCAP_HOME/snapcap_util/Snapcap.pde" "$dest/$name/Snapcap.pde" || return 1
    cp "$SNAPCAP_HOME/template/gitignore" "$dest/.gitignore" || return 1
    _snap_fill "$SNAPCAP_HOME/template/sketch.pde" "$dest/$name/$name.pde" \
        "$name" "$version" "$release" "$today" || return 1
    _snap_fill "$SNAPCAP_HOME/template/README.md" "$dest/README.md" \
        "$name" "$version" "$release" "$today" || return 1
    _snap_fill "$SNAPCAP_HOME/template/snapcap.json" "$dest/$name/snapcap.json" \
        "$name" "$version" "$release" "$today" || return 1

    if [ -n "$storage" ] && [ ! -d "$storage" ]; then
        # Don't create it: on a Mac that would put a stand-in folder where
        # an unmounted drive should be. Saving stays inside the sketch.
        echo "storage: $storage isn't there (drive not mounted?), so frames and snaps stay in the sketch." >&2
        echo "         Link them later with: ln -s <storage>/$name-media/frames $dest/$name/frames" >&2
    elif [ -n "$storage" ]; then
        local store="${storage%/}/$name-media"
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

    # 2026-11-09: land in the new project. Only works when sourced (jayci);
    # ./snapcap.sh runs in its own process, so there it prints the cd instead.
    if [ -n "${BASH_SOURCE[0]:-}" ] && [ "${BASH_SOURCE[0]}" = "$0" ]; then
        echo "Next:  cd $dest"
    else
        cd "$dest" && echo "Now in: $dest"
    fi
    echo ""
}

# Offer to keep a storage folder for every new project. Writes one
# export line into jayci's .jayrc (next to the other globals), or prints
# it when jayci isn't here. (added 2026-11-09)
_snap_remember_storage () {
    local dir="$1" yn line rc tmp
    printf "Use %s for every new project from now on? (y/n): " "$dir"
    read -r yn
    case "$yn" in [Yy]|[Yy][Ee][Ss]) ;; *) return 0 ;; esac

    export SNAP_STORAGE_DIR="$dir"     # this terminal, right away
    line="export SNAP_STORAGE_DIR=\"$dir\"   # snapcap: top folder for frames/snaps (set by snap_new_project $(date +%Y-%m-%d)). Delete to be asked again."
    rc="${JAY_SPACE:+$JAY_SPACE/jayci/.jayrc}"
    if [ -n "$rc" ] && [ -f "$rc" ]; then
        tmp="$(mktemp)" || return 1
        awk -v line="$line" '
            { print }
            /^export JAY_HOME=/ && !done { print line; done = 1 }
            END { if (!done) print line }
        ' "$rc" > "$tmp" && cat "$tmp" > "$rc"
        rm -f "$tmp"
        echo "Saved in $rc"
    else
        echo "To keep it, add this line to your shell config (~/.zshrc):"
        echo "  $line"
    fi
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
# (2026-11-09: paths now come from SNAPCAP_HOME, so they work again.
#  Scope is on purpose: ONLY the media folders inside snapcap itself,
#  never external storage. Old versions in FOSSIL RECORD at the bottom.)


# Empty one media folder inside snapcap_util/. Refuses anything that
# isn't a real folder inside this repo, so a link out to external
# storage (e.g. ~/Dropbox/_SNAPS) is never followed or emptied.
_snap_clean_dir () {
    local dir="${SNAPCAP_HOME:?SNAPCAP_HOME not set}/snapcap_util/$1"

    if [ -L "$dir" ]; then
        echo "  skip  $1/  is a link to external storage -- not touching it"
        return 0
    fi
    if [ ! -d "$dir" ]; then
        echo "  skip  $1/  (not there)"
        return 0
    fi
    case "$(cd "$dir" && pwd -P)" in
        "$(cd "$SNAPCAP_HOME" && pwd -P)"/snapcap_util/*) ;;
        *) echo "  skip  $1/  resolves outside snapcap -- not touching it"; return 0 ;;
    esac

    echo ""
    _snap_show "$dir"
    # -mindepth 1: empty the folder, keep the folder. rm -rf on a link
    # inside removes the link only, never what it points to.
    find "$dir" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
    echo "Deleting $1 from snapcap/snapcap_util/$1/"
    _snap_show "$dir"
    echo "$1 deleted"
}

# treela when it's there (sourced via jayci), plain ls otherwise.
_snap_show () {
    if command -v tree > /dev/null 2>&1; then tree -Csha "$1"; else ls -A "$1"; fi
}


snap_clean_snaps () {
    # Clean the local ./snaps/ directory (+ snaps_local/ fallback)
    echo ""
    _snap_clean_dir snaps
    _snap_clean_dir snaps_local
    echo ""
}




snap_clean_frames () {
    # Clean the local ./frames/ directory (+ frames_local/ fallback)
    echo ""
    _snap_clean_dir frames
    _snap_clean_dir frames_local
    echo ""
}



snap_clean_all () {
    # Clean the local ./frames/ and ./snaps/ directories
    snap_clean_frames
    snap_clean_snaps
}



###### HELP #######
# snapcap --help (jayci), ./snapcap.sh --help, snap_help, snap_new_project --help
# (added 2026-11-09)
snap_help () {
    local release
    release=$(git -C "$SNAPCAP_HOME" describe --tags --always --dirty 2>/dev/null || echo "nogit")
    cat << HELP

    ***********  snapcap  ${release}  ***********
    Frame recording utility for Processing sketches.
    Repo: ${SNAPCAP_HOME}

    -----------SHELL COMMANDS-------------
    snap_new_project [name] [parent]   (starts at v0.0.1)
                    new Processing sketch with Snapcap built in.
                    Anything left out is asked for.
                    parent: \$SNAP_PROJECTS_DIR, else \$JAY_SPACE, else here
                    ex.  snap_new_project myArt
    snap_clean_frames   empty snapcap_util/frames + frames_local
    snap_clean_snaps    empty snapcap_util/snaps  + snaps_local
    snap_clean_all      both. Links to external storage are skipped.
    snap_help           this help  (also: snapcap --help)

    Without jayci:  ./snapcap.sh <command> [args]
                    ./snapcap.sh --help

    -----------IN A SKETCH-------------
    setup():  snapcap = new Snapcap("myArt");
    r       start/stop recording frames  (TGA, one folder per take)
    ENTER   snap a single frame          (PNG)
    d       show/hide the status overlay (never captured)
    i       print the key list
    Keys, folders and formats can be changed in the sketch's snapcap.json.

    -----------SETTINGS (env vars)-------------
    SNAP_STORAGE_DIR    top folder for media; each project gets
                        <storage>/<name>-media/frames and /snaps.
                        Not set: ~/snapcap-media. snap_new_project shows
                        it and asks (Enter = use it, n = keep in sketch).
                        now: ${SNAP_STORAGE_DIR:-not set, using ~/snapcap-media}
    SNAP_PROJECTS_DIR   default parent folder   now: ${SNAP_PROJECTS_DIR:-not set}

    -----------MORE-------------
    template/       what every new project starts with
    README.md       full docs + diagrams (docs/diagrams/)

HELP
}


# Run directly instead of sourced:  ./snapcap.sh snap_new_project myProj
# 2026-11-09: no command, -h or --help shows help. Old block in FOSSIL RECORD.
if [ "${BASH_SOURCE[0]:-}" = "$0" ]; then
    case "${1:-}" in
        ''|-h|--help|help) snap_help ;;
        *) "$@" ;;
    esac
fi


###############################################################
###            >>> FOSSIL RECORD <<<
###############################################################
# Moved here 2026-11-09 (Claude). These were the snap_clean_* bodies.
# WHY: JAYCI_WORKSPACE was never set anywhere (jayci uses JAY_SPACE), so
#      the paths became /snapcap/snapcap_util/... at the root of the drive
#      and rm -rf hit nothing. An unset variable in an rm -rf path is
#      exactly what CODE_REVIEW.md warned about. Also: `treela` doesn't
#      exist when this file runs as ./snapcap.sh.
#---------------------------------------------------------------
# # TODO: Allow user input to determine path.
# #           - Path needs to be project specific, not hardcoded
# snap_clean_snaps () {
#     # Clean the local ./snaps/ directory
#     echo ""
#     treela ${JAYCI_WORKSPACE}/snapcap/snapcap_util/snaps/ 
#     rm -rf ${JAYCI_WORKSPACE}/snapcap/snapcap_util/snaps/* || true 
#     echo ""
#     echo "Deleting snaps from snapcap/snapcap_util/snaps/"
#     echo ""
#     treela ${JAYCI_WORKSPACE}/snapcap/snapcap_util/snaps/ 
#     echo "snaps deleted"
#     echo ""
# }
#
#
#
#
# snap_clean_frames () {
#     # Clean the local ./frames/ directory
#     echo ""
#     treela ${JAYCI_WORKSPACE}/snapcap/snapcap_util/frames/ 
#     rm -rf ${JAYCI_WORKSPACE}/snapcap/snapcap_util/frames/* || true 
#     echo ""
#     echo "Deleting frames from snapcap/snapcap_util/frames/"
#     echo ""
#     treela ${JAYCI_WORKSPACE}/snapcap/snapcap_util/frames/ 
#     echo "frames deleted"
#     echo ""
# }
#
#
#
# snap_clean_all () {
#     # Clean the local ./frames/ and ./snaps/ directories
#     echo ""
#     treela ${JAYCI_WORKSPACE}/snapcap/snapcap_util/frames/ 
#     rm -rf ${JAYCI_WORKSPACE}/snapcap/snapcap_util/frames/* || true 
#     echo ""
#     echo "Deleting frames from snapcap/snapcap_util/frames/"
#     echo ""
#     treela ${JAYCI_WORKSPACE}/snapcap/snapcap_util/frames/ 
#     echo "frames deleted"
#     echo ""
#
#     echo ""
#     treela ${JAYCI_WORKSPACE}/snapcap/snapcap_util/snaps/ 
#     rm -rf ${JAYCI_WORKSPACE}/snapcap/snapcap_util/snaps/* || true 
#     echo ""
#     echo "Deleting snaps from snapcap/snapcap_util/snaps/"
#     echo ""
#     treela ${JAYCI_WORKSPACE}/snapcap/snapcap_util/snaps/ 
#     echo "snaps deleted"
#     echo ""
# }

# WHY: running ./snapcap.sh with no command did nothing, and there was no --help.
# if [ "${BASH_SOURCE[0]:-}" = "$0" ] && [ $# -gt 0 ]; then
#     "$@"
# fi

# WHY: every new project starts at v0.0.1, so the question was just noise.
#     if [ -z "$version" ]; then
#         printf "Version [v0.1.0]: "
#         read -r version
#         version="${version:-v0.1.0}"
#     fi

# WHY (2026-11-10): no version argument. Every project starts at v0.0.1; the
# script tags the first commit and Snapcap reads the version from git.
# Old usage comment:
# # Usage:  snap_new_project [name] [version] [parent dir]
# #   version defaults to v0.0.1 and is never asked for (2026-11-09).
# #   snap_new_project myArt ~/sketches  also works: a folder in 2nd place is the parent.
# Old argument handling:
#     local name="$1" version="$2" parent="$3"
#     # 2026-11-09: version is optional, so "myArt ~/sketches" means name + parent.
#     if [ -z "$parent" ] && { [ -d "$version" ] || case "$version" in */*|"~"*) true ;; *) false ;; esac; }; then
#         parent="$version"
#         version=""
#     fi
#     version="${version:-v0.0.1}"
#     case "$version" in
#         *[!A-Za-z0-9._-]*)
#             echo "snap_new_project: version '$version' can only use letters, digits, '.', '_' and '-'." >&2
#             return 1 ;;
#     esac
# Old help line:
#     snap_new_project [name] [version] [parent]   (version: v0.0.1)
###############################################################
