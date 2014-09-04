#!/usr/bin/perl
#===============================================================================
#
#         FILE: iocheck.pl
#
#        USAGE: ./iocheck.pl  
#
#  DESCRIPTION: check yes and no
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 12/04/2013 04:00:28 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;


while ( 1 ) {
    print "Are you o.k?[yes/no] ";
    chomp(my $input = <STDIN>);
    if ( $input eq "yes" ) {
        print "yes\n" ;
        last ;
    }
    if ( $input eq "no" ) {
        print "no\n" ;
        last ;
    }
    print "try again...\n" ;

}



