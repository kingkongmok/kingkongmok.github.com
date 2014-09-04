#!/usr/bin/perl
#===============================================================================
#
#         FILE: helloKK.pl
#
#        USAGE: ./helloKK.pl  
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
#      CREATED: 10/22/2013 04:37:01 PM
#     REVISION: ---
#===============================================================================

#use strict;
#use warnings;

use CGI;
use CGI::Carp qw/fatalsToBrowser/;

my $q = new CGI;


print $q->header;

if ( $q->param("name") ) {
    my $username = $q->escapeHTML($q->param("name")) ;
    print $q->p("hello $username")
}
else {
    print $q->start_form(-action=>"helloKK.pl"),
    $q->p("please insert your name"),
    $q->input({-name=>"name"}),
    $q->submit,
    $q->end_form;
}
