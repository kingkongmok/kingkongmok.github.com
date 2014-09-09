#!/usr/bin/perl
#===============================================================================
#
#         FILE: test.pl
#
#        USAGE: ./test.pl  
#
#  DESCRIPTION: open files from directory. Merged all words into array, uniq them.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 03/01/2014 12:16:45 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;



my $path = "/tmp/test" ;
opendir(DIR, $path) or die $!;
my @FILES=readdir(DIR);
closedir(DIR);

chdir($path);
foreach my $file ( @FILES ) {
    my %hash ;
    if (  -f $file && -r $file  ) {
        open my $fh, "<" , $file ;
        my @array ;
        while ( <$fh> ) {
            chomp ;
            push @array, ( split/\s+/,$_ ) ; 
        }
        @hash{@array}=();
        print keys%hash , "\n";
    }
}
