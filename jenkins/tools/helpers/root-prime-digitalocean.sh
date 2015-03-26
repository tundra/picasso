#!/bin/bash

set -x -e

if [[ $EUID -ne 0 ]]; then
  echo "Must be run by root"
  exit 1
fi

PACKAGES="""
ufw
git
"""

# Install required packages.
sudo apt-get update
for PACKAGE in $PACKAGES; do
  sudo apt-get install -y $PACKAGE
done

# Create and configure the picasso user.
if ! id -u picasso > /dev/null 2>&1; then
  echo Use a strong password
  adduser picasso
  gpasswd -a picasso sudo

  # Set up ssh keys.
  su picasso -c "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
  su picasso -c "touch ~/.ssh/authorized_keys"
  cat ~/.ssh/authorized_keys > ~picasso/.ssh/authorized_keys
  su picasso -c "chmod 644 ~/.ssh/authorized_keys"
fi

# Usage: replace_line (file) (from) (to). Replaces the given from-line with the
# to-line in the given file. If the to-line is already present does nothing. If
# not, the from-line must be present or the call will fail.
function replace_line {
  FILE="$1"
  FROM="$2"
  TO="$3"
  echo "Replacing line [$FROM] to [$TO] in $FILE"
  if grep "$TO" $FILE > /dev/null; then
    echo "Line [$TO] is already present in $FILE"
  else
    grep "$FROM" $FILE > /dev/null
    echo "From line found; doing replacement"
    sed -i "s/$FROM/$TO/g" $FILE
  fi
}

# Change ssh configuration
replace_line /etc/ssh/sshd_config "Port 22" "Port 374"
replace_line /etc/ssh/sshd_config "PermitRootLogin yes" "PermitRootLogin no"
service ssh restart

ufw allow 374/tcp
ufw default deny incoming
ufw enable
ufw status
