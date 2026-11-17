# Angolmois for GFOS

Angolmois is a small BMS player: a rhythm game in the BM98 style, where
notes fall down key lanes and you press each key as its note reaches the
bottom, in time with the chart's key sounds. It plays BMS, BME, BML and PMS
charts with long notes, BPM changes and background images. Hits are graded
COOL, GREAT, GOOD, BAD or MISS, and a gauge fills as you keep a combo. You
clear the song when the gauge ends above the line.

This repository builds it for GFOS (AmigaOS 3.2.3 with GFOpenUp) as a
GFOpenUp part. Nothing third-party is kept here: the build fetches Angolmois
at the commit `angolmois.lock` names and applies `patches/`.

## Playing

Install the part, then start a chart from the Shell:

    SYS:Games/Angolmois/Angolmois -w Songs:MySong/hyper.bme

It needs a 68040 or 68060 with its FPU and the GFOpenGPU part, which shows
the game, plays the sounds and reads the keys through SDL 2. BMS songs are
not included; there are many free ones. `Examples/` holds upstream's four
short test charts and their sounds.

Useful options (`-h` lists them all):

| Option | What it does |
| --- | --- |
| `-w` | In a window rather than full screen |
| `-v` | Autoplay: watch the game play the chart |
| `-x` | Exclusive mode: a small window and the sound only |
| `-1` to `-9`, `-a N` | Play speed (F3 and F4 change it while playing) |
| `-m`, `-s`, `-r` | Mirror, shuffle or random lanes |
| `-B`, `-M` | No background images, no movies |

Esc stops the song. At the end the game prints your grades and score to the
Shell.

## What is changed for GFOS

* `0001-cwd-by-name.patch`: sound and image files are found by going into
  their drawer and back by the drawer's name (`getcwd`, `chdir`), as
  AmigaOS has no `fchdir`. This applies on every platform.
* `0002-amiga-volume-paths.patch`: a chart given as `DH0:song.bms` has its
  files in `DH0:`, with the colon kept.
* `amiga/compat/smpeg.h`: no MPEG background movies. A chart's `.mpg` is
  reported as not loaded and the song plays with its still images.
  SMPEG is not part of GFOpenGPU's SDL 2 kit.
* `amiga/amiga_start.c`: the stack (256 KB) and the `$VER` string.

## Building

    STOVE=.../stoves/os32-gcc16-open6 OUT=out ./build-amiga.sh

The output is `out/Parts/Angolmois` (the Part file, the program, the
examples and both read-mes), installed with

    GFOpenUpTool INSTALL Parts/Angolmois

## Tests

`tests/host-ag.sh` builds the same patched source with the same SMPEG
stand-in on the PC. It plays each of upstream's test charts to the end in
autoplay (`-v`) and exclusive (`-x`) modes, in a window on a virtual X
display, and checks that each run ends cleanly and that a missing chart is
refused. Then it runs the Part file test (`tests/test-part.sh`).
`build-amiga.sh` runs them first when the PC has what they need.

## Licences

Angolmois is GPL-2 or later (Kang Seonghoon, after Choi Kaya's original
Angolmois; see `ReadMe.upstream` and the source). The scripts, tests and
start code here are MIT, Copyright (c) 2026 AmiCradle Team.

Designed, tested and delivered by The AmiCradle Team.
