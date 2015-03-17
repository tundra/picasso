#!/bin/bash

set -v -e

if [[ $EUID -ne 0 ]]; then
  echo "Must be run by root"
  exit 1
fi

# Grab the key from stdin immediately so the following commands don't mess with
# it.
TMPKEY=/tmp/key.pub
cat > $TMPKEY

# Create .ssh if it doesn't exist.
DSSH=~jenkins/.ssh
if [ ! -d "$DSSH" ]; then
  mkdir -p $DSSH
  chown jenkins $DSSH
fi

# Ditto authorized_keys
AUTHS=$DSSH/authorized_keys
if [ ! -f "$AUTHS" ]; then
  touch $AUTHS
  chown jenkins $AUTHS
  chmod 644 $AUTHS
fi

# Look for the key already being in the list before adding it.
if ! grep -f $TMPKEY $AUTHS; then
  cat $TMPKEY >> $AUTHS
fi

# Clean up.
rm $TMPKEY
