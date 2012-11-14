#!/usr/bin/perl  -w
# -w is for warnings; strongly recommended by Larry Wall, Perl's author

use SubmissionAdapter qw(submissionTime getUserId loadTestCompileDir);
#SubmissionAdapter.pm adapts system specific info to the general script.
#

use JavaAnalyzers qw(doesSignatureExistInClass);
# public void vignette();
# public void vignette(int, int, int, int, java.awt.Color);



use Cwd; #for cwd() function

##########ARGUMENT(S)###################################################
#  scriptIG.pl [--manual] \                                            #
#    FULL_PATHNAME_OF_COMPRESSED_OR_UNCOMPRESSED_TAR                   #
#  (full pathname is needed so the stat() function can get at the file #
#   after chdir to the test compile directory was done.)               #
#########ENVIRONMENT SETTINGS###########################################
# TANAME short grader name used in files and directory names.          #
# PATH must contain . (current working dir.).                          #
#   This was the old-fashioned default. We won't make this happen in   #
#   the script below for security reasons.  Perhaps we should use full #
#   pathname when executing student submitted shell scripts and/or     #
#   programs under test that we had built.                             #
########## INITIALIZERS ################################################
# must be put before subroutine definitions                            #
#    (discovered by trial and error.  Undocumented??                   #
########################################################################
#  RCS version log below..
#
#
# Definitions and documentation of project specific variables come first.
# Then, definitions and documentation of general variables next, altogether
# these document what files and directories the script uses or creates.
# The control flow is expressed using functions (Perl "sub"s)
#
########################################################################
$verbose = 0;
# for debugging of the grading script
############################################################################
# Set handler for INT signal so accidental C-C doesn't mess us up          #

sub int_handler
{   my($x); 
    print "\nWas that an accidental C-C?
 Type C-Z, ps, kill -9 the scriptIG process if not, then type fg
 Press enter until script recovers if yes\n";
    $x = <STDIN>;
};
$SIG{INT} = \&int_handler;
#                                                                          #
#                                                                          #
############################################################################
#                                                                          #
# Predeclarations
############################################################################
sub askYes($);
sub backupFile($);
sub scoreStartTestCases($$);
sub scoreReport($);
sub scoreInit($);
sub scoreThisQualityOutof($$$);
sub lookupUserName($);
sub gradeOneStudent(@);
sub SetDueTime($$$$$);
############################################################################


########## Get TA Name from environment to name temp dir, reports file, etc
#$TAUserName = "";     #set to "" when no TANAME is required.
#$TAUserName = $ENV{"TANAME"};
$TAUserName = $ENV{"USER"};
if( not defined $TAUserName  )
{
    print "Something's wrong: USER isn't defined in your environment\n";
    #print "Dear TA: You must put the enviroment variable TANAME set to your User Name\n",
    #"in the environment before running this script.  Exit now and do it:\n",
    #"setenv TANAME <your username in the ecl>\n";
    die ;
}



########################################################################
################### Project Configuration Area #########################
########################################################################
#####  Modify as you see fit. All config and grading variable here. ####

$Course = "CSI201";   #Course name/nr for mail subject line.


#For submission directory, grading dir, insertion in the grade reports, etc
$ProjectName        = "pr3";



$Complain_to = #"Professor Chaiken";
               "your TA $TAUserName";
$Complain_period = #"3 months";
               "1 week";
$Professor = "Professor Chaiken";

#Files not to be submitted. Wildcards ok, will glob
#my(@UnwantedFiles)  = ("*.class");
my(@UnwantedFiles)  = ();  #don't care if .class or other file is submitted.

$filesWeBuild = "Picture.class";

$DoNonFunReqCheck = 1;  # 1 to call NonFunReqCheck function to grade
                        # non-functional requirements

$NonFunGradInstructions = 
"Evaluate Version History and Testingrequirements:
Part1, Part12, Part123, etc.
Parts have at least Start and Release versions.
Version dirs. have both Picture.java and Picture.class files,
to give evidence of testing.
---------------
Main methods must actually test the assigned methods.\n";

$FileToDiffFrom = cwd()."/GradingCases/Picture.java.nomain";
$SubmittedFileToDiffTo = "Picture.java";


#examples of non-functional requrements:
#, grade for 
# (1) Modularization:Separate files; headers, implementations, templates, and main().
# (2) Separate modules for Card, Pile and Hand, effectively.
#\n";



# (2) Function documentation: In the form of pre/post-conditions.

#$NonFunGradInstructions = 
#"Ctl-Z, Examine Source Files now, grade for 
# (1) Separate Files: headers, implementations, templates, and main().
# (2) Function documentation: In the form of pre/post-conditions.
# (3) Clear and generally consistant Indentation.
# (4) Preconditions checked by assert IN METHODS, not in test driver.
#\n";

#" (3) Attempt to write multiple source file program.\n".
#" (4) Submission of test cases/testing script.\n";

$ReportFileRequired  = 0; # 1 to run GradeReportFile function to check/grade report.
$reportMissingReportToProfessor = 0;

$ReportFileName = "";
$ReportLikeFile = "";
$ReportFilePoints   = 0;


$VersionHistoryPoints = 10;
$MainsTestMethodsPoints = 10;
$RequestOneDirBeSubmitted = 0;
$OneDirSubmissionPoints = 0; 
$MakefilePoints = 0;         # Used only when $IsCompilable is true.
$SimpleMakefileRequired = 0; # Request TA to examine Makefile for being Simple.
$RevisionLogRequired = 0;    # Self-documenting.
$RevisionLogPoints = 0;      # Self-documenting, not necessarilly using RCS.
$BuildScriptPoints = 0;      # Self-documenting. 
$BuildScriptRequested = 0;
$IndentationPoints = 0;      # Self-documenting.
$PedagogicalInstructionsFollowedPoints = 0;
$FileSubmittedPoints = 0; 
$InformativeCommentsPoints = 0;    # Self-documenting. 
$AssertChecksPreconditions = 0;
$FunctionAttemptPoints = 0;  # Self-documenting. 
$StackFramePoints  = 0;      # Self-documenting.
$FunctionCommentsPoints = 0; # Self-documenting. 
$FunctionPrePostCondPoints = 0; # Self-documenting. 
$VariableCommentsPoints = 0; # Self-documenting. 
$MultipleFilesPoints = 0;    # Self-documenting. 
$ModularizationStandardsPoints = 0; # # Self-documenting.
$TestCasesPoints = 0;        # Self-documenting. 
$TestingScriptPoints = 0;    # Self-documenting. 
$ManualBuildOnly = 0;        # if 1, TA must always interrupt script, 
$AskVersionNumber = 0;       # Ask TA for version number, record it in:
$ClaimedVersion   = "";      # Used only when $AskVersionNumber
                  #  examine submission, try build as the assignment specifies.

$PointBreakdownMessage = "";
#"
#Up to 15 points from your paper design draft will be added by Prof. Chaiken.
#Software Process/Documentation Requirements: up to 15 points, 5 extra for test cases.
#";



# Required text files, not including $ReportLikeFile, 
#   meant for txt files but bin ok.
#my(@RequiredFiles)  = ("typescript","driver.script");
my(@RequiredFiles)  = ( );

$RequiresCompiling       = 1;       # Does the project require compiling?




$CheckPrevYearCase  = 0;       # Is there a test case for prev year check?

#$LimitPipeInBytes   = 2048;    # Max bytes piped for each test case
                               #   for infinite loops

################### Grading policy settings ############################
                                                                    
$valueReportTotal    = 0.0;              # Only used when $ReportFileRequired=1
$valueTestsTotal     = 0.0;
$valueTestsPhase1    = 0.0;
$valueTestsTotal     += $valueTestsPhase1;
$valueTestsPhase2    = 0.0;   #May be set each time by setVersionPoints()
$valueTestsTotal     += $valueTestsPhase2;
$valueInteractiveTests = 80.0;

$valueTestsTotal     += $valueInteractiveTests;
$valuePerTest        = "to be computed";  # Only used when $RequiresCompiling=1
$valuePerTestrounded = "to be computed";  # Only used when $RequiresCompiling=1
$numTests            = "to be computed";  # Only used when $RequiresCompiling=1
$Score               = "to be computed";
$ScorePenalized      = "to be computed";

# Added to $Score when unwanted files detected
$valueUnwantedFiles = -0.0; #Don't care for now.

sub setVersionPoints( $ )
{
    if( $_[0] == 0 ) { $valueTestsPhase2 = 20; }
    if( $_[0] == 1 ) { $valueTestsPhase2 = 50; }
    if( $_[0] == 2 ) { $valueTestsPhase2 = 55; }
    if( $_[0] == 3 ) { $valueTestsPhase2 = 70; }
}

###################### Project due time and late config ###################

# On time Project Deadline  11/3/12 23:59 (11:59PM)
$DUEhour = 23;
$DUEmin  = 59;
$DUEmon  = 10;         # Month January = 0
$DUEmday = 3;
$DUEyear = 112;        # Years past 1900
$DUEtime = SetDueTime($DUEyear,$DUEmon,$DUEmday,$DUEhour,$DUEmin);  # Secs. past epoch

# Early bird Deadline  same as On time
$EARLYhour = 23;
$EARLYmin  = 59;
$EARLYmon  = 9;         # Month January = 0
$EARLYmday = 27;
$EARLYyear = 112;        # Years past 1900
$EARLYtime = SetDueTime($EARLYyear,$EARLYmon,$EARLYmday,$EARLYhour,$EARLYmin);  # Secs. past epoch


# Maximum days late: Projects turned in on that day and after = 0 credit
$DUEmaxdayslate = 7.0;

#Inverse Penalty Rate.  If this is say 12, penalty is 1/12 or 8.333% per day.
$DUEDaysPer100PercentOff = 100.0/14.0;

#Set to > 1 to give bonus for earliness.
$DUEearlyBonusFactor = 1.10;
###################### Directory Info ########################
chomp( $cwd = `pwd`);

$ProjGradingDir = $cwd;

$TestCaseDir       = "$ProjGradingDir/GradingCases";
$GradersBuildCommand = "$TestCaseDir/gradersBuilder";


$publicTestCaseBaseURL = 
    "http://www.cs.albany.edu/~sdc/CSI201/Fal12/Proj/Proj3/";

sub URLize($)
{
    my($x) = $_[0];
    $x =~ s/$TestCaseDir\//$publicTestCaseBaseURL/;
    return $x;
}

$JavaClassPathCourse = 
    "/home/faculty1/sdc/public_html/CSI201/Spr12/201Stuff/bookClasses-7-22-09/bookClasses";
$JavaClassPathProject = "$TestCaseDir/classes";
$JavaClassPathGrading = ".:$JavaClassPathProject:$JavaClassPathCourse";
$ENV{CLASSPATH} = $JavaClassPathGrading;


$OneIGTestCaseDir = "";
$OneIGexeName = "";
$OneIGPoints = 0;

$PenaltyPolicyFile = "$TestCaseDir/penalties";

@PartsIGList = ("javaTests");
@PartsIGexeName = ("$TestCaseDir/javaTests/javaTests.exe");
@PartsIGTestCaseDir =
    ("$TestCaseDir/javaTests");
@PartsIGPenaltyPolicyFile =
    ("$TestCaseDir/penalties"   
     );

@PartsIGPoints = (90);

################# Code Project Specific Special Pretests HERE.
sub ProjectSpecificSpecialPretests()
{
#    my($rating) =
#	runOneAutomaticTestReturnRating("$TestCaseDir/Pretests/colon.out");
#    scoreOneTestAddorSubPoints("Command-starts-with-colon", $rating, -4.0);
#    if( $rating == 0.0 )
#    {
#	@PartsIGTestCaseDir = ("$TestCaseDir/nocolon");
#    }
}


#$TestCaseDirPhase2 = "";

# where the test cases and reference output will be found
# standard test case names (for executable programs):
#  for example test case named                       t01
#  Explanation of that test                          t01.txt
#  File to direct stdin from:                        t01.in
#  File to copy to test directory                    t01.infname
#                                                or  t01.$infsuffix

$infsuffix = "code";

#  File with ref output created by program:          t01.ouftname
#  File with ref (ideal?) output from stdout:        t01.out
#  Optional File with one line of 
#                        cmd line & args w/ env:     t01.cmd
#   (w/ custom enviroment to be passed to the
#    program under test using the Unix env -i )
#  Optional Filter run when diff test fails:         t01.flt

                                                                    
#############################################################################
# All project configuration variable above, only code below
#############################################################################

$AllGradeReports = "$ProjGradingDir/reports";

die "Make directory $AllGradeReports and try again." unless -d $AllGradeReports; 

$GradeReportsDir = "$AllGradeReports/$TAUserName";
# directory where the reports to be mailed to the students
# will appear.  This should be a different directory for each project.  
# The name of the file be the UserId of the student
# The perl file handle for the current GradeReport file will be   GROUT

$GradeSummaryFile = "$AllGradeReports/$TAUserName.summary";
# The file where a records of each student's score before late check & 
#   final score is appended.
# FORMAT: <UserId> <Grade before Late Penalties> <Final Score>
#
# The perl file handle for the GradeSummaryFile will be  SUMOUT
open(SUMOUT, ">>$GradeSummaryFile") 
    || die("Can't open $GradeSummaryFile\n");
chmod 0660, $GradeSummaryFile;

$NoReportFile = "$AllGradeReports/$TAUserName.no_report";
# The file of student id's without a $ReportLikeFile, followed by the TA rating
# The TA rating is if the TA finds a valid report under different filename
# FORMAT: <UserId> <TA Final Rating for any report like file>
#
# The perl file handle for the NoReportFile will be      NOREPOUT
open(NOREPOUT, ">>$NoReportFile")
    || die "Can't open $NoReportFile\n";
chmod 0660, $NoReportFile;

