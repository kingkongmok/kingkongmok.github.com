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

use Tie::File;
use Fcntl 'O_RDWR';
use strict;

my (@lines);
my $o = tie @lines, 'Tie::File', "/tmp/test.txt", recsep => "\n", memory => 0, mode => "O_TRUNC" ;
$o->flock;
my $new_lines = ("my new line");
push(@lines, $new_lines);
$o = undef;
untie @lines;
