#!/usr/bin/perl -w

use SubmissionAdapter qw(getOtherSubmissions);



my $dir = $ARGV[0];
my $submission = $ARGV[1];

my $ret = getOtherSubmissions($dir,$submission);

print $ret;




