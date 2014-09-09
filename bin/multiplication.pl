#!/usr/bin/perl
#===============================================================================
#
#         FILE: multiplication.pl
#
#        USAGE: ./multiplication.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 11/26/2013 06:15:06 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

my@a = 1..9 ;
my@b = 1..9 ;
foreach my $a ( @a ) {
    foreach my $b ( @b ) {
        next if $b > $a ;
        printf "%dx%d=%d\t",$b,$a,$a*$b ;
    }
    print "\n";
}

