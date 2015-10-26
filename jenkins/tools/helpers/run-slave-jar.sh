#!/bin/bash

set -e

cd /home/vagrant

# Set up the build environment.
export LIBRARY_CONTAINER=/storage/libraries/

# Start the slave agent.
java                                                                           \
  -jar slave.jar                                                               \
  $(cat jenkins-flags.txt)