#$NoIntegrityFile="$AllGradeReports/$TAUserName.no_integrity";
# The file of student id's without the integrity statement
# FORMAT: <UserId> [ "No Integrity Statement" | "Accepted Last Year's Spec" ]
# 
# The perl file handle for the NoIntegrityFile will be   NOINTEGOUT
#open(NOINTEGOUT,">>$NoIntegrityFile") 
#  || die("Can't open $NoIntegrityFile\n");
#chmod 0660, $NoIntegrityFile;

#####################################################################

$TestCompileDir = "/tmp/$TAUserName.grading201";
# here is where the student submission will 
#  be unpacked
#  be compiled/linked
#  have its executable for testing if same as below
#  Might be changed by the script
############################################################################
#
#
#
$ManualBuildFixMessage = "TA: You may have to look in $TestCompileDir";
#"TA: If you don't already have DrJava (or other) open on 
#$TestCompileDir, 
#   type C-Z here,
#   then ./drjava [KEEP drjava open to SAVE TIME!]
#   then fg
#See if you can rename and/or change arguments of these methods in
#Picture.java so you can test the submitted work:
#void changeWhole( double )  
#boolean scribble( int, int, double ) 
#Compile again to get a Picture.class file
#Then type y if you succeeded and n if not.\n";





$MakeMessageFile = "$TestCompileDir/gmake.output";
$CompileMessageFile = "$TestCompileDir/compile.output";
# temporary files for output of gmake and manual compiles

#$TestCWD = "$TestCompileDir";
# working directory when the student program is run
# could be the same as TestCompileDir to facilitate running
# a debugger on the student program
#We will use variable $TestCompileDir IN PLACE OF $TestCWD
#$TestCWD is removed now!


#varying global variables
$ManualFlag = 0;       # Set true when script's first cmd line arg is --manual.
$UserId = "none-yet";
my($GLOBALtestnum) = "unset";
$diffParams = "-w -i -b";
$diffDir = "/usr/bin";
$diffName = "diff";
$diffCommand = "$diffDir/$diffName $diffParams ";
$FilesReceived = ""; #Rel. pathnames of files and dirs. received 1 per line.
@FilesReceivedL = (); #List of the above, calculated by Perl's split.
#
#     -b ignore trailing blanks and treat other whitespace strs as equiv.
#     -w ignore all spaces and tabs, and treat other strs of blanks as equiv;
#        this is more liberal
#     -i ignore case differences.

#$compressed_file_pattern = "/[.]*Z$/";
#Pattern to detect a compressed file.  Unfortunately, the use of
# a variable to hold it so it can be easily modified for different
# systems did not work.  Hence to port to another system, you
# MUST edit the pattern in the subroutine loadTestCompileDir
#


if ($verbose) { print "$0 called with ARGV=@ARGV\n"; }
############################################################################
#                                                                          #
# Execution starts here..                                                  #
#                                                                          #
#                                                                          #
############################################################################
sub gradeOneStudent(@);
gradeOneStudent(@ARGV);
############################################################################
#                                                                          #
# Subroutines below..                                                      #
#                                                                          #
#                                                                          #
############################################################################
sub TAWriteComment()
{
    print "TA:Explain? 60 or fewer chars/line; end with blank.\n";
    print "------------------------------------------------------------\n";
    my $CurString;
    chop( $CurString = <STDIN> );
    while ( $CurString ne "" )
    {
	print GROUT "     TA:  $CurString\n";
	chop( $CurString = <STDIN> );
    }
    print GROUT "\n";
}

sub AddPenaltyorComments($)
{
    my($PenaltyPolicyFile) = $_[0];
    
    if(!$TAHaltedTesting and !askYes("TA:Any penalty or comments?") )
    {
	return ;
    }
    if( $PenaltyPolicyFile )
    {
	# Put in the TA instructions if any.
	if(open(TXT, "<$PenaltyPolicyFile") )
	{
	    print "--- Policy:\n";
			    while ($line = <TXT>) 
			    {
				print "   $line";
			    }
			    close (TXT);
	}
    }


    print "\nTA:Number of penalty points to deduct(0 if none)";
    print ": ";
    my($reply) = getNumber(0.0,100.0);
    if( $reply != 0 )
    {

	# Put in the TA instructions if any.
	if( $PenaltyPolicyFile )
	{
	    if(open(TXT, "<$PenaltyPolicyFile") )
	    {
		print GROUT 
"\n--- Policy from ".URLize($PenaltyPolicyFile)." :\n";
		while ($line = <TXT>) 
		{
		    print GROUT "   $line";
		}
		close (TXT);
	    }
	}
	my($msg) =  "$reply penalty points deducted, explanation below from $TAUserName:";
	print GROUT "$msg\n" ;
	print "$msg\n" ;
	$Score = $Score - $reply;
	print "TA:Score after penalies, before lateness deduction:$Score\n";
    }
    else
    {
	print "TA:Score after penalies, before lateness deduction:$Score\n";
        $reply = askYes
"\nTA:Do you wish to add comments to the grade report?";
    }
    if ( $reply or $TAHaltedTesting )
    {
	if($TAHaltedTesting) {print "You must explain why you halted testing.\n"}
	TAWriteComment();
    }
}


sub gradeOneStudent(@)
# $_[0] is the (full) pathname of the submission directory
{
    if( @_ < 1 )
    {
	die "Error: $0 called with 0 arguments\n.";
    }
    if( $_[0] eq "--manual" )
    {
	$ManualFlag = 1;
	shift @_;     #I hate defaults!
    }
    if($verbose){print "gradeOneStudent $_[0]";
		 if($ManualFlag) {print " with ManualFlag on";}
		 print "\n";}
    my($BuildSuccessful) = 0;
    $UserId = getUserId( $_[0] );
    print "\n\nGet ready to grade student with UserId $UserId \n";
    if( $ManualFlag )
    {
	print "Enter correct UserId($UserId):";
	my($in);
	$in = <STDIN>;
	chomp($in);
	if( $in )
	{
	    $UserId = $in;
	    print "UserId changed from that from filename.";
	}
    }
    scoreInit( $UserId );
    
    $ENV{IMAGES_PREFIX} = cwd()."/WorkSamples/$UserId";


    unless( -d $GradeReportsDir )
    {
	mkdir($GradeReportsDir,0770) || die("Can't mkdir $GradeReportsDir\n");
	# mode 0700 begins with 0 to tell perl it is octal
    }
    backupFile( "$GradeReportsDir/$UserId" );
    open(GROUT,">$GradeReportsDir/$UserId") || 
	die("Can't open $GradeReportsDir/$UserId\n");
    chmod 0660, "$GradeReportsDir/$UserId";
    writeGROUTHeading();
    $SubmissionPathName = $_[0];
    if($ManualFlag )
    {
	print 
"Enter new full pathname of submission,
 prev to keep current grading dir. contents
 or <Enter> to use path below..\n($_[0]):";
	my($in);
	$in = <STDIN>;
	chomp($in);
	if( $in eq "prev" )
	{
	    $SubmissionPathName = "";
	}
	elsif( $in )
	{
	    $SubmissionPathName = $in;
	}
    }
    if( $SubmissionPathName ) 
    {
	($TestCompileDir,$FilesReceived, @FilesReceivedL)
	    =loadTestCompileDir( $TestCompileDir,  $SubmissionPathName );
    }

#    if( $ManualFlag && askYes("Check unwanted files?") )
    {checkUnwantedFiles( );}

#    if( $ManualFlag && askYes("Check required files?") )
    {checkRequiredFiles( );}

    if($RequestOneDirBeSubmitted)
    {
	$GotOneDirectory = getOneDirectory();

	if($OneDirSubmissionPoints)
	{
	    scoreThisQualityOutof 
		"Single Directory Required:",
		$GotOneDirectory,
		$OneDirSubmissionPoints;
	}
    }

    if( $ManualBuildOnly )
    {
	$BuildSuccessful = doManualBuild();
    }

    if($GradersBuildCommand ne "")
    {
	$BuildSuccessful = tryBuildWithCommand();
    }


##    if ( $ReportFileRequired ne 0)  { GradeReportFile( ); }

##    if ( $DoNonFunReqCheck ne 0)   { NonFunReqCheck(); }

    if (!$ManualBuildOnly and $RequiresCompiling==1)
    {
	if( $ManualFlag && !askYes("Run automated building?"))
	{
	    $BuildSuccessful = askYes(
"Run grading tests now?(You can check before answering.)");
	}
	else
	{
	    if($BuildScriptRequested)
	    {
		$BuildSuccessful = tryBuildScript( );
		if($BuildSuccessful and $BuildScriptPoints)
		{
		    scoreThisQualityOutof 
			"Automatic use of submitted build script OK",
			1.0,
			$BuildScriptPoints;
		}
	    }
	    if(!$BuildSuccessful)
	    {
		$BuildSuccessful = doManualBuild( );
		if( $BuildScriptPoints )
		{
		    print "Build script quality:";
		    $value = getNumber(0.0, 1.0);
		    scoreThisQualityOutof 
			"Build script submitted/worked OK",
			$value,
			$BuildScriptPoints;
		}
	    }
	}
    }

    if ( $ReportFileRequired ne 0)  { GradeReportFile( ); }

    if ( $DoNonFunReqCheck ne 0)   { NonFunReqCheck(); }

    if ( $BuildSuccessful )
    {
	ProjectSpecificSpecialPretests();

	if(@PartsIGList)
	{
	    my($i);
	    for($i=0; $i<@PartsIGList; $i++)
	    {
		if(
		   askYes(
"\n\nCan you grade $PartsIGList[$i] interactively?") )
		{
		    print GROUT
"\n\nBegin reports of $PartsIGList[$i] tests..\n";
		    runInteractiveTestCases(
			$PartsIGTestCaseDir[$i],#Directory
			$PartsIGexeName[$i],	#exeName
			$PartsIGPoints[$i]	#Value
						);
		}
		else
		{
		    print GROUT 
"\n\nInteractive grading of $PartsIGList[$i] cannot be done.\n\n";
		}
		print "($PartsIGList[$i])";
		AddPenaltyorComments($PartsIGPenaltyPolicyFile[$i]);
	    }
	}
#	runTestCasesPhase1();
#	runTestCasesPhase2();
	if($OneIGTestCaseDir)
	{
	    print GROUT
"\n\nBegin reports of tests..\n";
	    runInteractiveTestCases(
		   $OneIGTestCaseDir,          #Directory
		   $OneIGexeName,	      #exeName
		    $OneIGPoints	      #Value
					);
	}
	print "(overall)";
    }
    else
    {
	print GROUT "Programming Projects must be compilable and linkable
  to earn any credit in this course..\n";

	print SUMOUT "\nScore for non-compilable $UserId from non-functional stuff:$Score\n";
	print SUMOUT "$UserId $UserId ";
	$Score = 0.0;
    }
    AddPenaltyorComments($PenaltyPolicyFile);
    scoreCheckLate ( $_[0] );
    scoreDone( $UserId );
    close(GROUT);
}




sub lookupUserName($)
{
    return "$_[0]";
    #do nothing for now..ITS uses nis
    my( $UserId ) = $_[0];
    my( $uline  );
    my( @fline  );
    open(PFILE, "/etc/passwd");
    while($uline = <PFILE>)
        {
            if ($uline =~ /$UserId/)
            {
# use the /:/ pattern to include comma separated name fields
#               @fline =  split /:/, $uline, 7;
                @fline =  split /[:,]/, $uline, 7;
		return $fline[4];
            }
        }
    return "NOT FOUND in /etc/passwd?";
}



sub writeGROUTHeading()
{
    print GROUT "Subject: $Course Grading Report\n";
    print GROUT "\nUser Id:$UserId,  Project Name:  $ProjectName\n";
    print GROUT "\nThis is the automatically generated grading output\n\n";
	  
    print GROUT "If you have any questions about your grade on this program,\n";
    print GROUT "please contact $Complain_to. You have $Complain_period\n";
    print GROUT "from the receipt of this message to request a grade change,\n";
    print GROUT "after which this becomes your permanent score for this assignment.\n\n";
}


#--------------------------------------------------------------------------

sub checkRequiredFiles ()
{
    chdir( $TestCompileDir );

    my($index) = 0;

    if ($verbose)
    {
	print "\nChecking Required Files\n\n";
    }

    print "\n\n";

    while ( defined($RequiredFiles[$index]) )
    {
	if (( index($RequiredFiles[$index],"*") != -1 ) ||
	    ( index($RequiredFiles[$index],"?") != -1 ))
	{
	    die ( "No wildcards allowed in Required Files List.\n\n");
	}	
	else
	{ 
	    if ( !( -f "$RequiredFiles[$index]" ) )
	    { 
		@Required = (@Required, "$RequiredFiles[$index]");
	    }
	    else
	    {
		#Uncomment to print out every reqd file
		#use more (or less) on each required file
		#print "\n--------------- @RequiredFiles[$index] ---------------\n";
		#system("less @RequiredFiles[$index]");
		#print "\n\n";
	    }
	}
	
	$index = $index + 1;
    }
    
    
    if ( @Required )
    {

	print "\nThe following required files were not found:\n     @Required\n";
	print GROUT "\nThe following required files were not found:\n     @Required\n\n";

	# Uncomment for penalizing missing required files
	# print "\nPenalty (in points off project grade): ";
	# my($penalty) = int(getNumber (0.0,100.0));
	# print "\nPenalty for not submitting required files : ",$penalty,"\n";
	# print GROUT "\nPenalty for not submitting required files : ",$penalty,"\n";
	# $Score=$Score-$penalty;

    }

}

