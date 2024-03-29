#!/bin/sh

[ -z "$1" ] && echo "Usage: $0 <file>" >&2  && exit 1

nixdoc --category "${CATEGORY:-unknown}" --description "${DESCRIPTION:-none}" --file "$1" \
  | sed -z 's/`\n\n:/`/g' | sed '/:::/d'
