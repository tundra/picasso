#!/bin/bash

set -x -e

# Sudo anything
sudo true

# Check if the line is already in the sudoers file.
NOPASSWD="vagrant ALL=(ALL) NOPASSWD: ALL"
set +e
sudo grep "$NOPASSWD" /etc/sudoers > /dev/null
CODE=$?
set -e

# If not, add it. This isn't completely safe but, seriously, my life is too
# short to write a complete non-interactive visudo tool. Who creates a tool that
# only has an interactive flavor?!?
if [ $CODE -ne 0 ] ; then
  NEW_SUDOERS=/tmp/sudoers.new
  sudo cp /etc/sudoers $NEW_SUDOERS
  sudo sh -c "echo \"$NOPASSWD\" >> $NEW_SUDOERS"
  if sudo visudo -c -f $NEW_SUDOERS; then
    sudo cp $NEW_SUDOERS /etc/sudoers
    sudo rm $NEW_SUDOERS
  fi
fi

# These are just the packages we need to make the base box. We'll install the
# rest later.
PACKAGES="""
linux-headers-generic
build-essential
dkms
virtualbox-guest-dkms
virtualbox-guest-utils
"""

sudo apt-get update
# Install required packages.
for PACKAGE in $PACKAGES; do
  sudo apt-get install -y $PACKAGE
done
