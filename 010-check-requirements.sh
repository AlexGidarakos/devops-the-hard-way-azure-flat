#!/usr/bin/env bash

REQUIREMENTS="az terraform docker kubelogin kubectl"

for i in $REQUIREMENTS
do
  which $i > /dev/null && echo $i found || echo $i not found in PATH
done

echo
echo If any requirements were not met, please install and/or add them to the PATH variable
