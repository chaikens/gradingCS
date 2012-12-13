
all: Album.class javaTests/Tester.class

Album.class : Album.java
	javac Album.java

javaTests/Tester.class : javaTests/Tester.java Album.class
	(cd javaTests;	./compileTester.cmd)
