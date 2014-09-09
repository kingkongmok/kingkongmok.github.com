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
#      CREATED: 08/21/2013 11:23:13 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

open FILE, "<", "detail.csv" or die "$!" ;
open OUTFILE, ">", "change.sh" or die "$!" ;

chomp ( my @array = <FILE> ) ;

for ( @array ) {
       s/^\s?"//;
       s/"$//;
}

foreach my $line ( @array ) {
    my ( $oldPicsString , $newString )  = split ( /\",\"/, $line ) ;
    $newString  =~ s/[^\/]+$// ;
    # print "$newString\n" ;
    my @oldfilearray = split( /;/, $oldPicsString ) ;
    
    foreach  ( @oldfilearray ) {
        print OUTFILE "sudo cp -au $_\t$newString\n" ;
    }
}

close OUTFILE;
close FILE;
