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
	my $cmd = "cd " . cwd() . ";7z x  $archiveFile";
	`$cmd`;
	return 1;

    }
    elsif( $archiveFile =~ /.+\.rar/ )
    {
	my $cmd = "cd " . cwd() . "; ls ; unrar x   $archiveFile";
	if( $ENV{GR_DEBUG} )
	{
	    print "Unrar command: $cmd\n";
	    print "listing before:\n";
	    print cwd() . "\n";
	    print `ls -laR`;
	    print "pausing for input:"; <STDIN>;
	}
	`$cmd`;
	if( $ENV{GR_DEBUG} )
	{
	    print "After Unrar command: $cmd\n";
	    print "listing after:\n";
	    print cwd() . "\n";
	    print `ls -laR`;
	}
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
	    

sub pickRelativeDir()
{
	use Term::ReadLine;
	my $term = Term::ReadLine->new('Revision Directory Reader');
	my $prompt = "Pick revision dir(TAB to see options): ";

	my $Relative_dirFromTA;

	my $done = "";
	while( !$done )
	{
	    $Relative_dirFromTA = $term->readline($prompt);
	    my $confirmPrompt = "You picked dir\n$Relative_dirFromTA\nOK? ENTER if so, x if not:";
	    $done = ! $term->readline($confirmPrompt);
	    if( $done && !$Relative_dirFromTA )
	    {
		print "Are you sure you want to pick the root?\nYou're in\n";
		print cwd(); print "\n";
		$done = 0;

		my $yes = $term->readline("Type yes if so:");
		if( $yes eq "yes" ) 
		{
		    $done = 1;
		    $Relative_dirFromTA = ".";
		}
	    }
	}
	return  $Relative_dirFromTA ;
}



sub returnDirectoryToGradeFromSubmission($)
{
    my $SubmissionPathname = $_[0];
    if( $ENV{"GR_DEBUG"} ) {
	print "ArchiveAdapter: SubmissionPathname=$SubmissionPathname\n\n";}
    chdir($SubmissionPathname);
    my @ArchiveList = findArchiveList($SubmissionPathname);
        if( $ENV{"GR_DEBUG"} ) {
	    print "ArchiveAdapter: ArchiveList[0]=$ArchiveList[0]\n\n";}
    my $nArchives = 0 + @ArchiveList;
    if( $nArchives == 1 )
    {
	expandAnArchive($ArchiveList[0]);

	system 'find . -name \'*.java\' -o -name \'*.class\'';

	my $Relative_dirFromTA = pickRelativeDir();

	my $Relative_dirFromTAEscaped = escapeEmbeddedUglyChars($Relative_dirFromTA);
	chdir($Relative_dirFromTA);
	my $retval = cwd();
	if($ENV{"GR_DEBUG"})
	{print "Full Pathname with program to grade is:\n";
	 print $retval;
	 print "\nArchiveAdapter done.";
	}
	return $retval;
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
