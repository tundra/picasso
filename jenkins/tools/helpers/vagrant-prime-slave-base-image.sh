#!/bin/bash

set -e

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

echo "Add [vagrant ALL=(ALL) NOPASSWD: ALL] at the very end of the sudoers"
sudo visudo

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