#!/usr/bin/perl
#===============================================================================
#
#         FILE: temp.pl
#
#        USAGE: ./temp.pl  
#
#  DESCRIPTION: using the File::Temp on cpan
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 11/16/2013 09:29:34 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;


use File::Temp qw/ tempfile tempdir /;
my ($fh, $filename) = tempfile();

open $fh, "> $filename" ;

print $fh "hello world" ;

print $filename ;