sub checkUnwantedFiles()
{
    if ($verbose) 
    { 
	print "Checking Unwanted Files\n\n"; 
    }

    my( @Unwanted ) = ( );
    my( $nUnwanted ) = 0;
    chdir( $TestCompileDir );
    my( $filename );
    foreach $filename (@FilesReceivedL) {
	if (`file $filename` =~ /.*ELF.*/) {
	    $nUnwanted = $nUnwanted + 1;
	    @Unwanted = (  @Unwanted , "$filename");
	}
    }
    
    my($index) = 0;

    while ( defined($UnwantedFiles[$index]) )
    {
	if (( index($UnwantedFiles[$index],"*") != -1 ) ||
	    ( index($UnwantedFiles[$index],"?") != -1 ))
	{
	    my(@tmp);
	    @tmp = glob ( $UnwantedFiles[$index] );
	    if(@tmp)
	    {
		$nUnwanted = $nUnwanted + scalar @tmp;
		@Unwanted = (@Unwanted, @tmp);
	    }
	}	
	else
	{ 
	    if ( -f "$UnwantedFiles[$index]" ) {
		@Unwanted = (@Unwanted, "$UnwantedFiles[$index]");
		$nUnwanted = $nUnwanted + 1; 
	    }
	}
	
	$index = $index + 1;
    }

    
    if ( $nUnwanted != 0 )
    {
	my($t);
	$t = "@Unwanted";
	$t =~ s/ /\n/g ;
	print 
	    "\nThe following files were not to be submitted:
$t\n";
	print GROUT "\nThe following files were not to be submitted:
$t\n\n";
	print "Penalty for unwanted files : ",$valueUnwantedFiles,"\n";
	print GROUT "Penalty for unwanted files : ",$valueUnwantedFiles,"\n";

	$Score=$Score+$valueUnwantedFiles;

	unlink @Unwanted;
    }
}
    
sub scoreThisQualityOutof($$$)
{
    $Score = $Score + $_[1]*$_[2];
    print GROUT "Points for $_[0]: ",$_[1]*$_[2], "/", $_[2], "\n";
}

#----------------GradeReportFile----------------------------------------
sub GradeReportFile()
{
    my($value);
    my($hasinteg)=0;
    my($anyreport)=1;

    chdir( $TestCompileDir );
	if( -f "$ReportFileName" )
	{
	print "Ctl-Z, Read $ReportFileName file now,
 grade $ReportLikeFile
 then give fg command and enter value";
	$value = getNumber(0.0,1.0);
	scoreThisQualityOutof($ReportLikeFile,
			      $value,
			      $ReportFilePoints );
    }
    else
    {
	print NOREPOUT $UserId, " ";
	print GROUT 
"\n\nA file named $ReportFileName was not included!\n";
	print GROUT 
"We will attempt to find a $ReportLikeFile to grade anyway.\n";

	print 
"Ctl-Z, $ReportFileName NOT FOUND, check it out!, fg to continue..\n";



	$anyreport=askYes
	    "Does any $ReportLikeFile exist?";
	print NOREPOUT $anyreport, " ";

	if ($anyreport==1)
	{
	    print GROUT "Found a badly-named $ReportLikeFile file.\n";
	    print GROUT "For now, no points deducted for bad name.\n";

	    print "Ctl-Z, Read badly the named $ReportLikeFile file now,
 grade $ReportLikeFile
 then give fg command and enter value";
	    $value = getNumber(0.0, 1.0);
#	    chop($value = <STDIN>);
	    print GROUT
"$ReportLikeFile graded..\n";
	    scoreThisQualityOutof 
		$ReportLikeFile,
		$value,
		$ReportFilePoints;
	    print NOREPOUT $value, "\n";
	}
	else
	{	    
	    print GROUT "Was unable to find any $ReportLikeFile.\n";
	    scoreReport(0);
	    print NOREPOUT "0\n";
	    $hasinteg=0;
	    if($reportMissingReportToProfessor)
	    {print GROUT "This has been reported to $Professor.\n";}
	}
	

    }

#    if ($anyreport==1)
#    {
#       $hasinteg = askYes
#	"Does any report file have an integrity statement?";
#	print "\nValue will be truncated w/ 0=No, 1=Yes : ";
#    }
    
#    if ($hasinteg ne 1)
#    {
#	print NOINTEGOUT $UserId, " No Integrity Statement\n";
#	print GROUT "\nAn integrity statement was not included!\n";
#	print GROUT "This has been reported to $Professor.\n\n";
#    }

}
#----END OF------GradeReportFile----------------------------------------



sub GradeRevisionLog() #------------------------------------------------
{
    print "Ctl-Z, Look for and examine revision log(s)\n";
    if( !askYes( "Does any revision log exist?"))
    {
	#NO REVISION LOG!!
	print NOREPOUT $UserId, " ";
	scoreThisQualityOutof 
	    "Revision History",
		0,
		$RevisionLogPoints;
	print NOREPOUT "(NO REVISION LOG) 0\n";
#	    $hasinteg=0;
	if($reportMissingReportToProfessor)
	{
	    print GROUT "This has been reported to $Professor.\n";
	}
    }
    else
    {
	print "Grade for clarity and completeness of revision history:";
	$value = getNumber(0.0, 1.0);
	scoreThisQualityOutof 
	    "Revision History Quality",
	    $value,
	    $RevisionLogPoints;
    }
}
#----END OF GradeRevisionLog()---------------------------------------------


sub NonFunReqCheck( )  #---------------------------------------------------
{
    my($value);
    chdir( $TestCompileDir );
    if( $RevisionLogRequired )
    {
	GradeRevisionLog();
    }

    print $NonFunGradInstructions;

    if( $FileToDiffFrom )
    {
	system("diff $FileToDiffFrom $SubmittedFileToDiffTo");
    }




    if( $VersionHistoryPoints )
    {
	print "Version History Requirements:";
	$value = getNumber(0.0, 1.0);
	scoreThisQualityOutof 
	    "Version History Requirements.",
	    $value,
	    $VersionHistoryPoints;
    }

    if( $MainsTestMethodsPoints )
    {
	print "Main methods test the methods you were told to write and TEST:";
	$value = getNumber(0.0, 1.0);
	scoreThisQualityOutof 
	    "Main methods test the methods you were told to write and TEST:",
	    $value,
	    $MainsTestMethodsPoints;
    }






    if( $PedagogicalInstructionsFollowedPoints )
    {
	print "Instructions with pedagogical reasons followed:";
	$value = getNumber(0.0, 1.0);
	scoreThisQualityOutof 
	    "Forbidden Operations: Use ONLY operations described in assignment.",
	    $value,
	    $PedagogicalInstructionsFollowedPoints;
    }

    if( $FileSubmittedPoints )
    {
	print "Suitable file(s) submitted:";
	$value = getNumber(0.0, 1.0);
	scoreThisQualityOutof 
	    "Required file or files submitted.",
	    $value,
	    $FileSubmittedPoints;
    }


    if( $ModularizationStandardsPoints )
    {
	print "Modulization Standards:";
	$value = getNumber(0.0, 1.0);
	scoreThisQualityOutof 
	    "Modularization: Class header, impl, templates; main().",
	    $value,
	    $ModularizationStandardsPoints;
    }

    if( $FunctionPrePostCondPoints )
    {
	print "Function Documentation MUST BE pre/postconditions:";
	$value = getNumber(0.0, 1.0);
	scoreThisQualityOutof 
	    "Function documentation written as pre/postconditions",
	    $value,
	    $FunctionPrePostCondPoints;
    }


    if( $AssertChecksPreconditions )
    {
	print "Precondition assertions MUST be in method, not tester:";
	$value = getNumber(0.0, 1.0);
	scoreThisQualityOutof 
	    "Precondition assertions MUST be in method, not tester:",
	    $value,
	    $AssertChecksPreconditions;
    }


    if( $IndentationPoints )
    {
	print "Indentation:";
	$value = getNumber(0.0, 1.0);
	scoreThisQualityOutof 
	    "Clear/Consistant Indentation",
	    $value,
	    $IndentationPoints;
    }
    if( $InformativeCommentsPoints )
    {
	print "Comments generally useful and informative:";
	$value = getNumber(0.0, 1.0);
	scoreThisQualityOutof 
	    "Useful Comments",
	    $value,
	    $InformativeCommentsPoints;
    }
    if( $FunctionAttemptPoints )
    {
	print "Attempt to use functions/procedures in solution:";
	$value = getNumber(0.0, 1.0);
	scoreThisQualityOutof 
	    "Attempt to use functions or proceduress",
	    $value,
	    $FunctionAttemptPoints;
    }
    if( $FunctionCommentsPoints )
    {
	print "Comments DOCUMENT Function interface:";
	$value = getNumber(0.0, 1.0);
	scoreThisQualityOutof 
	    "Function Parameter, Return, Action Documentation",
	    $value,
	    $FunctionCommentsPoints;
    }
    if( $StackFramePoints )
    {
	print "Each procedure's stack frame layout DOCUMENTED:";
	$value = getNumber(0.0, 1.0);
	scoreThisQualityOutof 
	    "Stack frame layout documentation",
	    $value,
	    $StackFramePoints;
    }
    if( $VariableCommentsPoints )
    {
	print "Comments DOCUMENT variables in terms of purpose:";
	$value = getNumber(0.0, 1.0);
	scoreThisQualityOutof 
	    "Documentation of what important variables mean",
	    $value,
	    $VariableCommentsPoints;
    }
    if( $MultipleFilesPoints )
    {
	print "Attempt to write program in multiple files:";
	$value = getNumber(0.0, 1.0);
	scoreThisQualityOutof 
	    "Writing program in multiple source files",
	    $value,
	    $MultipleFilesPoints;
    }
    if( $TestCasesPoints )
    {
	print "Test cases submitted:";
	$value = getNumber(0.0, 1.0);
	scoreThisQualityOutof 
	    "Test cases",
	    $value,
	    $TestCasesPoints;
    }
    if( $TestingScriptPoints )
    {
	print "Testing Script submitted:";
	$value = getNumber(0.0, 1.0);
	scoreThisQualityOutof 
	    "Testing Script",
	    $value,
	    $TestingScriptPoints;
    }
    if( $AskVersionNumber )
    {
	my $Done = 0;
	while( ! $Done )
	{
	    print "Version Number?:";
	    chop($ClaimedVersion = <STDIN>);
	    $TestCaseDirPhase2 = "$TestCaseDir/Version$ClaimedVersion";
	    if( -d $TestCaseDirPhase2 )
	    {
		$Done = 1;
		setVersionPoints( $ClaimedVersion );
	    }
	    else
	    {
		print "Invalid Version number. See";
		system("ls $TestCaseDir");
	    }
	}
    }
    if( $PointBreakdownMessage )
    {
	print GROUT $PointBreakdownMessage;
    }
    print GROUT "Functional test results";
    if( $AskVersionNumber )
    {
	print GROUT " for Version"."$ClaimedVersion";
    }
    print GROUT " up to $valueTestsTotal points.\n"
}

sub getOneDirectory
{
    chdir $TestCompileDir;
    #CSI310 used to require submission of a directory.
    opendir TESTCOMPDIR, "." or die "serious dainbramage: $!";
    my(@allfiles) = grep !/^\.\.?/, readdir TESTCOMPDIR;
    closedir TESTCOMPDIR; 
    #thanks Camel Book page 202-3.
    my($n,$t);
    $n = @allfiles;
    if($n!=1){
	print GROUT "Submission doesn't consist of one directory.\n";
	print "Submission doesn't have just one top level entry..try to build manually.\n";
	return 0;
    } #must have only one entry.
    ($t) = @allfiles;
    if(not -d $t){
	print GROUT "Submission doesn't consist of one directory.\n";
	print "Submission's top entry is not a dir..try to  build manually.\n";
	return 0;
    } #which must be a directory
    print GROUT "Directory submitted=$t\n";
    chdir $t;
    $TestCompileDir = cwd();
    return 1;
}



sub tryBuildScript
{
    my(@exenames) = @PartsIGexeName;
    if($OneIGexeName){@exenames=(@exenames,$OneIGexeName);}
    if( not `file "build.sh"` =~ /(.*executable.*script)|(.*script.*executable)/ )
    {
	print GROUT "The result of our automatic attempt to run build.sh\n";
	print GROUT "is missing or non-executable or non-script build.sh\n";
	print GROUT "Results of manual investigations follow.\n";
	print "Missing or non-executable or non-script build.sh\n";
	return 0;
    }
    print "\n---LOOK AT THE build.sh CONTENTS--------\n";
    system( " cat build.sh ");
    print "--------end of build.sh---------";
    if(not askYes("Look OK?"))
    {
	return 0;
    }

    my($buildout) = `build.sh`;  
    print "$buildout\n";

#    if( (not -d $TestCWD) and ($TestCompileDir ne $TestCWD ))
#    {
#	mkdir($TestCWD,0770) || die( "Cannot mkdir $TestCompileDir\n" );
#	# mode 0700 begins with 0 to tell perl it is in octal
#    }	

    if( not -d $TestCompileDir) 
    {
	mkdir($TestCompileDir,0770) || die( "Cannot mkdir $TestCompileDir\n" );
        #Make the dir. where the submission will first be unpacked.
        #That may result in subdirs being unpacked, and building and testing might
        #be done in one of those subdirs.  In that case, $TestCompileDir will be 
        #changed.  No harm since it's the script is run from the beginning
        #for each submission.
	# mode 0700 begins with 0 to tell perl it is in octal
    }	

    my($Good) = 1;
    foreach $t (@exenames)
    {
	print "trying $t\n";
	if( -x $t )
	{
	    system("mv $t $TestCompileDir");
	    print "Moved executable file $t OK!\n";
	    print GROUT "Your build script built $t successfully.\n";
	}
	else 
	{ 
	    $Good = 0;
	    print "TA:$t not built by build.sh\n";
	}
    }
    return $Good;
}

    

# --------doManualBuild--------------------------------------------------

