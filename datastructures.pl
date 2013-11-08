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
#      CREATED: 10/08/2013 12:12:53 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

open my$fh, "< /home/kk/test.txt" ;

my@array ;
my%hash ;
my$scalar ;


#-------------------------------------------------------------------------------
#  test for aoa
#-------------------------------------------------------------------------------
while ( <$fh> ) {
   push @array,[split] ; 
}
foreach my $aoa ( @array ) {
    print join" ",@$aoa;
    print "\n";
}


#-------------------------------------------------------------------------------
#  test for hoa
#-------------------------------------------------------------------------------
while ( <$fh> ) {
    chomp(my($key, $value) =  split" ",$_,2);
    $hash{$key}=[split" ",$value] ; 
}

while ( my($keys,$values)=each%hash ) {
    my@values = @$values ;
    print "$values[1]\n" ;
}



#-------------------------------------------------------------------------------
#  test for aoh
#-------------------------------------------------------------------------------


while ( <$fh> ) {
    chomp ;
    push @array, { split" ",$_,2 } ; 
}
while ( @array ) {
    my($key, $value) = each shift @array ;
    print "$key $value\n" ;
}


#-------------------------------------------------------------------------------
#  test for hoh 
#-------------------------------------------------------------------------------


while ( <$fh> ) {
    chomp;
    my($key1,$value1)=split" ",$_,2; 
    my($key2,$value2)=split" ",$value1,2;
    $hash{$key1}{$key2}=$value2 ;
}

while ( my($key1,$value1)=each%hash ) {
    while ( my($key2,$value2)=each%$value1 ) {
        print "$key1 $key2 $value2\n" ;
    }
}
