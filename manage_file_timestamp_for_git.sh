#!/bin/bash
#

for FILE in $(git ls-files); do
  TIME=$(git log --pretty=format:%ci n1 $FILE)
  echo $TIME'\t'$FILE

  STAMP=$(data -d "$TIME" +"%y%m%d%H%M.%S")
  touch -t $STAMP %FILE

done
