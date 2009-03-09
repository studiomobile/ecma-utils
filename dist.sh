#!/bin/bash
if [ $# -ne 1 ]
then
  echo "Usage: makedist.sh <path to project which depends on library> \nExample:makedist.sh ~/Projects/MyProject"
  exit -1
fi

dst="$1"
src=`pwd`
pushd .
cd "$dst"
rm -r libcommon
ln -s "$src/Classes" libcommon
popd