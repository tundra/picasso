#!/bin/bash

set -e

# Required by the guest additions.
sudo apt-get install linux-headers-generic build-essential dkms

# Install the guest additions.
sudo apt-get install virtualbox-guest-dkms virtualbox-guest-utils
