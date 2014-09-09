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
use HTML::Entities;

my $string = 'EPSON%20LQ-730K%20Windows%20XP%e9%a9%b1%e5%8a%a8%e7%a8%8b%e5%ba%8f.exe';
my $htmlstring = 'EPSON/e xe';

print HTML::Entities::decode($htmlstring); ;


