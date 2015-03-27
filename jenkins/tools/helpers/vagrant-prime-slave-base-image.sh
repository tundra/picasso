#!/bin/bash

# Ensure that vagrant can sudo without password. This is a noop if the file
# already exists.
VAGRANT_SUDOERS=/etc/sudoers.d/vagrant-nopasswd
sudo sh -c "echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > $VAGRANT_SUDOERS"

# These are just the packages we need to make the base box. We'll install the
# rest later with install-slave.sh.
apt_install --sudo """
linux-headers-generic
build-essential
dkms
virtualbox-guest-dkms
virtualbox-guest-utils
"""
