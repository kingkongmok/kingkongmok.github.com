#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: checkDomainExpire.pl
#
#        USAGE: ./checkDomainExpire.pl  
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
#      CREATED: 08/15/2016 03:24:41 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use Data::Dumper;
use feature 'say';

use Date::Parse;
use Net::Domain::ExpireDate;

my $now = time;

my @server = (
    "baidu.com",
);

foreach ( @server ) {
    my $expiration_str  = expire_date( $_, '%Y-%m-%d' );
    if ( $expiration_str ) {
        my $time = str2time $expiration_str;
        if ( $time - $now < 30*24*60*60 ) {
            say "$_ expire date is $expiration_str, please check it.";
        }
    }
}

