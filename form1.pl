#!/usr/bin/perl
#===============================================================================
#
#         FILE: form1.pl
#
#        USAGE: ./form1.pl  
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
#      CREATED: 10/18/2013 04:59:45 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use CGI::Carp qw(fatalsToBrowser);

use CGI;
my $cgi = new CGI ;
print $cgi->header(-charset=>"utf-8");
if (  $cgi->param ) {

print $cgi->start_ul ;
        print $cgi->li($cgi->param("name"));
        print $cgi->li("hello");
        print $cgi->li($cgi->param("lastname"));
print $cgi->end_ul ;
}
