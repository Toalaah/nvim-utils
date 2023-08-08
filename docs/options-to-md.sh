#!/bin/sh

[ -z "$1" ] && echo "Usage: $0 <module>" >&2  && exit 1

directory="$(nix-build -E "with import <nixpkgs> {}; callPackage $MDBOOK_ROOT/build-module-docs.nix {}" --no-out-link)"

cat "$directory/$1.md"
