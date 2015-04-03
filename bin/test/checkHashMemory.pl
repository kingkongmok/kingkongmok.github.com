#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: checkHashMemory.pl
#
#        USAGE: ./checkHashMemory.pl
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: KK Mok (), kingkongmok@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 02/03/2015 02:49:20 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use Data::Dumper;
use Devel::Size qw/total_size size/;

my ( $filename ) = @ARGV ;
open my $fileout, "> /tmp/fileout";
open my $fh , "< $filename";
my %H ;

while ( <$fh> ) {
    while ( /\s(\S+)/g ) {
        $H{$1}++;
    }
}

print $fileout Dumper \%H;
close $fileout  ;
print "file size ", +(stat "/tmp/fileout")[7] , "\n";

print "hash total_size ", total_size(\%H), "\n";
print "hash size ", size(\%H), "\n";
