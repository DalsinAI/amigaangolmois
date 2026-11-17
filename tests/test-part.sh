#!/bin/sh
# PC test for scripts/write-part.sh: the Part file GFOpenUpTool reads.
# MIT, Copyright (c) 2026 AmiCradle Team.
set -eu
HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
D="$T/Games/Angolmois"; mkdir -p "$D/Examples"
: > "$D/Angolmois"; : > "$D/ReadMe"; : > "$D/Examples/longnote-lntype1-last.bml"; : > "$D/Examples/tumba-muffled-1.wav"
sh "$HERE/../scripts/write-part.sh" "$T" 2.0a3
fail=0
expect() { grep -qxF "$1" "$T/Part" || { echo "FAIL: no line: $1"; fail=1; }; }
expect 'part Angolmois 2.0a3'
expect 'needs 68040'
expect 'needs part GFOpenGPU'
expect 'copy "Games/Angolmois/Angolmois" "SYS:Games/Angolmois/Angolmois"'
expect 'copy "Games/Angolmois/Examples/longnote-lntype1-last.bml" "SYS:Games/Angolmois/Examples/longnote-lntype1-last.bml"'
expect 'copy "Games/Angolmois/Examples/tumba-muffled-1.wav" "SYS:Games/Angolmois/Examples/tumba-muffled-1.wav"'
[ "$(head -1 "$T/Part")" = 'part Angolmois 2.0a3' ] || { echo "FAIL: first line"; fail=1; }
[ "$(grep -c '^copy' "$T/Part")" = 4 ] || { echo "FAIL: file count"; fail=1; }
sh "$HERE/../scripts/write-part.sh" "$T" 2.0a3
[ "$(grep -c '^copy' "$T/Part")" = 4 ] || { echo "FAIL: second run lists the Part file"; fail=1; }
[ $fail = 0 ] && echo "Part file: all checks passed"
exit $fail
