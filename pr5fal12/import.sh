#!/bin/bash

GR_GROUP="grade201"

if [ -e   $PWD/submissions ] 
then
mkdir -m 770 $PWD/submissions
chgrp $GR_GROUP $PWD/submissions
fi

./directorize.pl \
   $1 \
   $PWD/submissions


