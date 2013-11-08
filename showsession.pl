#!/usr/bin/perl
#===============================================================================
#
#         FILE: showsession.pl
#
#        USAGE: ./showsession.pl  
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
#      CREATED: 10/24/2013 11:52:20 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use CGI;
use CGI::Session;
use CGI::Cookie;

my $cgi = new CGI;
my $session = new CGI::Session ;
#my $cookie = CGI::Cookie->new(



if ( $cgi->param ) {
if ( my %fetchcookie = CGI::Cookie->fetch ) {
    print $cgi->header,
    $fetchcookie{"name"};
}
else {
my $cookie = new CGI::Cookie(
-name => "kk",
-value => "mok",
) ; 
print $cgi->header, $cgi->p("hello stranger");
}
}


