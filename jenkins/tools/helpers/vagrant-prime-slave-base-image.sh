#!/bin/bash

set -x -e

SECRET=
SLAVE_ID=

while getopts ":-:" OPTCHAR; do
  case "$OPTCHAR" in
    -)
      case "$OPTARG" in
        id)
          SLAVE_ID="${!OPTIND}"
          OPTIND=$(($OPTIND + 1))
          ;;
        secret)
          SECRET="${!OPTIND}"
          OPTIND=$(($OPTIND + 1))
          ;;
        *)
          echo "Unknown option --$OPTARG"
          exit 1
          ;;
      esac
      ;;
    *)
      echo "Unknown option -$OPTARG"
      exit 1
      ;;
  esac
done

if [ -z "$SLAVE_ID" ]; then
  echo "No --id specified"
  exit 1
fi

if [ -z "$SECRET" ]; then
  echo "No --secret specified"
  exit 1
fi

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

# Store the jenkins configuration for later use.
echo -jnlpUrl http://ci.t.undra.org/computer/$SLAVE_ID/slave-agent.jnlp -secret $SECRET > jenkins-flags.txt
chmod 600 jenkins-flags.txt

# These are just the packages we need to make the base box. We'll install the
# rest later.
PACKAGES="""
linux-headers-generic
build-essential
dkms
virtualbox-guest-dkms
virtualbox-guest-utils
"""

# Install required packages.
for PACKAGE in $PACKAGES; do
  sudo apt-get install -y $PACKAGE
done
