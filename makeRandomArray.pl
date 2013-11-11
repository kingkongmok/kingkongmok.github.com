#!/usr/bin/perl
#===============================================================================
#
#         FILE: makeRandom.pl
#
#        USAGE: ./makeRandom.pl  
#
#  DESCRIPTION:  make random array by map and rand func.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 11/11/2013 11:07:06 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

my @aoa = map { [ map {int rand 10} 0..9] } 0..9 ;
my @a = map {int rand 10} 0..9 ;

use Data::Dumper;
print Dumper(\@aoa);