sub doManualBuild
{

    if( not -d $TestCompileDir) 
    {
	mkdir($TestCompileDir,0770) || die( "Cannot mkdir $TestCompileDir\n" );
        #Make the dir. where the submission will first be unpacked.
        #That may result in subdirs being unpacked, and building and testing might
        #be done in one of those subdirs.  In that case, $TestCompileDir will be 
        #changed.  No harm since it's the script is run from the beginning
        #for each submission.
	# mode 0700 begins with 0 to tell perl it is in octal
    }	

    chdir $TestCompileDir;    
    my($success);
    print 
"TA:Suspend/use other window:
    EXAMINE submission\n";
    #print " co RCS things(rcs -M -u file; co -l file;)\n";
    print
"   and then try to build the software";

#    if( $TestCompileDir ne $TestCWD )
#    {
	print " into $TestCompileDir";
#    }	


    if( $BuildScriptRequested )
    {
	print " with build.sh.., etc";
    }
    print "\nPress <enter> to continue..\n";
    my($dummy);
    chop($dummy=<STDIN>);
       

    if( $RequiresCompiling )
    {
	if( !askYes "TA:Will you be able to test this submission?" )
	{
	    print GROUT  
		"TA could not compile/link any of your submitted work.\n";
	    print 
		"TA: Please C-Z, run cat > $CompileMessageFile, copy/paste compile errors\n".
	 "(or edit appropriate messages into $CompileMessageFile)\n".
	     "then press <enter> to continue..";
	    chop($dummy=<STDIN>);
	    $success = 0;
	}
	else
	{
	    $success = 1;
	    if( askYes "TA: Did do any debugging or other manual fixes?" )
	    {
		TAWriteComment();
		print 
   "TA: Enter penalty for work done to program testable(up to 20 points):";
		$AssessedManualBuildPenalty = getNumber(0.0,20.0);
		print GROUT "Deduction for TA's work to make your program testable:"
		    ." $AssessedManualBuildPenalty Points\n";
		$Score = $Score - $AssessedManualBuildPenalty;
	   }
	}
    }

    if(open(GPP, "<$CompileMessageFile"))
    {
	while ($gpp_line = <GPP>) 
	{
	    print GROUT "   $gpp_line";
	}
	close(GPP);
    }
    if( $success == 0 ) {print GROUT  "Grading effort done...\n";}
    return $success;
}

# --------end of doManualBuild------------------------------------------

# --------tryBuildWithCommand---------------------------------------------

sub tryBuildWithCommand
{
    chdir ( $TestCompileDir );

    print "We are running $GradersBuildCommand...\n";
    my $compileOutput = `$GradersBuildCommand`;
    my $status = $?;
    print "It outputted:";
    print "$compileOutput\n";
    print "Command returned status:$status\n";

    #See if submission can be unit tested.
    #Hard coded below for project 2.  Must generalize in the future!

    if($status == 0)
    {
#	if( ! doesSignatureExistInClass(
#	    $TestCompileDir, "public void vignette();", "Picture"))
#	    $TestCompileDir, "public void changeWhole(double);", "Picture"))
#	{
#	    print "TA: You'll have to work in $TestCompileDir soon.\n";
#	    $status = $status + 1;
#	}
    }
    if ($status == 0)
    {    
#	print  GROUT "--- Compilation successful: $compileOutput\n";
	scoreMakeSuccess();
	$success=1; #true 
    } 
    else 
    {
	print "\n\nComputer guessed compilation failed. Try manually.\n";
	if($ManualBuildFixMessage){print $ManualBuildFixMessage;}
       
	if(askYes("Try to compile...successful?")==1)
	{
	    print  GROUT "--- Computer guessed compilation failed.\n";
	    print  GROUT "--- TA's manual compilation successful.\n";
	    scoreMakeSuccess();
	    $success=1; #true 
	}
	else
	{
	    print GROUT  "Could not generate the files \n";
	    print GROUT $filesWeBuild;
	    print GROUT "\n from your submission.\n";
	    print GROUT "--- Computer-guessed and manual comilation attempts failed.\n";
	    print GROUT "--- Compilation errors:\n----\n$compileOutput ---\n";

	    if(open(GPP, "<$CompileMessageFile"))
	    {
		print GROUT "--- Other Compile command output:\n";
		while ($gpp_line = <GPP>) 
		{
		    print GROUT "   $gpp_line";
		}
		close(GPP);
	    }
	    print GROUT  "Grading effort done...\n";
	    $success=0;
	}
    }
    return( $success );
}


sub tryMakefile
{
    chdir ( $TestCompileDir );
    if ( findMakefile() )
    {
       $compile_command = "gmake $exeName > $MakeMessageFile 2>&1";
       print "running ... $compile_command\n";
       system( $compile_command );
       if(-e $exeName )
       {
	   print "Submitted Makefile worked.\n";
	   scoreMakeSuccess();
	   return( 1 );
       }
       else
       {
	   scoreMakeFailure();
	   if( -f $MakeMessageFile )
	   { 
	       open( MSGFILE , "<$MakeMessageFile" );
	       while ($mess_line = <MSGFILE>) 
	       {
	#	   print GROUT "   $mess_line";
		   print       "$mess_line";
	       }
	       close(MSGFILE);
	   }
	   return( 0 );
       }
   }
}


# --------------------------------------------------------------------------

sub findMakefile
{
    chdir ( $TestCompileDir );
    my($success);
    $success = 0;
    
    if ( $verbose ) { print "Searching for makefile\n"; }
    
    $source_name1="Makefile";
    $source_name2="makefile";
    
    if (-e $source_name1) 
    {
        $success=1; #  true
    }
    else 
    {
	if (-e $source_name2)
	{
            $success=1; # true
	}
    }
    if( $success )
    {
	print "M[m]akefile found.\n";
	print GROUT "M[m]akefile found.\n";
    }
    else
    {
	print "M[m]akefile not found.\n";
	print GROUT "M[m]akefile not found.\n";
    }
    return ( $success );
}


#--------------------------------------------------------------------------

sub SetDueTime ($$$$$)
{
    #Input: 
    my($DUEyear) = $_[0];
    my($DUEmon) =  $_[1];
    my($DUEmday) = $_[2];
    my($DUEhour) = $_[3];
    my($DUEmin) = $_[4];
    #Result: returns $DUEtime is set to seconds past the epoch corresponding to the Input

    # Crude function estimates seconds past epoch of specified due date
    # Uses successive halving to find a due date
    # Operates like C function mktime

    my ($lefttime)  = 0;
    my ($righttime) = 1.1*time();  #so we can convert some future times too!

    my($DUEtime) = int ( (($lefttime+$righttime)/2.0)+0.5 );

    my(($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst))=
	localtime($DUEtime);

    do
    {
	if ( 
	    ($year>$DUEyear) ||
	    ( ($year==$DUEyear) && ($mon>$DUEmon) ) ||
	    ( ($year==$DUEyear) && ($mon==$DUEmon) && ($mday>$DUEmday) ) ||
	    ( ($year==$DUEyear) && ($mon==$DUEmon) && ($mday==$DUEmday) && 
	     ($hour>$DUEhour) ) ||
	    ( ($year==$DUEyear) && ($mon==$DUEmon) && ($mday==$DUEmday) && 
	     ($hour==$DUEhour) && ($min>$DUEmin) ) ||
	    ( ($year==$DUEyear) && ($mon==$DUEmon) && ($mday==$DUEmday) && 
	     ($hour==$DUEhour) && ($min==$DUEmin) && ($sec>0) ) )
	{
	    $righttime = $DUEtime;
	}
	else
	{
	    $lefttime = $DUEtime;
	}
	     
	$DUEtime=int( (($righttime+$lefttime)/2.0)+0.5 ) ;

#	select (STDOUT); $| = 1;  #make STDOUT unbuffered for spin counter.
#	print "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b$DUEtime";
	
	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=
	    localtime($DUEtime);
    }
    until ( ($min==$DUEmin) && ($hour==$DUEhour) && ($mday==$DUEmday) &&
	   ($mon==$DUEmon) && ($year==$DUEyear) && ($sec==0) );

    return $DUEtime;

}

#--------------------------------------------------------------------------

sub scoreInit($)
{
    $Score = 0;
    print SUMOUT $_[0], " ", lookupUserName($_[0]), " ";
}

sub scoreReport($)
{
    $Score = $Score + $valueReportTotal*$_[0];
   print GROUT "Points for $ReportLikeFile: ", 
	   $_[0]*$valueReportTotal, "/", $valueReportTotal, "\n";
}

sub scoreMakeSuccess()
{
    if($MakefilePoints) 
    {
	print GROUT "Rate working makefile (-0.5 for say, a wrong target)\n";
	print       "Rate working makefile (-0.5 for say, a wrong target)";
	if($SimpleMakefileRequired) { 
	    print GROUT "\n required to be simple\n";
	    print       "\n required to be simple";
	}    
	print ":";
	$value = getNumber(0.0, 1.0);
	scoreThisQualityOutof
	    "Makefile",
	    $value,
	    $MakefilePoints;
    }
}

sub scoreMakeFailure()
{
    print GROUT "Submitted M[m]akefile did not produce successful build:\n";
}

sub scoreManualCompile()
{
}

sub scoreStartTestCases($$)
{
    my($value) = $_[1];
    $numTests = $_[0];
    if($verbose){print "Number of tests counted is: ", $numTests, "\n";}
    $valuePerTest = $value / $numTests;
    $valuePerTestrounded = int ( ($valuePerTest*10.0)+.5 ) / 10.0 ;

    if($verbose) {print "Value Per test is:", $valuePerTest, "\n";}
}

sub scoreOneTestAddorSubPoints($$$)
{
    my($name) = $_[0];
    my($rating) = $_[1]; #Between 0 and 1
    my($value) = $_[2];  #Max points for this, penalty if neg.
    #if value < 0, penalty subtracted is (1-rating)*value.
    my($points);         #to be Added to $Score, (pos or neg)
    if( $value > 0.0 )
    {
	$points = $value*$rating;
	print GROUT 
	"Test $name rated ", $rating*100.0, "\% for ", 
	int(($points*10.0)+.5)/10.0,
	" out of ", $value, " points\n"; 
	$Score = $Score + $points;
    }
    else
    {
	if($rating != 1.0)
	{
	    my($penaltyfrac) = 1.0 - $rating;
	    $points = $value*$penaltyfrac;
	    print GROUT 
		"Penalty of ", $penaltyfrac*100.0, "\% from Test $name result,
to subtract ",	int(((-$points)*10.0)+.5)/10.0,
		" out of ", -$value, " points\n"; 
	    $Score = $Score + $points;
	}
    }
}


sub scoreOneTest($$)
{
    my($name) = $_[0];
    my($rating) = $_[1];
    my($points) = $valuePerTest*$_[1];

    print GROUT 
	"Test $name rated ", $_[1]*100.0, "\% for ", 
	int(($points*10.0)+.5)/10.0,
	" out of ", $valuePerTestrounded, " points\n"; 

    $Score = $Score + $valuePerTest*$_[1];
}

sub scoreCheckLate()
{
    
    my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst);
	
    #my(($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
	#$atime,$mtime,$ctime,$blksize,$blocks)) = stat($_[0]);

    my($mtime) = submissionTime($_[0]);

    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime($mtime);

    $year = $year - 100;
    $mon = $mon + 1;

    print "File mod. date is       : ", $mtime,    " - ",
    $mon, "/", $mday, "/", $year, " ", $hour, ":", $min, ":", $sec, "\n";

    my($dispYear,$dispmon);
    $dispYear = $DUEyear - 100;
    $dispmon = $DUEmon + 1;

    print "The no-late due date is : ", $DUEtime, " - ",
    $dispmon, "/", $DUEmday, "/", $dispYear, " ", $DUEhour, ":", $DUEmin, ":",
    "00\n\n";

    my($latedays,$is_early);

    if ( $mtime <= $EARLYtime )
    {
	$is_early = 1;
	$latedays = 0;
    }
    else
    {
	$is_early = 0;
	if( $mtime < $DUEtime )
	{
	    $latedays = 0;
	}
	else
	{
	    $latedays = ($mtime-$DUEtime)/(60.0*60.0*24.0);
	}
    }
    
    print "Before Late-Check Score : ", $Score,    "\n";
    print "Number of Days Late     : ", $latedays, "\n";

    my($ScoreRounded) = int(($Score*10)+0.5)/10.0;

    print GROUT 
	"\n\nScore before deducting points for lateness: ", $ScoreRounded,"\n";
    print SUMOUT $ScoreRounded, " ";

    my($LateMod)=1.0;

    if ( $is_early )
    { 
	if( $DUEearlyBonusFactor != 1.0 )
	{
	    print GROUT "Your project was turned in early!\n";	    
	    print GROUT "Your grade multiplied by $DUEearlyBonusFactor is ";
	    $ScorePenalized = $Score * $DUEearlyBonusFactor;
	    $ScorePenalized = int(($ScorePenalized*10)+0.5)/10.0;	
	    print GROUT  
		" $ScorePenalized  points.\n\n";
	    print SUMOUT $ScorePenalized, "\n";
	}
	else
	{
	    print GROUT "Your project was turned in on time.\n";
	    print GROUT  
	"\n\nTotal score for this project: ", $ScoreRounded, " points.\n\n";
	    print SUMOUT $ScoreRounded, "\n";
	}
    }
    else
    { 
	print GROUT 
	    "Your project was turned in approximately ", 
	    int(($latedays*1000)+.5)/1000.0, " days late.\n";

	if ( $latedays <= $DUEmaxdayslate )
	{
	    $LateMod = 1.0 - (($latedays)*(1.0/$DUEDaysPer100PercentOff));    
	    print GROUT
		"Grade multiplied by approximately ", 
		int(($LateMod*1000)+.5)/1000.0, "\n";
	}
	else
	{
	    print GROUT 
		"Your project was turned in too late to receive credit.\n";
	    $LateMod = 0.0;
	}

	$ScorePenalized = $Score * $LateMod;
	$ScorePenalized = int(($ScorePenalized*10)+0.5)/10.0;	
	print GROUT  
	"\n\nTotal score for this project: ", $ScorePenalized, " points.\n\n";
	print SUMOUT $ScorePenalized, "\n";
    }

}

