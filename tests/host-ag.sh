#!/bin/sh
# PC tests: Angolmois built from the same patched source and the same SMPEG
# stand-in (amiga/compat/smpeg.h) as the stove build, on SDL 2's dummy video
# and audio drivers. Each of upstream's test charts (test/: long notes,
# LNTYPE 1, bombs, an invisible-note chart) is played to its end in
# autoplay mode (-v, the game hits every note itself) and in exclusive
# mode (-x, the headless player), and must end cleanly; a missing chart
# must fail. Then the Part file test.
# Exit 2 when the PC lacks what it needs (the reason is the last line).
# MIT, Copyright (c) 2026 AmiCradle Team.
set -eu
HERE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$HERE/angolmois.lock"
. "$HERE/scripts/ag-common.sh"
WORK=${WORK:-$HOME/.cache/amigaangolmois/host}
CC=${HOST_CC:-cc}
command -v "$CC" > /dev/null || { echo "no C compiler"; exit 2; }
command -v sdl2-config > /dev/null || { echo "no SDL 2 (sdl2-config)"; exit 2; }
for m in SDL2_mixer SDL2_image; do
    pkg-config --exists "$m" || { echo "no $m (pkg-config)"; exit 2; }
done
command -v xvfb-run > /dev/null || { echo "no xvfb-run"; exit 2; }
mkdir -p "$WORK"; WORK=$(cd "$WORK" && pwd)
ag_source "$WORK"
S="$WORK/angolmois"
# shellcheck disable=SC2046
"$CC" -O1 -std=gnu99 -Wall -W -Wno-unused-parameter -I"$HERE/amiga/compat" $(sdl2-config --cflags) \
    -o "$WORK/angolmois-pc" "$S/angolmois.c" $(pkg-config --libs SDL2_mixer SDL2_image) $(sdl2-config --libs) -lm
export SDL_AUDIODRIVER=dummy LIBGL_ALWAYS_SOFTWARE=1
run() { xvfb-run -a -s "-screen 0 1024x768x24" "$@"; }
fail=0; n=0
for chart in "$S"/test/*.bms "$S"/test/*.bml; do
    for mode in -v -x; do
        n=$((n + 1))
        if run timeout 120 "$WORK/angolmois-pc" -w -q $mode "$chart" > "$WORK/run.log" 2>&1; then
            echo "ok: $(basename "$chart") $mode"
        else
            echo "FAIL: $(basename "$chart") $mode"; tail -5 "$WORK/run.log"; fail=1
        fi
    done
done
if run "$WORK/angolmois-pc" -w -v "$WORK/no-such-chart.bms" > "$WORK/run.log" 2>&1; then
    echo "FAIL: a missing chart did not fail"; fail=1
else
    grep -q "Couldn't load BMS file" "$WORK/run.log" && echo "ok: a missing chart is refused" \
        || { echo "FAIL: missing chart message"; fail=1; }
fi
[ $fail = 0 ] && echo "charts: $n runs ended cleanly: all checks passed"
[ $fail = 0 ] || exit 1
sh "$HERE/tests/test-part.sh"
