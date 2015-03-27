#!/bin/bash

BOX=

while [ $# -gt 0 ]; do
  case "$1" in
    --box)
      BOX="$2"
      shift 2
      ;;
    *)
      die "Unknown option $1"
      ;;
  esac
done

check_user picasso
check_set --box "$BOX"

# Create the keys dir if it doesn't already exist.
if [ ! -d keys ]; then
  mkdir keys
  mv rsync_id_rsa keys/
  mv vagrant_id_rsa keys/
fi

# Remove the dropped key in any case, whether we used it or not.
rm -f rsync_id_rsa vagrant_id_rsa

mkdir -p boxes

# Fetch the box file from rsync.net if we don't already have it.
BOX_FILE=boxes/$BOX
if [ ! -f $BOX_FILE ]; then
  scp -i keys/rsync_id_rsa $RSYNC_HOST:boxes/$BOX $BOX_FILE
fi

# Install dependencies
apt_install --sudo """
vagrant
"""

# Check out the picasso code base.
if [ ! -d picasso ]; then
  git clone http://github.com/tundra/picasso
fi
