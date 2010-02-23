#!/bin/bash
if [ $# -ne 1 ]
then
  echo "Usage: dist.sh <path to project which depends on library> \nExample:dist.sh ~/Projects/MyProject"
  exit -1
fi

dst="$1"
src=`pwd`
pushd . > /dev/null
cd "$dst"
rm -rf libcommon
ln -s "$src/Classes" libcommon
popd  > /dev/null
