#!/usr/bin/perl
#===============================================================================
#
#         FILE: test.pl
#
#        USAGE: ./test.pl  
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
#      CREATED: 01/02/2014 02:51:35 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;


sub gcd {
    my ($a, $b) = @_;
    while ($a) { ($a, $b) = ($b % $a, $a) }
    $b
}
 
sub lcm {
    my ($a, $b) = @_;
    ($a && $b) and $a / gcd($a, $b) * $b or 0
}
 
print lcm(2, 16);
