#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: test.pl
#
#        USAGE: ./test.pl  
#
#  DESCRIPTION: \
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 04/16/2015 04:27:08 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

sub slurp {
    my $count ;
    open my $fh , "/home/kk/Documents/logs/22.log" || die $!;

    while ( <$fh> ) {
        $count++ if /mmsdk:postactlog/;
    }
    return $count ;
} ## --- end sub readonly


print &slurp;
