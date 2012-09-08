#!/usr/bin/perl -w
opendir THISDIR, "." or die "serious failure: $!";
@allfiles = readdir THISDIR;
closedir THISDIR;
@classesWmain = ();
foreach $fn (@allfiles)
{
    if($fn =~ /^.+\.class$/)
    {
	$fn =~ s/\.class$//;
	$javaps = `javap $fn`;
	if($javaps =~ /public static void main/)
	{
	    @classesWmain = (@classesWmain, $fn);
	}
    }
}
$nMains = @classesWmain + 0;
if($nMains==0)
{
    print "NO main class!\n";
}
elsif($nMains!=1)
{
    print "$nMains classes with main!!\n";
}
else
{
    exec "java $classesWmain[0]";
}



