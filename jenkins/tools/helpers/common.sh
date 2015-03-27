#!/bin/bash

set -x -e

BASE=$(dirname $0)
RSYNC_HOST=17307@ch-s011.rsync.net

# Usage: check_set --flag "$VALUE". Check that the given value is nonempty and
# if not issue an error message that --flag must be specified.
function check_set {
  if [ -z "$2" ]; then
    die "No $1 specified"
  fi
}

# Usage: check_file_exists "$FILE". Check that the file exists or die with an
# error.
function check_file_exists {
  if [ ! -f "$1" ]; then
    die "File $1 doesn't exist."
  fi
}

# Usage: check_user (user). Fails if the current user isn't the given value.
function check_user {
  if [ "$USER" != "$1" ]; then
    echo "User must be $1, is $USER"
    exit 1
  fi
}

# Install a list of packages. Pass --sudo to sudo-install them.
function apt_install {
  # Read flags.
  COMMAND="apt-get install -y"
  while true;
    do case "$1" in
      --sudo) COMMAND="sudo $COMMAND"; shift 1;;
      *) break
    esac
  done
  # Do the installation.
  for PACKAGE in $1; do
    $COMMAND $PACKAGE
  done
}

# Succeeds if the given user exists.
function user_exists {
  id -u $1 > /dev/null 2>&1
}

# Usage: replace_line (file) (from) (to). Replaces the given from-line with the
# to-line in the given file. If the to-line is already present does nothing. If
# not, the from-line must be present or the call will fail.
function replace_line {
  FILE="$1"
  FROM="$2"
  TO="$3"
  if ! grep "$TO" $FILE > /dev/null; then
    grep "$FROM" $FILE
    echo "From line found; doing replacement"
    sed -i "s/$FROM/$TO/g" $FILE
  fi
}

# Print an error message and kill the script.
function die {
  echo $1 >&2
  exit 1
}
