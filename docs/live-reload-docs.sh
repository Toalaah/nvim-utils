#!/usr/bin/env nix-shell
#! nix-shell -i bash -p entr nixdoc mdbook
# vim:ft=sh

cd "$(dirname "$0")" || exit 1
lib="$(realpath "$(dirname "$0")/../lib")"
export lib

_exit() {
  [ -n "$child" ] && kill "$child"
  echo "=> Exiting..."
  exit 0
}

_build_site() {
  find "$lib" -maxdepth 1 -name '*.nix' -exec bash -c \
    'base=$(basename $0 .nix);
     out="./src/$base.md";
     nixdoc --category "$base" --description "Nvim-Utils" --file "$0" \
       | sed -z "s/\`\n\n:/\`/g" | sed "/:::/d" > "$out"' {} \;
}

_rebuild() {
  echo "=> Rebuilding..."
  _build_site
}

export -f _rebuild _build_site

echo "=> Building initial site..."
_build_site

mdbook serve &
child=$!
trap _exit SIGINT
while sleep 1; do
  find "$lib" -name '*.nix' | entr -rz -p -d -s _rebuild
done
