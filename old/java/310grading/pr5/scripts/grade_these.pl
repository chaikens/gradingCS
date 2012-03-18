#!/usr/local/bin/perl  -w
# -w is for warnings; strongly recommended by Larry Wall, Perl's author

#######################################################################
# grade_these                                                         #
#######################################################################
# arguments are:

# grade_these --section section
#   specify a section name which is a subdirectory of the
#   project submission directory

# grade_these --all
#   grade all the projects submitted 

# grade_these userid
#   grade one submission

# grade_these --from userid [userid2]
#   grade all submissions beginning with the one 
#    with this userid, up to and including userid2,
#   "globbing" order

# Interaction:  Before each new single submission grading
#  cycle, prompt to continue.  Newline or other response 
# not "n" continues it, "n" makes this script exit.

# configuration values

#set for debugging
#$FLG_verbose       = 1;    

$NAM_project   =  "pr7";
$Year          =  "Spr07";


#Settings sprcific for CSI310:
$DIR_home      =  "/home1/c/a/acsi310";
$DIR_scripts   =  "$DIR_home/private/$Year"."grading/$NAM_project";
$DIR_submit    =  "$DIR_home/submit";
$DIR_project   =  "$DIR_submit/$NAM_project";

$FLG_quiet     =  0;    #set to 1 by --quiet option


################################################################
# END OF PROJECT SPECIFIC CONFIGURATION                        #
################################################################

################################################################
#  (Abandon all hope, ye who enter here, unless you            #
#   study the code.)                                           #
#                                                              #

$DIR_filedir     =  $DIR_project;   #default when no sections are used.

#script or other executable to grade one submission.
#It will be called with the full pathname of the compressed
# or uncompressed tar file that contains the submission.

$EXE_grade_one = "$DIR_scripts/scriptIG.pl";

#$EXE_grade_one = "echo Simulated grading ";
#We overwrite previous setting 
#  to suppress perl warning about $DIR_scripts unused.

sub grade_one($)
{
    my($userid) = $_[0];
    my($FPN)    = "$DIR_filedir/$userid";

    print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n~ User $userid\n";
    print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n";

    if( -e "${FPN}.Z" ) 
    {
	$FPN = "${FPN}.Z";
    }

    if( not -e "$FPN" )
    {
	print "File $FPN doesn't exist??\n";
	return ;
    }
    
    system("$EXE_grade_one $FPN");
}


sub usage
{
    die("$0: Usage:\n $0 userid \n $0 --all \n $0 --from userid [userid] \n"
	. "--section section\n");

}


sub do_all()
{
    my(@FPN_files) = glob("$DIR_filedir/*");
    my($userid);

    foreach $userid (@FPN_files)
    {

	if($verbose) {print "File $userid\n";}

#strip leading pathname
	$userid =~ s#.*/##;

#strip the .Z if any
	$userid =~ s/.Z//;
	print "User $userid\n";
	unless( want_continue() )
	{
	    return ;
	}

	grade_one($userid);
    }
    print "Done with grading all...\n";
}

sub do_from($$)
# start grading from user $_[0] and stop after $_[1]
{
    my(@FPN_files) = glob("$DIR_filedir/*");
    my($userid);

    my($started) = 0; 
#set when user id $_[0] is reached.

    foreach $userid (@FPN_files)
    {

	if($verbose) {print "File $userid\n";}

#strip leading pathname
	$userid =~ s#.*/##;

#strip the .Z if any
	$userid =~ s/.Z//;
	if( $_[0] eq $userid )
	{
	    $started = 1;
	}

	if( $started )
	{
	    print "User $userid\n";
	    unless( want_continue() )
	    {
		return ;
	    }

	    grade_one($userid);
	}

	if( $_[1] eq $userid )
	{
	    print "Done with grading all $_[0] to $_[1]...\n";
	    return ;
	}
    }
    print "Done with grading all $_[0] to end...\n";
}

sub want_continue()
{
    if( $FLG_quiet ) { return 1; }
    my($ans) = "";
    print "Do you want to continue grading (y/n)[y]?\n ";
    chomp($ans=<STDIN>);
    if ($ans eq "n")
    {
	return 0;
    }
    return 1;
}


################################################################################
# 
#   ENTRY HERE
################################################################################

my $from1 = "";
my $from2 = "";
my $all   = "";
my $section  = "";
my $grade_this = "";

if ( $#ARGV  eq -1 )
{
    usage();
}

while( $#ARGV ne -1 )
{
    if ($ARGV[0] eq "--from")
    {
	shift @ARGV;     #delete --from; I hate defaults.
	if( ($#ARGV eq -1 ) || ($ARGV[0] =~ m/^--/))  
	{
	    # no arg of --from, bad usage.
	    usage();
	}
	$from1 = $ARGV[0];  #get first arg of --from
	shift @ARGV;        #get rid of first arg of --from
	if( $#ARGV ge 0)
	{
	    if( $ARGV[0] !~ m/^--/ )
	    {
		$from2 = $ARGV[0];
		shift @ARGV;
	    }
	}
    }
    elsif ($ARGV[0] eq "--all")
    {
	shift @ARGV;
	$all = 1;
    }
    elsif ($ARGV[0] eq "--quiet")
    {
	shift @ARGV;
	$FLG_quiet = 1;
    }
    elsif ($ARGV[0] eq "--section")
    {

	shift @ARGV;  #get rid of --section
	if (( $#ARGV eq -1 ) ||($ARGV[0] =~ m/^--/))  
	{
	    usage();
	}
	$section = $ARGV[0];
	$DIR_filedir = "$DIR_project/$section";
	shift @ARGV;
    }
    else
    {
	#done with detecting -- options, treat argument
	# as one student id to grade now.
	if( ($#ARGV ge 0 ) && ($ARGV[0] =~ m/^--/) )
	{
	    usage();
	}
	$grade_this = $ARGV[0];
	shift @ARGV;
    }
}

if( not -d $DIR_filedir )
{
    print "grade_these.pl: Directory $DIR_filedir doesn't exist.\n";
    usage();
}

if( $grade_this )
{
    if( $from1 || $all )
	{
	    usage();
	}
    grade_one($grade_this);
    exit 0;
}
if( $all )
{
    if( $from1 )
	{
	    usage();
	}
    do_all();
    exit 0;
}
if( $from1 )
{
    do_from($from1, $from2);
    exit 0;
}



#usage();

die("No student id's or --all option given, or BUG in grade_these.pl");











































