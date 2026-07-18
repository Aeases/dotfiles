#!/usr/bin/env bash
# opus_to_ogg.sh — Convert all .opus files in a directory to .ogg (Ogg Vorbis)
#                   and replace the originals.
#
# Usage:
#   ./opus_to_ogg.sh [DIRECTORY] [OPTIONS]
#
# Arguments:
#   DIRECTORY   Path to folder containing .opus files (default: current directory)
#
# Options:
#   -r          Recurse into sub-directories
#   -q QUALITY  Vorbis quality, 0–10 (default: 6 ≈ ~192 kbps)
#   -k          Keep original .opus files (don't delete after conversion)
#   -h          Show this help message
#
# Examples:
#   ./opus_to_ogg.sh ~/Music
#   ./opus_to_ogg.sh ~/Music -r -q 8
#   ./opus_to_ogg.sh . -k

set -euo pipefail

# ── Defaults ──────────────────────────────────────────────────────────────────
TARGET_DIR="."
RECURSE=false
QUALITY=6
KEEP_ORIGINALS=false

# ── Colours ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Colour

# ── Argument parsing ──────────────────────────────────────────────────────────
if [[ $# -gt 0 && "$1" != -* ]]; then
    TARGET_DIR="$1"
    shift
fi

while getopts ":rq:kh" opt; do
    case $opt in
        r) RECURSE=true ;;
        q) QUALITY="$OPTARG" ;;
        k) KEEP_ORIGINALS=true ;;
        h)
            sed -n '/^# Usage:/,/^[^#]/p' "$0" | grep '^#' | sed 's/^# \?//'
            exit 0
            ;;
        \?) echo -e "${RED}Unknown option: -$OPTARG${NC}" >&2; exit 1 ;;
        :)  echo -e "${RED}Option -$OPTARG requires an argument.${NC}" >&2; exit 1 ;;
    esac
done

# ── Validation ────────────────────────────────────────────────────────────────
if ! command -v ffmpeg &>/dev/null; then
    echo -e "${RED}Error: ffmpeg is not installed. Install it and try again.${NC}" >&2
    exit 1
fi

if [[ ! -d "$TARGET_DIR" ]]; then
    echo -e "${RED}Error: Directory '$TARGET_DIR' does not exist.${NC}" >&2
    exit 1
fi

if ! [[ "$QUALITY" =~ ^[0-9]$|^10$ ]]; then
    echo -e "${RED}Error: Quality must be an integer 0–10.${NC}" >&2
    exit 1
fi

# ── File discovery ────────────────────────────────────────────────────────────
if $RECURSE; then
    mapfile -t FILES < <(find "$TARGET_DIR" -type f -iname "*.opus")
else
    mapfile -t FILES < <(find "$TARGET_DIR" -maxdepth 1 -type f -iname "*.opus")
fi

if [[ ${#FILES[@]} -eq 0 ]]; then
    echo -e "${YELLOW}No .opus files found in '$TARGET_DIR'.${NC}"
    exit 0
fi

echo -e "${CYAN}Found ${#FILES[@]} .opus file(s) in '$TARGET_DIR'${RECURSE:+" (recursive)"}${NC}"
echo -e "  Quality: ${QUALITY}/10 | Keep originals: ${KEEP_ORIGINALS}"
echo ""

# ── Conversion ────────────────────────────────────────────────────────────────
SUCCESS=0
FAILED=0

for OPUS_FILE in "${FILES[@]}"; do
    OGG_FILE="${OPUS_FILE%.opus}.ogg"
    BASENAME=$(basename "$OPUS_FILE")

    printf "  Converting %-50s" "$BASENAME"

    if ffmpeg -y -i "$OPUS_FILE" \
              -c:a libvorbis \
              -q:a "$QUALITY" \
              -map_metadata 0 \
              "$OGG_FILE" \
              -loglevel error 2>/tmp/ffmpeg_err.txt; then

        if ! $KEEP_ORIGINALS; then
            rm -f "$OPUS_FILE"
        fi
        echo -e "${GREEN}✓${NC}"
        (( SUCCESS++ )) || true
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo -e "    ${RED}$(cat /tmp/ffmpeg_err.txt)${NC}"
        # Remove incomplete output file if it exists
        [[ -f "$OGG_FILE" ]] && rm -f "$OGG_FILE"
        (( FAILED++ )) || true
    fi
done

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "Done — ${GREEN}${SUCCESS} converted${NC}, ${RED}${FAILED} failed${NC}."
if ! $KEEP_ORIGINALS && [[ $SUCCESS -gt 0 ]]; then
    echo -e "${YELLOW}Original .opus files have been removed.${NC}"
fi

exit $FAILED
