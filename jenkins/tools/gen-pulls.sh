#!/bin/bash

. $(dirname $0)/helpers/common.sh

JOBS=

while [ $# -gt 0 ]; do
  case "$1" in
    --jobs)
      JOBS="$2"
      shift 2
      ;;
    *)
      die "Unknown option $1"
      ;;
  esac
done

check_set --jobs "$JOBS"

patch $JOBS/tclib-commit/config.xml -o $JOBS/tclib-pulls/config.xml < $BASE/resources/commit-to-pulls.patch
