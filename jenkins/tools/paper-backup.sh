#!/bin/sh

# Utility for chopping a file into chunks of a certain number of lines and
# encoding each chunk as a qr code. For storing private keys on paper.

set -e

KEYIN=$1
OUTFMT=key-%i.png
CHUNKSIZE=12

LINES=$(cat $KEYIN | wc -l)
BLOCK=0
for CUT in $(seq 1 $CHUNKSIZE $LINES); do
  IMGOUT=$(printf $OUTFMT $BLOCK)
  echo Writing $IMGOUT
  cat $KEYIN | tail -n +$CUT | head -$CHUNKSIZE | qrencode -l L -8 -o $IMGOUT
  BLOCK=$((BLOCK+1))
done
