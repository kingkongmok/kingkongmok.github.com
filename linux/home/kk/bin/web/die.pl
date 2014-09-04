#!/usr/bin/perl
#===============================================================================
#
#         FILE: die.pl
#
#        USAGE: ./die.pl  
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
#      CREATED: 11/21/2013 11:15:03 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use CGI;
use CGI::Carp qw/fatalsToBrowser/;

my $q = new CGI;
print $q->header;
die $resp->status_line;
