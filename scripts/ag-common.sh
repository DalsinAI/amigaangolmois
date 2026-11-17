# What build-amiga.sh (the stove) and tests/host-ag.sh (the PC) share:
# fetching Angolmois at angolmois.lock's commit with patches/ applied.
# Sourced; needs HERE (the repo) and angolmois.lock's settings.
# MIT, Copyright (c) 2026 AmiCradle Team.

# a repository at one commit, fetched once: fetch_at DIR URL COMMIT
fetch_at() {
    if [ "$(git -C "$1" rev-parse HEAD 2>/dev/null)" != "$3" ]; then
        rm -rf "${1:?}"; mkdir -p "$1"
        git -C "$1" init -q
        git -C "$1" fetch -q --depth 1 "$2" "$3"
        git -C "$1" checkout -q FETCH_HEAD
        [ "$(git -C "$1" rev-parse HEAD)" = "$3" ] || { echo "$1: commit mismatch"; exit 1; }
    fi
}

# Angolmois with patches/ applied, into $1/angolmois (redone when anything changes)
ag_source() {
    PSUM=$( (cat "$HERE"/patches/*.patch; echo "$AG_COMMIT") | sha256sum | cut -c1-16)
    if [ "$(cat "$1/.patched" 2>/dev/null)" != "$PSUM" ]; then
        rm -rf "$1/angolmois"; mkdir -p "$1/angolmois"
        fetch_at "$1/.dl/angolmois" "$AG_GIT" "$AG_COMMIT"
        (cd "$1/.dl/angolmois" && git archive HEAD) | tar -x -C "$1/angolmois"
        for p in "$HERE"/patches/*.patch; do
            patch -s -d "$1/angolmois" -p1 < "$p" || { echo "patch failed: $p"; exit 1; }
        done
        echo "$PSUM" > "$1/.patched"
    fi
}
