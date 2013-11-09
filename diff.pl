#!/usr/bin/perl
#===============================================================================
#
#         FILE: diff.pl
#
#        USAGE: ./diff.pl  
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
#      CREATED: 09/18/2013 03:26:25 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

chomp(my@f1=qx"cat /home/kk/f1");
chomp(my@f2=qx"cat /home/kk/f2");



use Data::Dumper;
print Dumper(map{$_=>1} @f1);


