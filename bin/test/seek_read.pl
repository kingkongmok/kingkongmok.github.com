#!/usr/bin/env perl 
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
#       AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
# ORGANIZATION: datlet.com
#      VERSION: 1.0
#      CREATED: 07/28/2015 11:53:27 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
# use utf8;
use Data::Dumper;
use feature 'say';
use warnings;
use strict;

my $str = <<SNIPS;
Hello all, I am encountering some issue in trying to do the following in ksh88,
therefore I want to explore a smart perl approach, but my knowledge is limited,
can you help?
I have 2 files, the first (indexFile1) contains lines with start
offset and length for each record inside the second file, so just 2 numbers
separated by a space. ...
SNIPS

open my $recData, '<', \$str;

while (<DATA>) {
    chomp;

    my ($start, $len) = split;
    my $segment;

    seek $recData, $start, 0;
    read $recData, $segment, $len;
    print "$segment\n";
}

__DATA__
16 12
80 9
315 10
