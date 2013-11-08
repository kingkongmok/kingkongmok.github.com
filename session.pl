#!/usr/bin/perl
#===============================================================================
#
#         FILE: session.pl
#
#        USAGE: ./session.pl  
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
#      CREATED: 10/23/2013 02:48:20 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use CGI;
use CGI::Session;
use CGI::Carp qw/fatalsToBrowser/;

my $cgi = new CGI;

my $sid = $cgi->cookie('CGISESSID') || $cgi->param('CGISESSID') || undef;
my $session = new CGI::Session(undef, $sid, {Directory=>'/tmp'});
$session->param("name", $cgi->param("name"));

print $session->header ;
if ( $session->param ) {
    print "hello, ",$session->param("name"),
    $cgi->url,
    $cgi->Vars;
}
else {
    $session->save_param($cgi);
}

