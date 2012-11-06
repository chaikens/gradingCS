#!/usr/bin/perl  -w
use Time::Local;
sub submissionTime($)
{
    my $dirName = $_[0];
    $dirName =~ s|.*/||;
    #student.2012-03-03-04-57-02
    $dirName =~ /(\d+)-(\d+)-(\d+)-(\d+)-(\d+)-(\d+)/;
    return Time::Local::timelocal($6,$5,$4,$3,$2,$1);
}


#2012-03-03-23-59-59
$DUEtime = Time::Local::timelocal(59,59,23,3,3,2012);
#                          second  ^
#                              minute ^
#                                   hour ^
#                                      day ^
#                                      month ^
#                                            year ^

$DUEDaysPer100PercentOff = 7.0;


$argument = $ARGV[0];
$argument =~ s/[a-zA-Z]{2}+[0-9]*\Q.\E//;
$SUBtime = submissionTime($argument);

if($SUBtime <= $DUEtime)
{
    print "\n";
    print 1.0;
    print "\n";
}
else
{
    $daysLate = ($SUBtime-$DUEtime)/(60.0*60.0*24.0);
    $LateMod = 1.0 - (($daysLate)*(1.0/$DUEDaysPer100PercentOff));    
    print "\n";
    print int($LateMod*1000.0+0.5)/1000.0;
    print "\n";   
}
