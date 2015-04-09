#!/bin/sh

TOOLS="$(dirname $0)"

$TOOLS/foreach.sh up > /tmp/picasso.out 2> /tmp/picasso.err 
