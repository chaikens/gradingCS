#!/usr/bin/perl -w

package SubmissionAdapter;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(getOtherSubmissions
 submissionTime getUserId loadTestCompileDir);

use ArchiveAdapter qw(returnDirectoryToGradeFromSubmission);



use Cwd; #for cwd() function
use Time::Local;
use File::Glob ':glob';

my $verbose = 0;

sub getOtherSubmissions($$)
{
    my $containingDir = $_[0];
    if( ! $containingDir )
    {
	print "getOtherSubmissions called without a containing dir\n";
	return "";
    }

    my $submission = $_[1];
    my $userId = getUserId($submission);
    my $timeString = $submission;
    $timeString =~ s/^.+\.//; #remove everything at first . and before.
    my $saveCwd = cwd();
    chdir($containingDir);
    my $others = "";
    foreach $name (<$userId.*>)
    {
	if( $name !~ /\Q$timeString/ )
	{
	    $others = "$others $name";
	}
    }
    chdir($saveCwd);
    return $others;
}

sub submissionTime($)
{
    my $dirName = $_[0];
    $dirName =~ s|.*/||;
    #student.2012-03-03-04-57-02
    $dirName =~ /(\d+)-(\d+)-(\d+)-(\d+)-(\d+)-(\d+)/;
    my $monthsPastJan = $2 - 1;
    return Time::Local::timelocal($6,$5,$4,$3,$monthsPastJan,$1);
}


sub getUserId($)
{
    my $dirName = $_[0];
    $dirName =~ s|.*/||;
    $dirName =~ s|\.[\d\-]+||;
    #student.2012-03-03-04-57-02
    return( $dirName );
}

#UNIT TESTS
#print submissionTime("/sda15/GIT/gradingCS/old/Spr07pr7/submissions/student.2012-03-03-04-57-02");
#print "\n";
#print getUserId("/sda15/GIT/gradingCS/old/Spr07pr7/submissions/student.2012-03-03-04-57-02");
#print "\n";

sub loadTestCompileDir($$)
{
    my $TestCompileDir = $_[0];
    my $submissionPath = $_[1];

    unless( -d $TestCompileDir )
    {
	mkdir($TestCompileDir,0700) || die( "Cannot mkdir $TestCompileDir\n" );
	# mode 0700 begins with 0 to tell perl it is in octal
    }

    if ( $verbose ) { print "run rm -rf $TestCompileDir/*\n"; }
    !system("rm -rf $TestCompileDir/*")||die("Cannot clear $TestCompileDir\n");
    # r for delete subdirs too, since some people submit them
    # f to suppress error message when the dir is empty

    if( $verbose ) { print "loadTestCompileDir working on $_[0]\n"; }

    my( $command ) = "cp -r $submissionPath/* $TestCompileDir";
    if( $verbose ) {print "$command \n";}

    system($command );

    $command = "(cd $TestCompileDir; find . -name '*' -print)";
    my $FilesReceived = `$command`;
    $FilesReceived =~ s/\.\s+//;
    print "We received the following files:\n";
    print "$FilesReceived";

    my $dirToGrade = returnDirectoryToGradeFromSubmission($TestCompileDir);

    $command = "(cd $dirToGrade; find . -name '*' -print)";
    $FilesReceived = `$command`;
    $FilesReceived =~ s/\.\s+//;
    print "From the version we are grading, 
we received the following files:\n";
    print "$FilesReceived";

    my @FilesReceivedL = split /\s+/, $FilesReceived;
    return ($dirToGrade,$FilesReceived, @FilesReceivedL);

}


#my ($scalar, @array) =
#loadTestCompileDir("/tmp/SubmissionAdapterTesting", "/sda15/GIT/gradingCS/old/Spr07pr7/submissions/student.2012-03-03-04-57-02");
#print "scalar ret:";
#print $scalar;
#print "\n\narray ret:";
#print @array;
#print ":\n";

1;
