#!/usr/bin/perl 
#===============================================================================
#
#         FILE: test1.pl
#
#        USAGE: ./test1.pl  
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
#      CREATED: 08/21/2013 12:10:00 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

open FILE, "<", "desc.csv" or die "$!" ;
open OUTFILE, ">", "change.sh" or die "$!" ;

chomp (my @array = <FILE>);

for ( @array ) {
    s/^\s?"//;
    s/"$//;
}


foreach my $line ( @array  ) {
    $line =~ s/images\/+// ;
    chomp($line);
    (my$oldpath, my$newpath)=split/\",\"/,$line ;
    print OUTFILE "sudo cp -au $oldpath $newpath\n" ;
}
close FILE; 
close OUTFILE; 
