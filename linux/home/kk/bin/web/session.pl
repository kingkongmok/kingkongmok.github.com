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
my $session = new CGI::Session(undef, $cgi, {Directory=>'/tmp'});
$session->expire(20);


if ( $session->param("name") ) {
    if ( $cgi->param("logout") ) {
        print $session->header, "you\'re logging out.";
        $session->delete();
    }
    else {
        print $session->header, "hello ", $session->param("name"), "\n";
    }
}
else {
    if ( $cgi->param("name"))  {
        print $session->header(), "you just sigin in as ", $cgi->param("name");
        $session->save_param($cgi,["name","sex","web"]);
    }
    else {
        print $session->header(), "welcome stranger, please loggin.\n" ;
    }
}
