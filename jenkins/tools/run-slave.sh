#!/bin/bash

set -e

cd /home/vagrant

# Start the slave agent.
java                                                                           \
  -jar slave.jar                                                               \
  $(cat jenkins-flags.txt)
