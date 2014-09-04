#!/usr/bin/perl
#===============================================================================
#
#         FILE: 2array.pl
#
#        USAGE: ./2array.pl  
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
#      CREATED: 09/22/2013 02:58:57 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

open F2A, "<", "/home/kk/workspace/perl/2array.txt";

my%k;
my%h;
while ( <F2A> ) {
    (my$c1, my$c2)=split;
    if ( $k{$c1}++ ) {
        $h{$c1}=$h{$c1} > $c2? $h{$c1} : $c2 ;
    }
    else{ 
        $h{$c1}=$c2 ;        
    }
}

while ( (my$k,my$v)=each%h ) {
    print "$k\t$v\n" ;
}
    
