#!/usr/bin/perl
#===============================================================================
#
#         FILE: test.pl
#
#        USAGE: ./test.pl  
#
#  DESCRIPTION: search multrilines with gsm regex option.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 12/07/2013 11:55:38 AM
#     REVISION: ---
#===============================================================================

#use strict;
#use warnings;


my$string='id:     8db47c
times:  2621
type:   forecast, observe
id:     334cfc
times:  2029
type:   index, forecast3d, alarm
id:     7c1429
times:  6446413
type:   index, forecast5d, observe
id:     86
times:  2
type:
id:     549d81
times:  2155650
type:   forecast, index, observe, alarm, calendar
id:     71f520
times:  1943';

$string = $string . "\nid"; 

while ( $string =~ /(id:\s+?(\w+?)\n.*?)(?=id)/gsm ) {
    print $1 if length$2 > 5;
}

