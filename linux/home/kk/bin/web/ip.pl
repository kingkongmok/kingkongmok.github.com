#!/usr/bin/perl
#===============================================================================
#
#         FILE: ip.pl
#
#        USAGE: ./ip.pl  
#
#  DESCRIPTION: get custemer's ip by perl cgi.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 12/20/2013 02:53:11 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use CGI ;
use CGI::Carp qw/fatalsToBrowser/;

my $cgi = new CGI ;

print $cgi->header,
    "$ENV{REMOTE_ADDR}\n" ;
