#!/bin/bash
if [ ! -d $1 ]
then
echo $1 must be a directory
exit
fi

cp ../Album.class $1
cd $1
CLASSPATH=.:..:$CLASSPATH
javac *.java 
rm Album.class

