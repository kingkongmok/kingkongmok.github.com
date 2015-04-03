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

#===  FUNCTION  ================================================================
#         NAME: display
#      PURPOSE: print from STDIN
#   PARAMETERS: ????
#      RETURNS: ????
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub display {
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
    return ;
} ## --- end sub display


#===  FUNCTION  ================================================================
#         NAME: printall
#      PURPOSE: print ord 0 ~ 256
#   PARAMETERS: ????
#      RETURNS: ????
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub printall {
    my @array = 0..256 ;
    
    foreach my $element ( @array ) {
        print "$element => ", chr($element), "\n" ;
    }
    return ;
} ## --- end sub printall

&printall ;
&display ;

# print "123asd阿萨德哈哈哈sdferjhjhk回家哈" =~ s/[[:ascii:]]//gr 

