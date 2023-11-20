#!/usr/bin/env bash


if [ "$1" == "run" ]; then
  v run src/ $2 $3
else
  v src -o ot
fi