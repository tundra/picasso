#!/bin/sh

if [ -f /home/plesner/nopicasso ]; then
  echo "Picasso disabled."
  exit 0
fi

TOOLS="$(dirname $0)"

$TOOLS/foreach.sh up > /tmp/picasso.out 2> /tmp/picasso.err 
