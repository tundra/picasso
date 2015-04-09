#!/bin/bash

# Utility for applying the same command to all the vms.

set -e

VAGRANT="$(dirname $(dirname $0))"

VMS="""
linux/ubuntu-14.04.2-server-i386
linux/ubuntu-14.04.2-server-amd64
windows/windows7-professional-x86
windows/windows7-professional-x64
"""

# Runs vagrant with the raw arguments on each vm.
function delegate_command {
  for VM in $VMS; do
    VM_ROOT="$VAGRANT/$VM"
    echo "[$VM] vagrant $*"
    VAGRANT_CWD="$VM_ROOT" vagrant "$*"
  done
}

# Main dispatch.
function main {
  case "$1" in
    *)
      delegate_command "$*"
      ;;
  esac
}

main "$*"
