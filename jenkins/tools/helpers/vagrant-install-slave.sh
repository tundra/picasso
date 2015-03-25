#!/bin/bash

set -x -e

cd /home/vagrant

# These are just the packages we need to make the base box. We'll install the
# rest later.
PACKAGES="""
git
default-jre
runit
"""

# Install required packages.
for PACKAGE in $PACKAGES; do
  sudo apt-get install -y $PACKAGE
done

# Fetch the slave jar if it's not here already.
if [ ! -f slave.jar ]; then
  wget http://ci.t.undra.org/jnlpJars/slave.jar
fi

# Fetch picasso
if [ ! -d picasso ]; then
  git clone http://github.com/tundra/picasso
fi

# Install as runit service.
JENKINS_SV=/etc/service/jenkins
if [ ! -d $JENKINS_SV ]; then
  HELPERS=/home/vagrant/picasso/jenkins/tools/helpers
  sudo mkdir -p $JENKINS_SV/log
  sudo ln -s $HELPERS/sv-run-slave.sh $JENKINS_SV/run
  sudo ln -s $HELPERS/sv-log-slave.sh $JENKINS_SV/log/run
fi
