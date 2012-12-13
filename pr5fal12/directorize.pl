#! /usr/bin/perl -w

use strict;

my $zip = $ARGV[0]; 
my $dir = $ARGV[1];
if($dir eq "")
{
    $dir = '.';
}

my $unzipDir = "$dir/LEFTOVERS";

if( ! -d $unzipDir )
{
    `mkdir -p "$dir/LEFTOVERS"`;
    die "Can't mkdir $dir/LEFTOVERS\n" unless $? eq 0;
}

$zip =~ s/\ /\\\ /g;  #Re-quote stupid embedded spaces 
                      #in the disgusting non-Unix style
                      #file name for the zip file from
                      #I won't say it's despicable name!

my $unzipCmd = "unzip -d $dir/LEFTOVERS $zip";
#print "$unzipCmd\n";

`$unzipCmd`;
die "Can't $unzipCmd" unless $? eq 0;

opendir (DIR, "$dir/LEFTOVERS");
my @files= readdir(DIR);
closedir DIR;
#print @files;

my ($asgName, $usrName, $time, $fileName);
my $countMoved = 0;
my $countUnmatched = 0;

for my $file(@files){
  
#  print $file,"\n";
  if( $file eq '.' or $file eq '..' ){ next;}
  if( $file =~/^([^_]+)_([^_]+)_attempt_([^_]+)_(.+)$/s )
# asgName------- ^ might have embedded spaces!
# _ is the separator.
  {
      $asgName=$1;
      $usrName=$2;
      $time=$3;
      $fileName=$4;
  }
  elsif ($file =~/^([^_]+)_([^_]+)_attempt_([^\.]+\.txt)$/s )
  {
      $asgName=$1;
      $usrName=$2;
      $fileName=$3;
      $time = $fileName;
      $time =~ s/\.txt//;
  }
  else
  {
      print "UNMATCHED:$file\n\n";
      $countUnmatched++;
      next;
  }

  my $dirName = $usrName.".".$time;

  if(! -d "$dir/$dirName" ){
      mkdir "$dir/$dirName";
      `chmod 770 "$dir/$dirName"`;
  }

  $file =~ s/\ /\\\ /g;  #Escape-sequence stupid embedded spaces.
  $file =~ s/\(/\\\(/g;  #Escape-sequence stupid embedded ( HA!!
  $file =~ s/\)/\\\)/g;  #Escape-sequence stupid embedded  )HA!!

  $fileName =~ s/\ /\\\ /g;  #Escape-sequence stupid embedded spaces.
  $fileName =~ s/\(/\\\(/g;  #Escape-sequence stupid embedded ( HA!!
  $fileName =~ s/\)/\\\)/g;  #Escape-sequence stupid embedded  )HA!!


  `mv $dir/LEFTOVERS/$file $dir/$dirName/$fileName`;
  print "\n\nCan't mv $dir/LEFTOVERS/$file $dirName/$fileName\n\n" 
      unless $? == 0;

  print "\b\b\b\b\b"; #Enough for myriads of files
  print ++$countMoved;

}

print " files moved";
if($countUnmatched != 0)
{
    print " and $countUnmatched filenames unmatched in LEFTOVERS.\n";
}
else 
{
   print ".\n";
}


