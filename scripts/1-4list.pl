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
#      CREATED: 01/02/2014 10:13:03 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;


my @many =  glob "{1,2,3,4},{1,2,3,4},{1,2,3,4},{1,2,3,4}";

foreach ( @many ) {
    my@a=split",",$_ ;
    my%h; 
    @h{@a}=();
    print "@a\n" if keys%h == 4 ;
    
}

