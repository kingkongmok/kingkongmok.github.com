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
#      CREATED: 06/17/2015 10:56:09 AM
#     REVISION: ---
#===============================================================================

# use strict;
use warnings;
use utf8;
use feature 'say';
use Data::Dumper;

foreach $symname (sort keys %main::) {
        local *sym = $main::{$symname};
        # print "\$$symname is defined\n" if defined $sym;
        print "\@$symname is nonnull\n" if   @sym;
        print "\%$symname is nonnull\n" if   %sym;
}
