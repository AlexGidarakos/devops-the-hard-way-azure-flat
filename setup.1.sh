#!/usr/bin/env bash
source setup.inc
NOTFOUND=0

for i in $REQUIREMENTS; do
  which $i > /dev/null && echo "$i found" || { echo "$i not found in PATH"; NOTFOUND=1; }
done

((NOTFOUND)) && echo -e "Please install and/or add unmet requirements to the PATH variable and try again"

exit $NOTFOUND
