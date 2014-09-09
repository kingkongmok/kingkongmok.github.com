#!/usr/bin/perl
#===============================================================================
#
#         FILE: href.pl
#
#        USAGE: ./href.pl  
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
#      CREATED: 10/21/2013 03:38:16 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use CGI; 

my $cgi = new CGI ;
my $username = "kingkongmok";
print $cgi->header ,
$cgi->start_html ,

$cgi->a ( { -href=>"http://www.google.com/" }, "$username" ),
$cgi->end_html ;