sub scoreDone()
{
    if ( $CheckPrevYearCase == 1 )
    {
	my($checklastyear)=0;
	
	print "\nDid ouput using last year's spec look suspicious? ";
	print "\nValue will be truncated w/ 0=No, 1=Yes : ";
	$checklastyear=int(getNumber(0.0,1.0));
	
#	if ($checklastyear==1)
#	{
#	    print NOINTEGOUT $UserId, " Accepted Last Year's Spec\n";
#	    print GROUT 
#		"\nSuspicious looking output when used last year's spec\n";
#	    print GROUT "This has been reported to $Professor.\n\n";
#	}

    }
    
}


#--------------------------------------------------------------------------

sub runTestCasesPhase1
{
    #removed
    die "runTestCasesPhase1 was Removed\n";
}

#--------------------------------------------------------------------------


sub runInteractiveTestCases($$$)
{
    print "\n\nrunInteractiveTestCases: $_[0] $_[1] $_[2]\n\n";


    my($InteractiveTestCaseDir) = $_[0];
    my($exeName) = $_[1];
    my($valueInteractiveTests) = $_[2];

    print "\n\nrunInteract... our cwd is " . cwd( ) . "\n\n";

    chdir($InteractiveTestCaseDir);
# project specific file installation here

    my( @TestInFiles ) = <*.txt>; # Glob wildcard

    print "SEEEE--- $TestInFiles[0] should be a .txt file";

#   (@TestInFiles + 0) puts the array in a "numeric context"
#   where it will be evaluated to its length.  Sorry Ed. Dj.
    if ( @TestInFiles == 0)
    {
	return;
    }
    scoreStartTestCases( @TestInFiles + 0 , $valueInteractiveTests);



    $GLOBALtestnum = 0;
    my($testFileName_txt);   #file containing test explanation
    # name xxxx.txt must be found in test case directory

    my($testName);
    # name xxxx

    $TAHaltedTesting = 0;
    foreach $testFileName_txt (@TestInFiles) 
    {
	if( $TAHaltedTesting ) 
	{
	    last;
	}
	$GLOBALtestnum = $GLOBALtestnum + 1;

	$testName = $testFileName_txt;
	$testName =~ s/\.txt//;
	print 
	"\n->->->->->Begin test($GLOBALtestnum): $testName\n";

	
	scoreOneTest( $testName, 
		      GradeInteractiveCase(
					   $TestCompileDir,
					   $exeName,
					   $InteractiveTestCaseDir,
					   $testName));

    }
    print "Exiting runInteractiveTestCases !!!!!!\n";
}

#################################################################################

sub runOneAutomaticTestReturnRating($)
{

    chdir( $TestCompileDir );
    
    #RETURNS THE RATING between 0 and 1
    my($rating);
    
    my($testFileName_stdout);  #file containing reference standard output
    # name xxxx.out must be found in test case directory
    $testFileName_stdout = $_[0];

    my($testName);
    # name xxxx

    my($testFileName_cmd);      #file containing command to run
    # name xxxx.cmd must be found in test case directory

    my($testFileName_stdin);    #file to redirect standard input
    # name xxxx.in may be found in test case directory

    my($resultFileName_stdout); #file to put student stdout
    # redirect stdout to name xxxx.out in working dir

    my($testFileName_outfname);   #ref.  output file named on the command line
    # name xxxx.outfname may be found in test case directory

    my($resultFileName_outfname); #stud. output file named on the command line
    # student pgm should create xxxx.outfname in work dir.

    my($testFileName_infname);   #test input file named on command line
    # name xxxx.infname or xxx.infsuffix may be found in test case directory
    # If it exists, it should be copied to the work dir, to avoid 
    # crashing student programs by giving them long pathnames.

    my($testFileName_txt);      #Explanation, policy, etc for test
    # name xxxx.txt may be found in test case directory
    # If it exists, it should be displayed to the TA when there are 
    # output differences.

    my($testFileName_filter);   #Filter to run on test's standard output
    # name xxxx.flt may be found in test case directory
    # If it exists, test output should be run through it. 

    my($truncName);             #Name of file to hold truncated student stdout
    # name xxxx.out.trunc may be found in work directory

print 
	"\nBegin test based on ref. output file:\n$testFileName_stdout\n";

#	unlink(<"$error_file">);
#	unlink(<"$a_output">);

	$testFileName_stdin = $testFileName_stdout;  # copy string first
	$testFileName_stdin =~ s/\.out/\.in/;    # now substitute .in for .out
	$testFileName_txt = $testFileName_stdout;  # copy string first
	$testFileName_txt =~ s/\.out/\.txt/;    # now substitute .txt for .out
	$testFileName_cmd = $testFileName_stdout;  # copy string first
	$testFileName_cmd =~ s/\.out/\.cmd/;    # now substitute .cmd for .out
	$testFileName_outfname = $testFileName_stdout; # copy string first
	$testFileName_outfname =~s/\.out/\.outfname/;
	$testFileName_filter = $testFileName_stdout;  # copy string first
	$testFileName_filter =~ s/\.out/.flt/;  # now substitute .flt for .out

	if( -e $testFileName_outfname )
	{
	    $resultFileName_outfname = $testFileName_outfname;  # copy 1st
	    $resultFileName_outfname =~ s#.*/##;    # delete all but last comp.
	}
	else
	{   
	    $resultFileName_outfname = "";
	    $testFileName_outfname = "";
	}

	my($test_command);
	# Get the user's output file name
	$resultFileName_stdout = $testFileName_stdout;    # copy first
	# Create the local output file name by removing the path.
	# This makes it the same name, but in the cwd.
	$resultFileName_stdout =~ s#.*/##;                  # substitute

	$testName = $resultFileName_stdout;   #copy
	$testName =~ s#\.out##;            #root of test file name
	$truncName = "$resultFileName_stdout".".trunc";
	$testFileName_root = "$testFileName_stdout";  # copy string first
	$testFileName_root =~ s#\.out##;   #remove .out extension
	if( defined $infsuffix )
	{
	    $testFileName_infname = "$testFileName_root".".$infsuffix";	    
	}	    
	else
	{
	    $testFileName_infname = "$testFileName_root".".infname";
	}	
#    project specific:  copy an input file into the test dir
	print GROUT "\n\n";  ##Starting a new test case
	if( -e $testFileName_infname )
	{
	    system("cp $testFileName_infname $TestCompileDir");
	    print GROUT 
"--- Copying input file:  ".URLize($testFileName_infname)."\n";
	}

	# Run it, filtering if necessary
	#
	my($cmdlineArgs) = "";

	# check for command line arg file here 
	if( $verbose ) {print "testFileName_cmd=$testFileName_cmd\n\n";}

	if( -e $testFileName_cmd )
	{
	    #and read it into $cmdlineArgs if it exists 
	    $test_command = read_first($testFileName_cmd);
	    print GROUT 
"--- Test cmd file:    ". URLize($testFileName_cmd) . "\n";
	    if( -e $testFileName_stdin )
	    {
		print GROUT     
"--- Test stdin file:  ". URLize($testFileName_stdin) . "\n";
		$test_command = "( $test_command ) < $testFileName_stdin";
	    }
	}
	else
	{
	    $test_command = $exeName;
	    if( -e $testFileName_stdin )
	    {
		print GROUT     
"--- Test stdin file:  ". URLize($testFileName_stdin)."\n";
		$test_command = "( $test_command ) < $testFileName_stdin";
	    }
	}

	print GROUT     
"--- Test command:     ".URLize($test_command)."\n";
	print GROUT     
"--- Ref stdout file:  ".URLize($testFileName_stdout)."\n";
	if( $testFileName_outfname ne "" ) {
	print GROUT     
"--- Ref named outfile:".URLize($testFileName_outfname)."\n";
        }
	

	$test_command = 
"(ulimit -S -t 5; ulimit -S -f 10;  $test_command  > $resultFileName_stdout 2>&1 )";

    # Bourne shell sh is used.  
    # limit cpu time to 5 seconds
    # limit file sizes to 10*512 bytes


#	$test_command = "($test_command < $testFileName_infname) | ($ProjGradingDir/limpipe $LimitPipeInBytes) > $resultFileName_stdout ";
#	$test_command = "($test_command ) | (grep OK ) > $resultFileName_stdout 2>&1";

#	my($ender) = "$ProjGradingDir/ender";
#	$test_command = "($ender $test_command < $testFileName_stdin) | (grep OK ) >& $resultFileName_out";


	print "Running $test_command\n";

#	print GROUT "--- Test run \"$test_command\"\n";

	my($test_return) = system($test_command);

#	if ($test_return) 
#	{
#	    print "--- Error running $bin_name on $test_in ($test_return)\n";
#	    print GROUT "--- Error running $bin_name on $test_in ($test_return)\n";
#	}


	my($resultFileName_diff) = $resultFileName_stdout;
	$resultFileName_diff =~  s/\.out/\.diff/;
	if( $testFileName_outfname ne "" ) 
	{
	    # project specific
	    # If we are checking a file that the student program
	    #  creates by name, test it for exact content equality,
	    #  because the CSI333 TMIPS project wrote binary named files.


	    my( $diffCommandBinary ) = "/usr/local/bin/diff";
	    my( $diffRunLine )  = 
		"$diffCommandBinary $testFileName_outfname $resultFileName_outfname "
		    . "> $resultFileName_diff 2>&1";

	    print "Diffing with $diffRunLine\n";
	    $diff_return = system($diffRunLine);
	    
	    #  Add points for the matches
	    unless ($diff_return)
	    {
		print  "--- Matched! \n";
		$rating = 1.0;
	    }
	    else 
	    {
		print  "--- Binary files differed..\n";
               # Project specific: if binary files differ, give 0.

		# Show the diff output
		print GROUT "\n--- Output from $diffCommandBinary :\n";
		print GROUT "line nums\n< <reference>\nline nums\n> Student program output
---\nmore differences...\n";


		open(DIFF, "<$resultFileName_diff");
		my( $maxlines ) = 20;
		while (defined($diff_line = <DIFF>) && ( $maxlines ne 0)) 
		{
		    print GROUT "   $diff_line";
		    $maxlines = $maxlines - 1;
		}
		close (DIFF);
		print GROUT "--- This shows binary files differ\n";
		$rating = 0;
	    }

	}
	else
	{
	    #
	    # We are comparing the standard output of student program
	    #  with reference standard output.
	    #

	    `wc -l $testFileName_stdout` =~ /(\d+)/;  #Count lines in reference output file.
	    my($taillen) = 2*$1 + 256;     #Calculate double that number of lines.
	    #Plus extra..just in case
	    
	    system("tail -$taillen < $resultFileName_stdout > $truncName.t");

	    #If the file doesn't end with \n, recreate it with \n appended.
	    # This is to remove a warning message printed by diff
	    if( `tail -1c $truncName.t` ne "\n" )
	    {
		system("echo \"\" | cat $truncName.t - > $truncName ");
		system("rm $truncName.t");
		# append a newline to stop print from printing a warning.
	    }
	    else
	    {
		system("mv $truncName.t $truncName");
	    }
	    my($diff_run_line) = 
		"$diffCommand $testFileName_stdout $truncName "
		    . "> $resultFileName_diff 2>&1";

	    print "Diffing with $diff_run_line\n";
	    $diff_return = system($diff_run_line);
	    
	    #  Add points for the matches
	    unless ($diff_return)
	    {
		print  "--- Matched! \n";
		$rating = 1.0;

	    }
	    else 
	    {
               # Check to see if student result is acceptable although there are
               #   differences with the reference stdout.

		print "TA: rate student program's standard output: $resultFileName_stdout\n";

		if($verbose){print 
	  "\n\nscriptly.pl debug: filter=$testFileName_filter\n\n";}

		if( -e $testFileName_filter )
		{
		    $rating = ManualFilterRate($resultFileName_stdout,
						   $resultFileName_diff,
						   $testFileName_txt,
						   $testFileName_filter);

		    if ($rating == 1.0 )
		    {
			print GROUT "--- Output accepted by TA\n ";
		    }
		    else 
		    {
			if($rating == 0 and askYes("TA:Want to halt testing?"))
			{
			    $TAHaltedTesting = 1;
			}
			print GROUT "--- Your program's output(truncated):\n";
			
			# Put student output into his/her report
			open (USEROUT, "<$truncName")
			    || die "Can't open $truncName.\n";
			chmod 0660, $truncName;
			while ($line = <USEROUT>) 
			{
			    print  GROUT "   $line";
			}
			close (USEROUT);
			
			# Put in the TA instructions if any.
			if(open(TXT, "<$testFileName_txt") )
			{
			    print GROUT 
"\n--- Our grading policy from ".URLize($testFileName_txt)." :\n";
			    while ($line = <TXT>) 
			    {
				print GROUT "   $line";
			    }
			    close (TXT);
			}

		    }
#		    scoreOneTest( $testName, $rating );
		}
		else
		{
		    $rating = ManualRate($resultFileName_stdout,
					     $resultFileName_diff,
					     $testFileName_txt);
		    if ($rating == 1.0 )
		    {
			print GROUT "--- Output accepted by TA\n ";
		    }
		    else 
		    {
			if($rating == 0 and askYes("TA:Want to halt testing?"))
			{
			    $TAHaltedTesting = 1;
			}
			print GROUT "--- Your program's output:\n";
			
			# Show student output from the test case
			open (USEROUT, "<$resultFileName_stdout")
			    || die "Can't open $resultFileName_stdout\n";
			chmod 0660, $resultFileName_stdout;
			while ($user_line = <USEROUT>) 
			{
			    print  GROUT "   $user_line";
			}
			close (USEROUT);
			
			# Show the diff output
			print GROUT "\n--- Output from $diffCommand :\n";
			open(DIFF, "<$resultFileName_diff");
			while ($diff_line = <DIFF>) 
			{
			    print GROUT "   $diff_line";
			}
			close (DIFF);
			# Put in the TA instructions if any.
			if( open(TXT, "<$testFileName_txt") )
			{
			    print GROUT 
"\n--- Our grading policy from ".URLize($testFileName_txt)." :\n";
			    while ($line = <TXT>) 
			    {
				print GROUT "   $line";
			    }
			    close (TXT);
			}
		    }
		}
	    }
	}
    return ($rating);
}


