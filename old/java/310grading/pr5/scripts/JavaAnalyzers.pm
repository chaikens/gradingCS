#!/usr/bin/perl -w

package JavaAnalyzers;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(findMainClassInteractively doesSignatureExistInClass);

use Cwd ('chdir', 'cwd') ;

my $verbose = 0;


sub doesSignatureExistInClass($$$)
{
    my $dir = $_[0];
    my $signature = $_[1];
    my $className = $_[2];

    my $saveDir = cwd();

    if( ! defined $dir || ! defined $signature || ! defined $className)
    {
	print "findMainClassInteractively called with undefined arg.\n";
	return "";
    }
    if ( ! opendir DIR, $dir )
    {
	print "doesSignatureExistInClass couldn't open dir $dir\n";
	return "";
    }
    
    if (! -e "$dir/$className.class")
    {
	print "Class $className.class doesn't exist in $dir.\n";
	return "";
    }

    cwd($dir);
    my $jps = `javap $className`;
    cwd($saveDir);
    if(!($jps =~ /\Q$signature/s))  
    {
	print "$className.java compiled but didn't have 
  $signature\n";
	return "";}
    else { return "1";}
}

sub findMainClassInteractively($)
{
    my $dir = $_[0];
    my $savedir = cwd();
    if( ! defined $dir )
    {
	print "findMainClassInteractively called with undefined arg.\n";
	return "";
    }
    if ( ! opendir DIR, $dir )
    {
	print "findMainClassInteractively couldn't open dir $dir\n";
	return "";
    }
    chdir( $dir );
    my @allfiles = readdir DIR;
    closedir DIR;
    my @classesWmain = ();
    my $fn;
    foreach $fn (@allfiles)
    {
	if($fn =~ /^.+\.class$/)
	{
	    $fn =~ s/\.class$//;
	    my $javaps = `javap $fn`;
	    if($javaps =~ /public static void main/)
	    {
		@classesWmain = (@classesWmain, $fn);
	    }
	}
    }
    my $nMains = @classesWmain + 0;
    if($nMains == 1)
    {
	chdir( $savedir );
	return $classesWmain[0];
    }
    if($nMains == 0)
    {
	print "No main class found in $dir\n";
    }
    else
    {
	print "Multiple main classes found:";
        my $x;
	foreach $x  (@classesWmain)
	{
	    print "$x ";
	}
	print "\n";
    }
    my $ans;
    while ( 1 )
    {
	print 
"TA: Identify or build main class in \n$dir\n"; 
	print 
"TA: Then, type in nothing if you failed or the name,\n then enter:";

	chomp($ans = <STDIN>);
	if( $ans eq "") { last; }
	$ans =~ s/.*\.class//;
	if( -f "$ans.class" ) { last; }
	print `ls -l`;
	print "TA: No $ans.class found in $dir! Try again!\n";
    }
    chdir( $savedir );
    return $ans;
}

1;

#Unit tests:
#print findMainClassInteractively( $ARGV[0] );

