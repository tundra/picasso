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
  UPDATE="apt-get update"
  COMMAND="apt-get install -y"
  while true;
    do case "$1" in
      --sudo) UPDATE="sudo $UPDATE"; COMMAND="sudo $COMMAND"; shift 1;;
      *) break
    esac
  done
  # Do the installation.
  $UPDATE
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
# not, the from-line must be present or the call will fail. Pass --sudo as the
# first argument to do this under sudo.
function replace_line {
  SUDO_OPT=""
  while true;
    do case "$1" in
      --sudo) SUDO_OPT="sudo"; shift 1;;
      *) break
    esac
  done
  FILE="$1"
  FROM="$2"
  TO="$3"
  if ! $SUDO_OPT sh -c "grep \"$TO\" $FILE > /dev/null"; then
    $SUDO_OPT grep "$FROM" $FILE
    echo "From line found; doing replacement"
    $SUDO_OPT sed -i "s|$FROM|$TO|g" $FILE
  fi
}

# Executes the given string as root. This is useful for cases where sudoing
# directly doesn't work, for instance when there are pipes and redirections.
function as_root {
  sudo sh -c "$*"
}

# Usage: asuser (user) (command ...) Runs the command as the given user.
function as_user {
  TARGET=$1
  shift 1
  sudo su $TARGET -c "$*"
}

# Print an error message and kill the script.
function die {
  echo $1 >&2
  exit 1
}
