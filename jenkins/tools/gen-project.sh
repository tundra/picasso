#!/bin/bash

. $(dirname $0)/helpers/common.sh

JOBS=
PROJECT=

while [ $# -gt 0 ]; do
  case "$1" in
    --jobs)
      JOBS="$2"
      shift 2
      ;;
    --project)
      PROJECT="$2"
      shift 2
      ;;
    *)
      die "Unknown option $1"
      ;;
  esac
done

check_set --jobs "$JOBS"
check_set --project "$PROJECT"

for FLAVOR in commit pulls; do
  sed "s|tclib|$PROJECT|g" $JOBS/tclib-$FLAVOR/config.xml > $JOBS/$PROJECT-$FLAVOR/config.xml
done
