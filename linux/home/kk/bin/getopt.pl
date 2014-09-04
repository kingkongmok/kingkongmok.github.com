#!/usr/bin/perl
#===============================================================================
#
#         FILE: getopt.pl
#
#        USAGE: ./getopt.pl  
#
#  DESCRIPTION: test Getopt funtions. the Std may be easy to use as below 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 12/04/2013 12:18:52 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

#use Getopt::Long;
#my %opts = (parameter => 20);
#GetOptions( \%opts, 
#        'p|parameter=i', 
#        'o|outputfile=s',
#        'i|inputfile=s'
#) or die "Invalid parameters!";
#
#
#use Data::Dumper;
#print Dumper(%opts);

use Getopt::Std;
getopts('dn:a:');
our($opt_d, $opt_n, $opt_a);

if($opt_d)
{
  print "Debugging mode\n";
}

if(!$opt_n && !$opt_a)
{
  print "USAGE:\n\texample6 [-d] -n name -a age\n";
  exit;
}

else
{
  if($opt_d)
  {
    print "Forming string\n";
  }

  my $output = "$opt_n is $opt_a years old\n";
  print $output;
}
