#!/usr/bin/perl
#===============================================================================
#
#         FILE: test.pl
#
#        USAGE: ./test.pl  
#
#  DESCRIPTION: 在数列中提取只连续出现3次的字母; display the letter repeat and again (3times) only
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 01/24/2014 12:33:33 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

my $string = 1234456667777778 ;
my @array = split//,$string ;
my %hash ;
my %hash2 ;
my $element2 = "";
my $element3 = "";
my $element4 = "";

foreach my $element ( @array ) {
    $hash2{$element}++ if $element eq $element2 && $element3 eq $element2 && $element4 eq $element3;
    $hash{$element}++ if $element eq $element2 && $element3 eq $element2 && $element4 ne $element3;

    $element4 = $element3 ;
    $element3 = $element2 ;
    $element2 = $element ;
}

my @a1 = keys%hash ;
my @a2 = keys%hash2 ;

foreach my $element ( @a1 ) {
    print $element unless $element ~~ @a2 ;
}
