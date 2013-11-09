#!/usr/bin/perl
#===============================================================================
#
#         FILE: testreg.pl
#
#        USAGE: ./testreg.pl  
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
#      CREATED: 10/17/2013 05:01:51 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

my $str = "hello";
my $reg = qr/.e/;
if($str =~ $reg){
print 'ok';
}

