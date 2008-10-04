#!/bin/bash
if [ $# -ne 1 ]
then
  echo "Usage: makedist.sh <path to project which depends on library> \nExample:makedist.sh ~/Projects/MyProject"
  exit -1
fi

dst="$1/libcommon"
rm -r $dst
mkdir -p "$dst"
cp -r Headers "$dst"
cp -r Classes "$dst"
cp -r common.xcodeproj "$dst"