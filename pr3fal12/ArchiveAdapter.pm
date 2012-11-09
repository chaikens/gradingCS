#!/usr/bin/perl -w

package ArchiveAdapter;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(returnDirectoryToGradeFromSubmission);



use Cwd; #for cwd() function

sub escapeEmbeddedUglyChars($)
{
    my $fileName = $_[0];
    $fileName =~ s/\ /\\\ /g;  #Escape-sequence stupid embedded spaces.
    $fileName =~ s/\(/\\\(/g;  #Escape-sequence stupid embedded ( HA!!
    $fileName =~ s/\)/\\\)/g;  #Escape-sequence stupid embedded  )HA!!
    return $fileName;
}


sub expandAnArchive($)
{
    my $archiveFile = escapeEmbeddedUglyChars($_[0]);
 

    if( $archiveFile =~ /.+\.zip/ )
    {
	my $cmd = "unzip -d " . cwd() . " $archiveFile";
	`$cmd`;
	return 1;
    }
    elsif( $archiveFile =~ /.+\.7z/ )
    {
	my $cmd = "cd " . cwd() . ";7z e  $archiveFile";
	`$cmd`;
	return 1;

    }
    elsif( $archiveFile =~ /.+\.rar/ )
    {
	my $cmd = "cd " . cwd() . ";unrar e  $archiveFile";
	`$cmd`;
	return 1;

    }
    elsif( $archiveFile =~ /.+\.tar/ )
    {
	my $cmd = "cd " . cwd() . ";tar xf  $archiveFile";
	`$cmd`;
	return 1;

    }
    elsif( ($archiveFile =~ /.+\.tgz/ ) || ($archiveFile =~ /.+\.tar\.gz/) )
    {
	return 0;
    }
    return 0;
}

sub findArchiveList($)
{
    my $SubmissionPathname = $_[0];
    #We are in the Submission directory..

    my @ary = `ls *`;
    my $n = @ary;
    while( $n > 0 )
    {
	if( $ary[$n-1] =~ /\.(zip|rar|7z|tar)/ )
	{
	    return ($ary[$n-1]);
	}
	$n = $n - 1;
    }
    return 0;
}
	    

sub returnDirectoryToGradeFromSubmission($)
{
    my $SubmissionPathname = $_[0];
    print "ArchiveAdapter: SubmissionPathname=$SubmissionPathname\n\n";
    chdir($SubmissionPathname);
    my @ArchiveList = findArchiveList($SubmissionPathname);
    print "ArchiveAdapter: ArchiveList[0]=$ArchiveList[0]\n\n";
    my $nArchives = 0 + @ArchiveList;
    if( $nArchives == 1 )
    {
	expandAnArchive($ArchiveList[0]);
	print `find `;
	print "\n\nEnter the Version Dir. to grade:\n";
	my $dirFromTA;
	chop($dirFromTA=<STDIN>);
	chdir($dirFromTA);
	return cwd();
    }
    else
    {
	my $Mess = "Number of archives found=$nArchives";
	if( $nArchives == 0 )
	{
	    return "";
	}
	else
	{
	    return "";
	}
    }
}
