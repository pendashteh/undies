#!/usr/bin/env bash

cd $(dirname $BASH_SOURCE)
for project in $(ls); do
  if [ -f $project/$project ]; then
    source $project/$project
  fi
done
