#!/bin/bash
if [ -e   $PWD/submissions ] 
then
mkdir $PWD/submissions
fi
./directorize.pl \
   $1 \
   $PWD/submissions


