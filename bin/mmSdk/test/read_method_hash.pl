#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: read_method_hash.pl
#
#        USAGE: ./read_method_hash.pl logfile
#
#  DESCRIPTION: print http_method_count.hash.log, printout method status
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 04/10/2015 11:28:55 AM
#     REVISION: ---
#===============================================================================

# use strict;
# use warnings;
use Data::Dumper;
use utf8;

use Storable qw(store retrieve);
my $hashFile = $ARGV[0] // "/tmp/http_method_count.hash.log" ;
my $httpMethodCount = retrieve("$hashFile");

my %newHash; 
while ( my($time,$subHash) = each %{$httpMethodCount} ) {
    while ( my($method, $pv)=each %{$subHash} ) {
        $newHash{$method}+=$pv;
    }
}

printf "%10i %s\n",$newHash{$_},$_ for sort{$newHash{$a} <=> $newHash{$b}} keys %newHash;
