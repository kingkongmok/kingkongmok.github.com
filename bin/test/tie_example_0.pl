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
#      CREATED: 06/05/2015 03:52:50 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

package Centsible;
sub TIESCALAR { bless \my $self, shift }
sub STORE { 
    ${ $_[0] } = $_[1] 
}      # 做缺省的事情
sub  FETCH { 
    sprintf "%0.2f", 
        ${ my $self = shift } 
}    # 圆整值

package main;
tie my $bucks, "Centsible";
$bucks = 45.00;
$bucks *= 1.0715;   # 税
$bucks *= 1.0715;   # 和双倍的税！
print "That will be $bucks, please.\n";
