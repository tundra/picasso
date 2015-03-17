#!/bin/bash

# Print commands; fail on errors.
set -v -e

# Apt-get dependencies.
apt-get update
apt-get install -y git
apt-get install -y make
apt-get install -y python-setuptools
apt-get install -y jenkins-slave
apt-get install -y python-pip

# Set up python
pip install virtualenv

# Set things up for jenkins.
mkdir -p /var/jenkins
chown vagrant /var/jenkins
