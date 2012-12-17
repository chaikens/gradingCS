
all: Album.class javaTests/TesterBase.class

Album.class : Album.java
	javac Album.java

javaTests/TesterBase.class : javaTests/TesterBase.java Album.class
	(cd javaTests;	./compileTester.cmd .)
