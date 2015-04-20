#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: timetest.pl
#
#        USAGE: ./timetest.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 04/20/2015 09:15:27 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

my ($sec, $min, $hour, $mday, $mon, $year) = localtime();
my $lastHour = sprintf "%d-%d-%d %02d\n", $year+1900, $mon, $mday, $hour-1;  

print $lastHour;

