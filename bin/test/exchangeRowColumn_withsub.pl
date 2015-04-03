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
#      CREATED: 02/11/2014 11:23:26 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use Data::Dumper;

my $string = "1 2
a b c d
A B C ";


my @aoa = stringToAOA($string) ;
displayerCross(\@aoa) ;


sub getMaxLength {
    my	( $a, $b, $c )	= @_;
    my @c =  reverse sort ( ~~@$a, ~~@$b, ~~@$c) ;
    return $c[0];
} ## --- end sub getMaxLength

sub stringToAOA {
    my	( $par1 )	= @_;
    my @array = split"\n", $string ;
    my $itor = 0;
    my @aoa ;
    foreach my $line ( @array ) {
        $aoa[$itor] = [ split" ",$line ] ;
        $itor++ ;
    }
    return @aoa;
} ## --- end sub stringToAOA

sub displayerCross {
    my $aoa = shift ;
    my $maxlength = 0 ;
    foreach my $array ( @aoa ) {
        $maxlength = ($maxlength > ~~@$array)?$maxlength : ~~@$array ;
    }
    for ( my $iter = 0; $iter < $maxlength; $iter++ ) {
        foreach my $array ( @aoa ) {
            my @a = @$array ;
            if ( exists $a[$iter] ) {
                print $a[$iter], "\t" ;
            }
            else {
            print "\t" ;
            }
        }
        print "\n" ;
    }
    return ;
} ## --- end sub displayerCross
