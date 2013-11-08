#!/usr/bin/perl 
#===============================================================================
#
#         FILE: arrraycreate.pl
#
#        USAGE: ./arrraycreate.pl  
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
#      CREATED: 09/05/2013 03:03:20 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

my @aoa = map {  [ map {int rand 10} 0..9] } 0..9 ;
my @a =  map {int rand 10} 0..9 ;



