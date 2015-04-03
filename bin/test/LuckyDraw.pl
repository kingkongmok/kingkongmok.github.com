#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: LuckyDraw.pl
#
#        USAGE: ./LuckyDraw.pl  
#
#  DESCRIPTION:  programming perl p465 lotto
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: KK Mok (), kingkongmok@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 12/22/2014 02:33:45 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

package LuckyDraw;

use overload "<>" => sub { my $self = shift;
        return splice @$self, rand @$self, 1;
    };
sub new {
    my $class = shift;
    return bless [@_] => $class;
}

package main;
my $lotto = new LuckyDraw 1 .. 51;
for (qw(1st 2nd 3rd 4th 5th 6th)) {
    my $lucky_number = <$lotto>;
    print "The $_ lucky number is: $lucky_number.\n";
}

my $lucky_number = <$lotto>;
print "\nAnd the bonus number is: $lucky_number.\n";

