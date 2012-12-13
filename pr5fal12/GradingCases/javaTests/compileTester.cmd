#!/bin/bash
cp ../Album.class .
CLASSPATH=.:$CLASSPATH
javac Tester.java 
rm Album.class

