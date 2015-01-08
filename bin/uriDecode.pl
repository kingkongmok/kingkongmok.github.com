#!/usr/bin/perl
#===============================================================================
#
#         FILE: htmlStringEscape.pl
#
#        USAGE: ./htmlStringEscape.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 02/14/2014 05:22:10 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use URI::Encode qw/uri_decode/;

print uri_decode(<>);