sub runTestCasesPhase2
{
    chdir( $TestCompileDir );

# project specific file installation here

    my( @TestInFiles ) = <$TestCaseDirPhase2/*.out>; # Glob wildcard

#   (@TestInFiles + 0) puts the array in a "numeric context"
#   where it will be evaluated to its length.  Sorry Ed. Dj.
    scoreStartTestCases( @TestInFiles + 0 , $valueTestsPhase2);


    if ( @TestInFiles == 0)
    {
	return;
    }

    $GLOBALtestnum = 0;
    my($testFileName_stdout);   #file containing reference standard output
    # name xxxx.out must be found in test case directory

    my($testName);
    # name xxxx

    my($testFileName_cmd);      #file containing command to run
    # name xxxx.cmd must be found in test case directory

    my($testFileName_stdin);    #file to redirect standard input
    # name xxxx.in may be found in test case directory

    my($resultFileName_stdout); #file to put student stdout
    # redirect stdout to name xxxx.out in working dir

    my($testFileName_outfname);   #ref.  output file named on the command line
    # name xxxx.outfname may be found in test case directory

    my($resultFileName_outfname); #stud. output file named on the command line
    # student pgm should create xxxx.outfname in work dir.

    my($testFileName_infname);   #test input file named on command line
    # name xxxx.infname or xxx.infsuffix may be found in test case directory
    # If it exists, it should be copied to the work dir, to avoid 
    # crashing student programs by giving them long pathnames.

    my($testFileName_txt);      #Explanation, policy, etc for test
    # name xxxx.txt may be found in test case directory
    # If it exists, it should be displayed to the TA when there are 
    # output differences.

    my($testFileName_filter);   #Filter to run on test's standard output
    # name xxxx.flt may be found in test case directory
    # If it exists, test output should be run through it. 

    my($truncName);             #Name of file to hold truncated student stdout
    # name xxxx.out.trunc may be found in work directory

    $TAHaltedTesting = 0;
    foreach $testFileName_stdout (@TestInFiles) 
    {
	if( $TAHaltedTesting ) 
	{
	    last;
	}
	$GLOBALtestnum = $GLOBALtestnum + 1;
	print 
	"\nBegin test($GLOBALtestnum):\n ref. output: $testFileName_stdout\n";

#	unlink(<"$error_file">);
#	unlink(<"$a_output">);

	$testFileName_stdin = $testFileName_stdout;  # copy string first
	$testFileName_stdin =~ s/\.out/\.in/;    # now substitute .in for .out
	$testFileName_txt = $testFileName_stdout;  # copy string first
	$testFileName_txt =~ s/\.out/\.txt/;    # now substitute .txt for .out
	$testFileName_cmd = $testFileName_stdout;  # copy string first
	$testFileName_cmd =~ s/\.out/\.cmd/;    # now substitute .cmd for .out
	$testFileName_outfname = $testFileName_stdout; # copy string first
	$testFileName_outfname =~s/\.out/\.outfname/;
	$testFileName_filter = $testFileName_stdout;  # copy string first
	$testFileName_filter =~ s/\.out/.flt/;  # now substitute .flt for .out

	if( -e $testFileName_outfname )
	{
	    $resultFileName_outfname = $testFileName_outfname;  # copy 1st
	    $resultFileName_outfname =~ s#.*/##;    # delete all but last comp.
	}
	else
	{   
	    $resultFileName_outfname = "";
	    $testFileName_outfname = "";
	}

	my($test_command);
	# Get the user's output file name
	$resultFileName_stdout = $testFileName_stdout;    # copy first
	# Create the local output file name by removing the path.
	# This makes it the same name, but in the cwd.
	$resultFileName_stdout =~ s#.*/##;                  # substitute

	$testName = $resultFileName_stdout;   #copy
	$testName =~ s#\.out##;            #root of test file name
	$truncName = "$resultFileName_stdout".".trunc";
	$testFileName_root = "$testFileName_stdout";  # copy string first
	$testFileName_root =~ s#\.out##;   #remove .out extension
	if( defined $infsuffix )
	{
	    $testFileName_infname = "$testFileName_root".".$infsuffix";	    
	}	    
	else
	{
	    $testFileName_infname = "$testFileName_root".".infname";
	}	
#    project specific:  copy an input file into the test dir
	print GROUT "\n\n";  ##Starting a new test case
	if( -e $testFileName_infname )
	{
	    system("cp $testFileName_infname $TestCompileDir");
	    print GROUT 
"--- Copying input file:  ".URLize($testFileName_infname)."\n";
	}

	# Run it, filtering if necessary
	#
	my($cmdlineArgs) = "";

	# check for command line arg file here 
	if( $verbose ) {print "testFileName_cmd=$testFileName_cmd\n\n";}

	if( -e $testFileName_cmd )
	{
	    #and read it into $cmdlineArgs if it exists 
	    $test_command = read_first($testFileName_cmd);
	    print GROUT 
"--- Test cmd file:    ".URLize($testFileName_cmd)."\n";
	    if( -e $testFileName_stdin )
	    {
		print GROUT     
"--- Test stdin file:  ".URLize($testFileName_stdin)."\n";
		$test_command = "( $test_command ) < $testFileName_stdin";
	    }
	}
	else
	{
	    $test_command = $exeName;
	    if( -e $testFileName_stdin )
	    {
		print GROUT     
"--- Test stdin file:  ".URLize($testFileName_stdin)."\n";
		$test_command = "( $test_command ) < $testFileName_stdin";
	    }
	}

	print GROUT     
"--- Test command:     ".URLize($test_command)."\n";
	print GROUT     
"--- Ref stdout file:  ".URLize($testFileName_stdout)."\n";
	if( $testFileName_outfname ne "" ) {
	print GROUT     
"--- Ref named outfile:".URLize($testFileName_outfname)."\n";
        }
	

	$test_command = 
"(ulimit -S -t 5; ulimit -S -f 10;  $test_command  > $resultFileName_stdout 2>&1 )";

    # Bourne shell sh is used.  
    # limit cpu time to 5 seconds
    # limit file sizes to 10*512 bytes


#	$test_command = "($test_command < $testFileName_infname) | ($ProjGradingDir/limpipe $LimitPipeInBytes) > $resultFileName_stdout ";
#	$test_command = "($test_command ) | (grep OK ) > $resultFileName_stdout 2>&1";

#	my($ender) = "$ProjGradingDir/ender";
#	$test_command = "($ender $test_command < $testFileName_stdin) | (grep OK ) >& $resultFileName_out";


	print "Running $test_command\n";

#	print GROUT "--- Test run \"$test_command\"\n";

	my($test_return) = system($test_command);

#	if ($test_return) 
#	{
#	    print "--- Error running $bin_name on $test_in ($test_return)\n";
#	    print GROUT "--- Error running $bin_name on $test_in ($test_return)\n";
#	}


	my($resultFileName_diff) = $resultFileName_stdout;
	$resultFileName_diff =~  s/\.out/\.diff/;
	if( $testFileName_outfname ne "" ) 
	{
	    # project specific
	    # If we are checking a file that the student program
	    #  creates by name, test it for exact content equality,
	    #  because the CSI333 TMIPS project wrote binary named files.


	    my( $diffCommandBinary ) = "/usr/local/bin/diff";
	    my( $diffRunLine )  = 
		"$diffCommandBinary $testFileName_outfname $resultFileName_outfname "
		    . "> $resultFileName_diff 2>&1";

	    print "Diffing with $diffRunLine\n";
	    $diff_return = system($diffRunLine);
	    
	    #  Add points for the matches
	    unless ($diff_return)
	    {
		print  "--- Matched! \n";
		scoreOneTest( $testName, 1.0 );
	    }
	    else 
	    {
		print  "--- Binary files differed..\n";
               # Project specific: if binary files differ, give 0.

		# Show the diff output
		print GROUT "\n--- Output from $diffCommandBinary :\n";
		print GROUT "line nums\n< <reference>\nline nums\n> Student program output
---\nmore differences...\n";


		open(DIFF, "<$resultFileName_diff");
		my( $maxlines ) = 20;
		while (defined($diff_line = <DIFF>) && ( $maxlines ne 0)) 
		{
		    print GROUT "   $diff_line";
		    $maxlines = $maxlines - 1;
		}
		close (DIFF);
		print GROUT "--- This shows binary files differ\n";
		scoreOneTest( $testName, 0 );
	    }

	}
	else
	{
	    #
	    # We are comparing the standard output of student program
	    #  with reference standard output.
	    #

	    `wc -l $testFileName_stdout` =~ /(\d+)/;  #Count lines in reference output file.
	    my($taillen) = 2*$1 + 256;     #Calculate double that number of lines.
	    #Plus extra..just in case
	    
	    system("tail -$taillen < $resultFileName_stdout > $truncName.t");

	    #If the file doesn't end with \n, recreate it with \n appended.
	    # This is to remove a warning message printed by diff
	    if( `tail -1c $truncName.t` ne "\n" )
	    {
		system("echo \"\" | cat $truncName.t - > $truncName ");
		system("rm $truncName.t");
		# append a newline to stop print from printing a warning.
	    }
	    else
	    {
		system("mv $truncName.t $truncName");
	    }
	    my($diff_run_line) = 
		"$diffCommand $testFileName_stdout $truncName "
		    . "> $resultFileName_diff 2>&1";

	    print "Diffing with $diff_run_line\n";
	    $diff_return = system($diff_run_line);
	    
	    #  Add points for the matches
	    unless ($diff_return)
	    {
		print  "--- Matched! \n";
		scoreOneTest( $testName, 1.0 );
	    }
	    else 
	    {
               # Check to see if student result is acceptable although there are
               #   differences with the reference stdout.

		print "TA: rate student program's standard output: $resultFileName_stdout\n";

		if($verbose){print 
	  "\n\nscriptly.pl debug: filter=$testFileName_filter\n\n";}

		if( -e $testFileName_filter )
		{
		    my($rating) = ManualFilterRate($resultFileName_stdout,
						   $resultFileName_diff,
						   $testFileName_txt,
						   $testFileName_filter);

		    if ($rating == 1.0 )
		    {
			print GROUT "--- Output accepted by TA\n ";
		    }
		    else 
		    {
			if($rating == 0 and askYes("TA:Want to halt testing?"))
			{
			    $TAHaltedTesting = 1;
			}
			print GROUT "--- Your program's output(truncated):\n";
			
			# Put student output into his/her report
			open (USEROUT, "<$truncName");
			while ($line = <USEROUT>) 
			{
			    print  GROUT "   $line";
			}
			close (USEROUT);
			
			# Put in the TA instructions if any.
			if(open(TXT, "<$testFileName_txt") )
			{
			    print GROUT 
"\n--- Our grading policy from ".URLize($testFileName_txt)." :\n";
			    while ($line = <TXT>) 
			    {
				print GROUT "   $line";
			    }
			    close (TXT);
			}

		    }
		    scoreOneTest( $testName, $rating );
		}
		else
		{
		    my($rating) = ManualRate($resultFileName_stdout,
					     $resultFileName_diff,
					     $testFileName_txt);
		    if ($rating == 1.0 )
		    {
			print GROUT "--- Output accepted by TA\n ";
		    }
		    else 
		    {
			if($rating == 0 and askYes("TA:Want to halt testing?"))
			{
			    $TAHaltedTesting = 1;
			}
			print GROUT "--- Your program's output:\n";
			
			# Show student output from the test case
			open (USEROUT, "<$resultFileName_stdout");
			while ($user_line = <USEROUT>) 
			{
			    print  GROUT "   $user_line";
			}
			close (USEROUT);
			
			# Show the diff output
			print GROUT "\n--- Output from $diffCommand :\n";
			open(DIFF, "<$resultFileName_diff");
			while ($diff_line = <DIFF>) 
			{
			    print GROUT "   $diff_line";
			}
			close (DIFF);
			# Put in the TA instructions if any.
			if( open(TXT, "<$testFileName_txt") )
			{
			    print GROUT 
"\n--- Our grading policy from ".URLize($testFileName_txt)." :\n";
			    while ($line = <TXT>) 
			    {
				print GROUT "   $line";
			    }
			    close (TXT);
			}
		    }
		    scoreOneTest( $testName, $rating );
		}
	    }
	}		
    }
    print "Exiting RunTestCases2!!!!!!!!!\n";
}

#------  ManualFilterRate -------------------------------------------------#
sub ManualFilterRate($$$$)
# ( student output file name in $TestCompileDir, 
#   diff output file name, 
#   possible TA instr .txt file, 
#   filter to run )
{
    my($studOutfname) = $_[0];
#    my($diffOutfname) = $_[1];    
    my($TAInstrfname) = $_[2];
    my($filterfname)  = $_[3];

    chdir( $TestCompileDir );
    
    my($command) = "$filterfname < $studOutfname";

    my($filteroutput);
    $filteroutput = `$command`;
    print "\n";
    print "$filteroutput";
    print "\n";
    if( -e $TAInstrfname )
    {
	open( TXTFILE, "<$TAInstrfname" );
	if( defined( TXTFILE ) )
	{
	    print "\n------ current test's TA instructions(.txt) file ---------\n";
	    while ($line = <TXTFILE>) 
	    {
		print "$line";
	    }
	    close (TXTFILE);
	    print "----------------------------------------------------------\n";
	}
	else
	{
	    die "Script config problem: Cant open file '$TAInstrfname'\n";
	}
    }

    print "\nGive a rating";
    $answer_rating=getNumber(0.0,1.0);
    return($answer_rating);
} # sub
#------  end of ManualFilterRate ------------------------------------------#



