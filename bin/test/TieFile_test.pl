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

use SettingsGeneral;

use Tie::File;
use Fcntl 'O_RDWR';
use strict;
my $command = $ARGV[0];

sub readonly_test {
    use Fcntl 'O_RDONLY';
    my $count;
    tie my @FILE, 'Tie::File', "/home/kk/Documents/logs/11.log", mode => O_RDONLY, memory => 20_000_000;
    foreach ( @FILE ) {
        $count++ if /mmsdk:postactlog/;
    }
    untie @FILE;
    return $count ;
} ## --- end sub readonly_test



print &readonly_test;
