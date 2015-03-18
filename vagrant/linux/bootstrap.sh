#!/bin/bash

# Print commands; fail on errors.
set -v -e

PACKAGES="
git
make
python-setuptools
python-pip
g++
default-jre
"""

# Apt-get dependencies.
apt-get update
for PACKAGE in $PACKAGES; do
  apt-get install -y $PACKAGE
done

# Set up python
pip install virtualenv

# Set things up for jenkins.
mkdir -p /var/lib/jenkins
chown vagrant /var/lib/jenkins