#------  ManualRate -------------------------------------------------------#

sub ManualRate($$$)
# ( student output file name, diff output file name, possible .txt file )
{
    my($students_output_filename) = $_[0];
    my($user_line);

    print "\n\nStudent's program output:\n---------------------------------\n";
    
    # Show user's output of the test case
    open (USER_OUT, "<$students_output_filename");
    while ($user_line = <USER_OUT>) 
    {
	print "$user_line";
    }
    close (USER_OUT);
    print "---------------------------------------------------------------\n";

    # Show the diff output
    my( $diff_output_filename) = $_[1];
    if( $diff_output_filename )
    {
	print "\n Differences reported by diff:\n";
	open(DIFF_OUT, "<$diff_output_filename");
	while ($diff_line = <DIFF_OUT>) 
	{
	    print "$diff_line";
	}
	close (DIFF_OUT);
	print "----------End of diff output($_[1])------------------------\n";
    }

#    print "\nGive a rating (0.0 - 1.0): ";
#    chop($answer_rating=<STDIN>);


    print "TA: diff output format reminder:\n";
    print "line nums\n< <reference>\nline nums\n> Student's output from $_[0]
---\nMore differences...\n";

    my($policy_filename) = $_[2];
    if( -e $policy_filename )
    {
	open( TXTFILE, "<$policy_filename" );
	if( defined( TXTFILE ) )
	{
	    print "------ current test's .txt file --------------------------\n";
	    while ($line = <TXTFILE>) 
	    {
		print "$line";
	    }
	    close (TXTFILE);
	    print "----------------------------------------------------------\n";
	}
	else
	{
	    print "Script config problem: Cant open file '$policy_filename'\n";
	}
    }

    print "\nGive a rating";
    $answer_rating=getNumber(0.0,1.0);
    return($answer_rating);
} # sub

sub read_first($)
{
    #
    #return the first line in a file with name $_[0]
    #
    open( FH_RANDOM , "<$_[0]" ) || die("Cannot open $_[0]\n");
    my($input_line) = <FH_RANDOM>;
    chomp($input_line);
    close( FH_RANDOM );
    return($input_line);
}


sub RoundToTenths ($)
{
    return (int(($_[0]*10)+0.5))/10.0;    
}

sub getNumber($$)
{
    my($OK) = 0;
    my($number);

    do {
	print "[", $_[0], ",", $_[1], "]:";
	chop($number=<STDIN>);

# A warning is always produced when $number is not a pure numeric
# That can be disabled by removing the -w warning flag
#
# This works fine execept when the string starts with numerical chars
# Perl just seems to truncate it to determine the value
# Example:  "dasd" "sd123" are detected correctly (value=0) & rejected
#           "1dss" has a value of 1 and is accepted
#           "3.5fsfsdf" has a value of 3.5 and is rejected because of range
#
# (LY)

	unless ( ($number ne "0") && ($number == 0) )
	{ $OK = 1; }

	unless ( $OK == 0 )
	{ 
	    if( ($number < $_[0]) || ( $number > $_[1] ) )
	    { $OK = 0; }
	}
	unless ( $OK == 1 )
	{ print "Bad number input.  Try again.\n";}
    }
    until ($OK);
    return( $number );
}

sub getNumberOrNo($$)
{
    my($OK) = 0;
    my($number);

    do {
	print "[", $_[0], ",", $_[1], "] or No:";
	chop($number=<STDIN>);
	if( $number eq "No" )
	{
	    return "No";
	}

# see (LY)'s comment above

	unless ( ($number ne "0") && ($number == 0) )
	{ $OK = 1; }

	unless ( $OK == 0 )
	{ 
	    if( ($number < $_[0]) || ( $number > $_[1] ) )
	    { $OK = 0; }
	}
	unless ( $OK == 1 )
	{ print "Bad number input.  Try again.\n";}
    }
    until ($OK);
    return( $number );
}



sub backupFile($)
{
    if( -e $_[0] )
    {
	my( $nn ) = $_[0].".P";
	print "\n***TA: Old report being renamed\n   $nn\n\n";
	backupFile( $nn );
	system(" mv $_[0] $nn ");
    }
}

sub askYes($)
{
    print "$_[0]", "\nAnswer y or n:";
    my($ans);
    chomp($ans = <STDIN>);
    while( ($ans  ne "y") && ( $ans ne "n" ))
    {
	print "Please answer y or n, not \"$ans\":";
	chomp($ans = <STDIN>);
    }
    if( $ans eq "y" )
    {
	return 1;
    }
    else
    {
	return 0;
    }
}

	   
    

#
#
#  $Id: scriptIG.pl,v 2.3 2004/02/26 12:57:08 acsi310 Exp acsi310 $
#  $Log: scriptIG.pl,v $
#  Revision 2.3  2004/02/26 12:57:08  acsi310
#  Installed an INT signal handler hack to make it hard
#  to accidentally kill the script.
#
#  Revision 2.2  2004/02/26 11:36:42  acsi310
#  Mysterious undefined input from <STDIN> on line 2849
#  retried.
#
#  Revision 2.1  2004/02/25 22:32:29  acsi310
#  Print name of test each time TA requests instructions.
#
#  Revision 2.0  2004/02/23 14:08:35  acsi310
#  Moving from Spr03 to Spr04..
#
#  Revision 1.14  2003/02/26 17:11:21  acsi310
#  Better msg to student when automatic build.sh run attempts fail.
#
#  Revision 1.13  2003/02/25 21:35:18  acsi310
#  Looks good, but grading control keys are TOO CLOSE TO C-C!!
#
#  Revision 1.12  2003/02/25 19:48:17  acsi310
#  TA can request instruction file printout
#  whenever IG system is awaiting input or case grading decision.
#
#  Revision 1.11  2003/02/25 13:02:40  acsi310
#  modified TA message at the beginning of each test.
#  Works nice on good part1 submission.
#
#  Revision 1.10  2003/02/24 22:50:53  acsi310
#  Looking good..still must finish testing build script
#  evaluation code.
#
#  Revision 1.9  2003/02/24 19:55:18  acsi310
#  Added Multiple part grading.
#
#  Revision 1.8  2003/02/24 04:30:35  acsi310
#  Looks good..got automatic call to build script working
#  when it was submitted in one top level dir, as specified some assignments.
#
#  Revision 1.7  2003/02/24 02:22:53  acsi310
#  Must get scoring for non-fun to go in,
#  and also dev. for part2 testiong..
#
#  Revision 1.6  2003/02/24 01:09:44  acsi310
#  Good.
#  Must handle case when TA does C-X after all of xxx.in has
#  been processed..
#
#  Revision 1.5  2003/02/24 00:40:24  acsi310
#  Works nice so far..cleaning up stuff.
#  Must give graceful messages when TA accepts results..
#
#  Revision 1.4  2003/02/23 23:12:59  acsi310
#  Seems to work nice.
#
#  Revision 1.3  2003/02/23 15:10:51  acsi310
#  Must fix test file name making .txt.txt happens...
#
#  Revision 1.2  2003/02/23 14:59:29  acsi310
#  Put predeclarations first.
#
#  Revision 1.1  2003/02/23 14:14:37  sdc
#  Initial revision
#
#  Revision 1.2  2003/02/23 04:21:32  sdc
#  Replaced name of $IsCompilable with $RequiresCompiling
#
#  Revision 1.1  2003/02/23 04:13:40  sdc
#  Initial revision
#
#  Revision 1.7  2003/02/14 22:31:57  acsi310
#  Begin to adapt for CSI310:
#  Systematically deal with multiple dir. submissions.
#  Use Unix "file" command to detect ELF(obj,exe,dump) files.
#
#  Revision 1.6  2000/12/18 02:51:56  csi333
#  Leave it for now..
#
#  Revision 1.5  2000/12/18 00:39:58  csi333
#  Allow RCS directory to be test compile dir or test compile dir/RCS
#
#  Revision 1.4  2000/12/17 18:44:45  csi333
#  Checkin before making it unpack RCS stuff before checking non-functional reqs.
#
#  Revision 1.3  2000/12/15 16:26:45  csi333
#  Make appending of \n to the end of the student's output file
#  conditional on it not ending with \n.
#
#  Revision 1.2  2000/12/15 03:54:37  csi333
#  first mod for jtool.
#
#  Revision 1.1  2000/12/15 03:41:16  csi333
#  Initial revision
#
#  Revision 1.13  2000/12/11 18:47:34  csi333
#  Remove extraneous revision log quality line output to grade report file.
#
#  Revision 1.12  2000/12/11 18:18:04  csi333
#  Better explanation of diff output format.
#
#  Revision 1.11  2000/12/11 18:10:14  csi333
#  Add a ) to fix syntax error.
#
#  Revision 1.10  2000/12/11 18:09:02  csi333
#  Don't wait for \n after asking TA about revision log.
#
#  Revision 1.9  2000/12/11 18:04:36  csi333
#  Still fixing askYes..
#
#  Revision 1.8  2000/12/11 17:52:16  csi333
#  Fix bug in askYes
#
#  Revision 1.7  2000/12/11 17:46:04  csi333
#  Fixed NonFunGradInstructions to make them consistant with
#  the questions given to the TA.
#
#  Revision 1.6  2000/12/11 17:42:51  csi333
#  Added askYes("Question") sub.
#  Ask TA about penalty or comments.
#  Print policy.txt to TA.  If non-zero penalty,
#  put print this to grade report too.
#
#  Revision 1.5  2000/12/11 16:10:45  csi333
#  Removed checkReport function after merging its capabilities
#  with GradeReportFile function.
#
#  Revision 1.4  2000/12/11 04:01:48  csi333
#  Parametrize Report Like file message so it is usable for more than just
#  a text file revisions log.
#
#  Revision 1.3  2000/12/11 02:53:03  csi333
#  Replaced defn of $valueTestsPhase2
#
#  Revision 1.2  2000/12/11 02:23:02  csi333
#  Early bonus deadline can be before on time due date.
#
#  Revision 1.1  2000/12/10 18:04:34  csi333
#  Initial revision
#
#  Revision 3.6  2000/11/05 15:30:42  csi333
#  Print file name of misc. penalty policy file.
#  remove valueMake variable, MakefilePoints is used instead.
#  Modify non-func reqs. for more flexiblity for first ASM project;
#  earlier projects are graded with less rigor about function use and documentation.
#
#  Revision 3.5  2000/11/05 00:51:10  csi333
#  Append a newline to truncated student output file so that diff
#  does not fail and print a warning simply if student program fails to print a
#  newline after its last output.
#
#  Revision 3.4  2000/11/04 23:42:57  csi333
#  Added newlines to report output near TA penalty comments.
#
#  Revision 3.3  2000/11/04 23:32:45  csi333
#  Fix bugs in last revision's function.
#
#  Revision 3.2  2000/11/04 23:26:21  csi333
#  Enable TA to apply a misc. penalty after grading is completed.
#  Rename AddComments subroutine, call it before computing late penalty.
#
#  Revision 3.1  2000/11/03 21:14:52  csi333
#  Improve PointBreakdownMessage
#
#  Revision 3.0  2000/11/03 20:49:36  csi333
#  More enhancements to support asm projects.
#  Improved TA interaction for reporting differences.
#  Made message about policy files (t*.txt) conditional on the file's existance.
#
#  Revision 1.1  2000/11/03 20:46:48  csi333
#  Initial revision
#
#  Revision 2.9  2000/10/11 20:25:21  csi333
#  Setting of current non-fun-req policy, revision log checking,
#  a few other little things (do rcsdiff if you are interested.)
#
#  Revision 2.8  2000/10/11 17:25:18  csi333
#  Almost done.. need to set up "Process Req" grading policy.
#
#  Revision 2.7  2000/10/04 18:24:30  csi333
#  Improved messages about required makefile together with required
#  build script.
#
#  Revision 2.6  2000/10/04 18:01:38  csi333
#  Message about missing required files change to say the files were
#  NOT FOUND.  (They might have been tarred as ../something !!)
#  Also, deleted a useless unlink missing required files operation!
#
#  Revision 2.5  2000/10/04 17:47:19  csi333
#  Wrote separate to check for and grade any kind of revision log.
#
#  Revision 2.4  2000/10/04 17:14:50  csi333
#  Add bonus for being on time or early.
#
#  Revision 2.3  2000/10/03 00:40:56  csi333
#  Seems OK for Fall 2000 datatool project-uses filter
#
#  Revision 2.2  2000/10/02 15:00:42  csi333
#  fixed TestFileName_infname
#
#  Revision 2.1  2000/10/02 14:54:39  csi333
#  Fixed a syntax error.
#
#  Revision 2.0  2000/10/02 14:53:13  csi333
#  Fall 2000 version..
#
#  Revision 1.5  1999/12/14 13:57:43  csi333
#  Removed @c_files variable to stop used once warning
#
#  Revision 1.4  1999/12/14 03:22:45  csi333
#  Grading policy comment added for say a wrong target in the makefile
#
#  Revision 1.3  1999/12/11 21:27:55  csi333
#  Hacked in a universal C++ compile command, didn't fix
#   or remove previous attempts to automate this.
#
#  Revision 1.2  1999/12/11 19:49:55  csi333
#  Moved from devel directory..
#  Main new features are
#   (1) if a testcase.flt file is present, it is used to
#  filter student output to display to the TA for grading by
#  following the policy displayed from testcase.txt
#   (2) Time and filesize limits put on student program execution.
#
#  Revision 1.5  1999/12/11 19:45:56  csi333
#  Added time and file size limits to run of student program
#
#  Revision 1.4  1999/12/11 18:42:23  csi333
#  RCS LOG added
#
#
#
#
#   (developed under Slackware Linux, path names expressed by 
#    variable below must be modified for eve/lilith csc systems.)
#  S.Chaiken 2/16/98-2/18/98
#  Beginning of extensive reorganization of script 
#    Adapted by Joseph Foley from a script written by Qingwen Cheng
#    Based on the script by Bedros A Yessaian
#  With a bunch o' quick and dirty hacks, added by Liang Yin
#    (CSI402 TA, Spring 1998)
#
#  Customized for CSI402 cpu simulation project2-part1 by Paul Jaggi, Spr. 1999
#  Customized for CSI333 tmips project, Fall 1999, S.Chaiken
#  Various improvements and generalizations, Fall 1999, S.Chaiken
#
#  Customized for CSI333 datatool project, Fall 2000, S.Chaiken
#  Customized for CSI333 333xref project, Fall 2000, S.Chaiken
#  Customized for CSI333 jtool project, Fall 2000, S.Chaiken

