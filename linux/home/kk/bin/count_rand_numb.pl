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
#      CREATED: 08/30/2013 04:37:20 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
my	@array=1..10;
my$numb=0;
my%hash;
while ( $numb<1000 ) {
    $hash{int(rand@array)}++ ;
    $numb++;
}
#print join":",keys%hash;
my$k;
my$v;
my$sumk;
my$sumv;
while ( ($k,$v)=each%hash ) {
    print "$k\t$v\n" ;
    $sumk+=$k; 
    $sumv+=$v; 
} END 
{
print "the sum of key is $sumk\n" ;
print "the sum of val is $sumv\n" ;
}
BEGIN{
print "keys\tvalues\n";
}
