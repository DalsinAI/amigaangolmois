#!/bin/sh
# Writes the Part file GFOpenUpTool INSTALL reads (gfopenup src/openuptool.c):
# one "copy" line per file under the part drawer, each to SYS:<its path>.
# It needs the GFOpenGPU part, whose SDL2.module shows the game, plays the
# key sounds and reads the keys.
#   write-part.sh <part drawer> <version>
# MIT, Copyright (c) 2026 AmiCradle Team.
set -eu
P=$1; V=$2
{
    echo "part Angolmois $V"
    echo "; Angolmois: a BMS rhythm game player (BM98-like); bring your own BMS songs"
    echo "needs 68040"
    echo "needs part GFOpenGPU"
    (cd "$P" && find Games -type f ! -name Part | LC_ALL=C sort) | while read -r f; do
        echo "copy \"$f\" \"SYS:$f\""
    done
} > "$P/Part"