####################################################################
###################################################################
#
#
# INTERACTIVE GRADING SUPPORT
#
###################################################################
##################################################################
use IPC::Open3;

sub handler {
    print "\n\nGot a SIGPIPE\n\n";
    $IGGotSIGPIPE = 1;
    $IGGO = 0;
}
       
sub IGwriteGROUTHeading();
sub IGwriteGROUTHeading()
{
    print GROUT "\nBEGIN NEW TEST REPORT---------\n";
}


sub GradeInteractiveCase($$$$)
# $_[0]: CWD
# $_[1]: executable name
# $_[2]: Test Case Directory
# $_[3]: Test Case name
# return value = rating between 0.0 and 1.0
#
# other globals used:
# GROUT
# $SIG{PIPE}
{

print "GradeInteractiveCase\n
[0] $_[0] CWD\n
$_[1]: executable name
 $_[2]: Test Case Directory
 $_[3]: Test Case name
";



##################################################################
# INITIALIZE GLOBALS HERE INSTEAD OF BEGINNING OF WHOLE FILE
$IGtimeout = #20.25; #second
    2.0;
$IGReadMAX = 2000;
$IGnShow = 250;
##################################################################

$IGGotSIGPIPE = 0;
$SIG{PIPE} = 'handler';

my($exeName) = $_[1];
my($IGTestCompileDir) = $_[0];

IGRedoTestGoToLabelYesIKnowItSUgly:

chdir( $IGTestCompileDir );

my($TestCaseDir) = $_[2];
my($testName) = $_[3];

my($TAInstrfname) = "$TestCaseDir/$testName.txt";
my($testFileName_stdin) = "$TestCaseDir/$testName.in";
my($FileInOK);

my($rating) = "?";

if( -e $testFileName_stdin )
{
    open(IGTESTIN, "<$testFileName_stdin") or die "Can't open $testFileName_stdin\n";
    #print GROUT 
#"--- Test stdin file:  ".URLize($testFileName_stdin)."\n";
    $FileInOK = "(CX:from in.file)";
    print "TA:Test input may be inserted 1 line at a time 
    from $testFileName_stdin 
      by using C-X<enter> at the prompt..\n";
}
else
{
    $FileInOK = "";
}



my($StudentReportBrief) = "";
my($StudentReportLong) = "";

IGwriteGROUTHeading();

my($TAinstructions) = "";

if( -e $TAInstrfname )
{
    open( IGTXTFILE, "<$TAInstrfname" );
    if( defined( IGTXTFILE ) )
    {
	$TAinstructions =
"\n------ current test's TA instructions($testName.txt) file ---------\n";
	
	$StudentReportBrief .= "Name of test: $testName, see
   ".URLize($TAInstrfname)."\n";
	$StudentReportLong .= "Name of test: $testName, see
   ".URLize($TAInstrfname)."\n";
	while ($line = <IGTXTFILE>) 
	{
	    $TAinstructions .=    "$line";
	    $StudentReportLong .= "$line";
	}
	close (IGTXTFILE);
	$TAinstructions .= "----------------------------------------------------------\n";
	$StudentReportLong .= "-------------Results-----------------------------:\n";
	print $TAinstructions;
	}
	else
	{
	    die "Script config problem: Cant open file '$TAInstrfname'\n";
	}
}
else
{
    die "Script config problem: Cant find filename '$TAInstrfname'\n";
}

my($WDR,$RDR);

chdir $IGTestCompileDir;

my($pid) = open3($WDR, $RDR, "", $exeName);

my($rin,$win,$ein);
$rin = $win = $ein = "";
vec($rin, fileno($RDR), 1) = 1;
vec($win, fileno($WDR), 1) = 1;



my($reading) = 1;
my($writing);
$IGGO = 1;
$IGDONE = 0;
$IGBAD = 0;
my($ASKTA1,$ASKTA2);
my($TAinput,$sawNl);
my($nsel,$n);
while($IGGO)
{
    if($reading)
    {
	my( $nread ) = -1;
	#only initially, so 2nd time while sees $nread==0
	#if the sysread encountered EOF.
	my($nTotalRead); $nTotalRead = 0;
	while( $nTotalRead < $IGReadMAX
	       and
	       $nsel = select($rout=$rin,$wout="",$eout=$ein,$IGtimeout)
	       and
	       $nread )
	{
	    if( vec($rout, fileno($RDR), 1) )
	    {
		$nread = 
		    sysread $RDR, $Rbuf, ($IGReadMAX-$nTotalRead), $nTotalRead;
		$nTotalRead += $nread;
	    }
	    else
	    {
		print "\n\nSomething's wrong:select!=0 but no read fd bit!\n";
	    }
	}
	$reading = 0;
	if( $nTotalRead == $IGReadMAX )
	{
	    #Too much output!!!!!
	    $IGGO = 0;
	    $IGBAD = 1;
	    print "\n------------------------------------------\n";
	    $temp = "Program tried to print >= $IGReadMAX chars";
	    print "$temp($IGnShow shown):\n";
	    $trunc = substr $Rbuf, 0, $IGnShow;
	    print $trunc;
	    print "-----OUTPUT-FROM-STUDENT-PROG-TRUNCATED-----\n";
	    $StudentReportBrief .= "$temp\n";
	    $StudentReportLong  .= "$temp($IGnShow shown):\n";
	    $trunc =~ s/\n/\nOut->/mg ;
	    $StudentReportLong .= 
		("Out->$trunc\n".
		 "-----OUTPUT-FROM-STUDENT-PROG-TRUNCATED-----\n");
	}		
	elsif( $nTotalRead == 0 )
	{
	    print "\nEither program is waiting for input, or its output TIMED OUT\n";
	    $StudentReportLong .= "....Your program didn't output anything here...\n";
	    $ASKTA2 = 1;
	}
	else
	{
	    my($temp) = $Rbuf;
	    print "\n---STUDENT-PROGRAM-OUTPUT-------------------\n$temp";
	    print "------END-OF-STUDENTS-PROGRAM-OUTPUT---\n";
	    $temp = "Out->$temp";
	    $temp =~ s/\n/\nOut->/mg;
	    $StudentReportLong .= $temp;
	    $ASKTA1 = 1;
	}
    }##END OF if($reading){}
    $TAinput = "";
    if($ASKTA2)
    {
	$ASKTA2 = 0;
	print 
"\nTA2:(cA:ok)(CF:bad)(CN:wait output)(CG:partial.cr)(CX:in.file)(CB?)more input:";
	$TAinput = <STDIN>;
	my( $n ) = index "\cA\cF\cN\cG\cX\cB", substr($TAinput, 0, 1), 0;
	if($n==0)
	{
	    $StudentReportLong .= "\nResult Accepted, Good Job.";
	    $StudentReportBrief .= "\nResult Accepted, Good Job.";
	    $IGGO = 0;
	    $IGDONE=1;
	    $rating = 1.0;
	}
	elsif($n == 1)
	{
	    $StudentReportLong .= "\n...Program failed this test.......\n";
	    $rating = 0.0;
	    $IGGO = 0;
	    $IGDONE=1;
	}
	elsif($n == 2)
	{
	    $StudentReportLong .= "...More waiting for output....\n";
	    $StudentReportBrief .= "...More waiting for output....\n";
	    $reading = 1;
	}
	elsif($n == 3)
	{
	    $StudentReportLong .= "...Evaluated for partial credit....\n";
	    $StudentReportBrief .="...Evaluated for partial credit....\n";
	    print "\n\nGive a rating";
	    $rating = getNumberOrNo(0.0,1.0);
	    $IGGO=0;
	    $IGDONE=1;
	}
	elsif($n == 4)
	{
	    $TAinput = <IGTESTIN>;
	    if( not defined $TAinput )
	    {
		$FileInOK = "";
		$TAinput = "";
		$reading = 1;
		print "TA:No more file input is available. \n";
	    }
	    else
	    {
		print "TA:The next input will be:$TAinput";
	    }
	}
	elsif( $n == 5 )
	{
	    print $TAinstructions;
	    $reading = 1;
	    $TAinput = "";
	}
    }##END OF if($ASKTA2){}
    if($ASKTA1)
    {
	$ASKTA1 = 0;
	print
"\nTA1:(CA:accept)(CF:reject)(CG:par.cred.)${FileInOK}(CB:?)more input:";
	while( not defined ($TAinput = <STDIN>) )
	{ print "????Failed input? Try again";
	  print
"\nTA1:(CA:accept)(CF:reject)(CG:par.cred.)${FileInOK}(CB:?)more input:";
      }
	my( $n ) = index "\cA\cF\cG\cX\cB", substr($TAinput, 0, 1), 0;
	if($n==0)
	{
	    $StudentReportLong .= "\nResult Accepted, Good Job.\n";
	    $StudentReportBrief .= "\nResult Accepted, Good Job.\n";
	    $rating = 1.0;
	    $IGGO = 0;
	    $IGDONE=1;
	}
	elsif($n == 1)
	{
	    $StudentReportLong .= "\n...Program failed this test........\n";
	    $rating = 0.0;
	    $IGGO = 0;
	    $IGDONE=1;
	}
	elsif($n == 2)
	{
	    $StudentReportLong .= "...Evaluated by $TAUserName for partial credit....\n";
	    $StudentReportBrief .="...Evaluated by $TAUserName for partial credit....\n";
	    print "\n\nGive a rating";
	    $rating = getNumberOrNo(0.0,1.0);
	    $IGGO=0;
	    $IGDONE=1;
	}
	elsif($n == 3)
	{
	    $TAinput = <IGTESTIN>;
	    if( not defined $TAinput )
	    {
		$FileInOK = "";
		$TAinput = "";
		$ASKTA1 = 1;
		print "TA:No more file input is available. \n";
	    }
	    else
	    {
		print "TA:The next input will be:$TAinput";
	    }
	}
	elsif($n == 4)
	{
	    print $TAinstructions;
	    $TAinput = "";
	    $ASKTA1 = 1;
	}
    }##END OF if($ASKTA1){}
    if($TAinput)
    {
	$writing = 0;
	$sawNl = 0;
	while( $IGGO 
	       and
	       ($sawNl==0)
	       and
	       $nsel = select($rout="",$wout=$win,$eout=$ein,$IGtimeout) )
	{
	    if( ($nsel > 0 ) && (vec($wout, fileno($WDR), 1)==1) )
	    {
		if( $writing == 0 )
		{
		    $StudentReportLong .= "\nIn--<";
		    $writing = 1;
		}
		$rbuf = substr $TAinput, 0, 1;
####### KLUGE...to protect against bug manifested when the test.in file
####    ends with a non-nl terminated line and the TA types C-X to
####    input that line
		if( (length $TAinput) > 0 )
		{
		    $TAinput = substr $TAinput, 1;
		}
		$nread = length $rbuf;
		if( $nread != 0 )
		{
		    $StudentReportLong .= "$rbuf";
		    if($rbuf eq "\n")
		    {
			$sawNl = 1;
		    }
		    syswrite $WDR, $rbuf, 1;
########     print "\n\nWrote ->$rbuf<- to our program..\n";
		}
		else
		{
		#    $eofseen = 1;
		    $StudentReportLong .= "EndTestIn.\n";
		}
	    }
	}##END OF while(...){try to send $TAinput line to the program}
	if($IGGO)
	{
	    if(not $sawNl)
	    {
		print "\nTIMEOUT trying to give student program input\n";
		print 
		    "\nNow, try to see if student program is trying to print:\n";
		$reading = 1;
	    }
	    else
	    {
		$TAinput = "";
		$reading = 1;
	    }
	}
	elsif($IGDONE==0)
	{
	    print "Student program crashed while tester was trying to write\n";
	    $StudentReportBrief .= "\nProgram crashed.......\n";
	    $StudentReportLong .= "\nProgram crashed.......\n";
	}
    }##END OF if($TAinput){}
} ##END OF while($IGGO)

kill 9, $pid;

if($rating eq "?")
{
    print "TA:Testing on $testName stopped. Please rate";
    $rating = getNumberOrNo(0.0,1.0);
}
if($rating eq "No")
{
    print "\n\n-*-*-*-- ReDo of that last test $testName from 
       $TestCaseDir----\n";
    goto IGRedoTestGoToLabelYesIKnowItSUgly;
}

if($rating != 1.0)
{
    print GROUT "$StudentReportLong\n";
}
else
{
    print GROUT "$StudentReportBrief\n";
}

return $rating;

}#end sub GradeInteractiveCase


