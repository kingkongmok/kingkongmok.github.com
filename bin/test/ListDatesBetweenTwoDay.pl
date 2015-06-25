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
#      CREATED: 06/24/2015 04:47:04 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use feature 'say';

use Date::Simple qw/date/;
use Date::Range;


my ( $start, $end ) = ( date('2005-08-29'), date('2005-09-02') );
my $range = Date::Range->new( $start, $end );
my @all_dates = $range->dates;
use Data::Dumper;
print join",",@all_dates;
