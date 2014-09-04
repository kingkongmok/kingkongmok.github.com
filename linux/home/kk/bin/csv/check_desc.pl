#!/usr/bin/perl 
#===============================================================================
#
#         FILE: check_detail.pl
#
#        USAGE: ./check_detail.pl  
#
#  DESCRIPTION: check in0.txt before convert.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 09/26/2013 10:39:36 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

open FILE, "<", "desc.csv" or die "$!" ;
open SPACING_FILE, ">", "space.csv" or die "$!" ;
open NOTASCII_FILE, ">", "notascii.csv" or die "$!" ;
open BRACKETS_FILE, ">", "brackets.csv" or die "$!" ;


while ( <FILE> ) {
    while(/(.)/g) {
        print NOTASCII_FILE "$.\n$_\n" if 32 > ord($1) || ord($1) > 126
    }

    print BRACKETS_FILE "$.\n$_\n" if /(\(|\))/ ;

    chomp($_);
    my ( $oldPicsString , $newString )  = split ( /\",\"/, $_ ) ;
    print SPACING_FILE "$.\n$_\n" if $newString=~/\s/ ;
}

close BRACKETS_FILE;
close SPACING_FILE;
close NOTASCII_FILE;
