#!/bin/sh
# Builds Angolmois, the BMS rhythm game player (BM98-like: notes fall to
# the key lanes in time with the chart's key sounds), for GFOS (AmigaOS
# 3.2.3 with GFOpenUp) with a stove: a 68040 or 68060 with its FPU, shown,
# heard and played through GFOpenGPU's SDL 2 (the stove's SDL2, SDL2_mixer
# and SDL2_image link stubs; SDL2.module at run time), hard float as that
# kit is. MPEG background movies are left out (amiga/compat/smpeg.h).
#   STOVE=.../stoves/os32-gcc16-open6 OUT=out ./build-amiga.sh
# Angolmois is fetched at the commit angolmois.lock gives; nothing
# third-party is kept here. The PC tests (tests/host-ag.sh: upstream's test
# charts played to the end in autoplay and exclusive modes, and the Part
# file test) run first when the PC has a compiler, SDL 2 with SDL2_mixer
# and SDL2_image, and xvfb-run; HOST_TESTS=0 skips them.
# OUT gets Parts/Angolmois: a GFOpenUp part (its Part file and the drawer it
# puts in SYS:Games/Angolmois; it needs the GFOpenGPU part), installed with
#   GFOpenUpTool INSTALL Parts/Angolmois
# MIT, Copyright (c) 2026 AmiCradle Team.
set -eu
HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$HERE/angolmois.lock"
. "$HERE/scripts/ag-common.sh"
STOVE=${STOVE:-"$HOME/AmiCradle/stoves/os32-gcc16-open6"}
# outside the checkout: Cradle cleans it (git clean -ffdx) before every job
WORK="${WORK:-$HOME/.cache/amigaangolmois/build}"; OUT="${OUT:-$WORK/out}"
# the PC tests run on the PC's own PATH: the stove has an sdl2-config too (GFOS's)
HOST_PATH=$PATH
TC="$STOVE/prefix"; PATH="$TC/bin:$PATH"; export PATH
mkdir -p "$WORK" "$OUT"; OUT=$(cd "$OUT" && pwd)
t0=$(date +%s)

# --- the PC tests first -----------------------------------------------------------
if [ "${HOST_TESTS:-1}" != 0 ] && (PATH=$HOST_PATH; command -v "${HOST_CC:-cc}") > /dev/null 2>&1; then
    rc=0; PATH=$HOST_PATH WORK="$WORK/host" sh "$HERE/tests/host-ag.sh" > "$WORK/host-tests.log" 2>&1 || rc=$?
    case $rc in
        0) grep -E "checks passed" "$WORK/host-tests.log" ;;
        2) echo "PC tests skipped: $(tail -1 "$WORK/host-tests.log")" ;;
        *) tail -30 "$WORK/host-tests.log"; exit 1 ;;
    esac
fi

# --- SDL 2, SDL2_mixer and SDL2_image from the stove's SDK -------------------------
SDK="$TC/m68k-amigaos"
for f in include/SDL2/SDL.h include/SDL2/SDL_mixer.h include/SDL2/SDL_image.h \
         lib/libSDL2.a lib/libSDL2_mixer.a lib/libSDL2_image.a; do
    [ -f "$SDK/$f" ] || { echo "the stove has no $f"; exit 2; }
done

# --- Angolmois at its pinned commit, patches/ ----------------------------------------
SRC="$WORK/src"
ag_source "$SRC"
S="$SRC/angolmois"

# --- compile and link ------------------------------------------------------------------
LATE=""
if m68k-amigaos-gcc -fno-late-combine-instructions -S -o /dev/null -x c /dev/null 2>/dev/null; then LATE="-fno-late-combine-instructions"; fi
CPU="-m68040 -m68881"
# no loops turned into memset/memcpy calls (GCC 16), address 0 is memory
CF="-noixemul $CPU -O2 -fomit-frame-pointer -fno-tree-loop-distribute-patterns -fno-delete-null-pointer-checks $LATE \
 -std=gnu99 -Werror=implicit-function-declaration -I$HERE/amiga/compat -I$SDK/include/SDL2"
O="$WORK/obj"; rm -rf "$O"; mkdir -p "$O"
m68k-amigaos-gcc $CF -Dmain=ag_game_main -c "$S/angolmois.c" -o "$O/angolmois.o" > "$O/cc.log" 2>&1 \
    || { grep -E 'error' "$O/cc.log" | sed 's#^.*/##' | head -60; exit 1; }
m68k-amigaos-gcc $CF -Wall -DAG_VERSION="\"$AG_VERSION\"" -DAG_DATE="\"$(date -u +%d.%m.%Y)\"" \
    -c "$HERE/amiga/amiga_start.c" -o "$O/amiga_start.o"
echo "compile: $(( $(date +%s) - t0 )) s"
# -lpthread: the stove's libgcc and SDL 2 build on its pthreads
m68k-amigaos-gcc -noixemul $CPU -o "$O/Angolmois.debug" "$O/angolmois.o" "$O/amiga_start.o" \
    -L"$SDK/lib" -lSDL2_mixer -lSDL2_image -lSDL2 -lm -lpthread > "$O/link.log" 2>&1 \
    || { grep -E 'undefined|error' "$O/link.log" | sed 's#^.*/##' | sort | uniq -c | sort -rn | head -60; exit 1; }

# --- the GFOpenUp part: Parts/Angolmois ---------------------------------------------
P="$OUT/Parts/Angolmois"; D="$P/Games/Angolmois"; rm -rf "$P"; mkdir -p "$D/Examples"
m68k-amigaos-strip -o "$D/Angolmois" "$O/Angolmois.debug"
cp "$HERE/README.md" "$D/ReadMe"
cp "$S/README.md" "$D/ReadMe.upstream"
cp "$S"/test/* "$D/Examples/"
sh "$HERE/scripts/write-part.sh" "$P" "$AG_VERSION"
ls -l "$D/Angolmois"
echo "part: $(grep -c '^copy' "$P/Part") files, $(du -sk "$P" | cut -f1) KB"
echo "total: $(( $(date +%s) - t0 )) s"
