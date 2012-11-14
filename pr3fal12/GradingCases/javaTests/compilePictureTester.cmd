#!/bin/bash
cp ../Picture.class .
CLASSPATH=.:$CLASSPATH
javac PictureTester.java 
rm Picture.class

