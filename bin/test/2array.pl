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

my%k;
my%h;
while ( <DATA> ) {
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
    
__DATA__
b   0
c   1
d   2
e   3
f   4
g   5
h   6
i   7
j   8
k   9
b   3
c   4
d   5
e   6
f   7
g   8
h   9
i   10
j   11
k   12
b   2
c   3
d   4
e   5
f   6
g   7
h   8
i   9
j   10
k   11
