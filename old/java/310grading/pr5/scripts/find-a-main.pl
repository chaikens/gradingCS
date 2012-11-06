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
print "@classesWmain\n";



