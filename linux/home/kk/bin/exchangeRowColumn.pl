#!/usr/bin/perl
#===============================================================================
#
#         FILE: test.pl
#
#        USAGE: ./test.pl  
#
#  DESCRIPTION: 行与列交换
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 01/09/2014 03:19:13 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

my $teststring="1 2 3 4
a b c d e 
A B C D
";
print $teststring ;
print "\n==============\n";

my @filearray = split/\n/,$teststring ;

my %hash ;
my $maxlength =0;

foreach my $element ( @filearray ) {
    my @linearray = split/\s/,$element ;
    $maxlength = ~~@linearray > $maxlength ? ~~@linearray : $maxlength;
}

for ( my $index=0; $index<$maxlength; $index++ ) {
    foreach ( @filearray ) {
        my @linearray = split/\s/,$_ ;
        if (defined $linearray[$index]){
            print $linearray[$index];
        }
        else {
            print "null" ;
        }
        print "\t" ;
    }
    print "\n" ;
}

