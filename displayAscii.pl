#!/usr/bin/perl
#===============================================================================
#
#         FILE: test.pl
#
#        USAGE: ./test.pl  
#
#  DESCRIPTION: G
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 09/27/2013 11:23:45 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

my@array;
while ( <> ) {
    while ( /(.)/g ) {
        if ( ord($1)>128 ) {
            push @array, $. ;
            last ;
        }
    }

    print $_ unless grep {$.==$_} @array ;

}



