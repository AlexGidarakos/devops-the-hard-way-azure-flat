#!/usr/bin/env bash

source setup.inc

# Check for required binaries
NOTFOUND=0
for i in $REQUIREMENTS;
do
  which $i > /dev/null

  if [[ $? -eq 0 ]]; then
    echo "$i found"
  else
    echo "$i not found in PATH"; NOTFOUND=1
  fi
done
((NOTFOUND)) && echo -e "Please install and/or add unmet requirements to the PATH variable and try again" && exit 1
