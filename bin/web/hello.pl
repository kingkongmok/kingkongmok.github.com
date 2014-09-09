#!/usr/bin/perl
#===============================================================================
#
#         FILE: hello.pl
#
#        USAGE: ./hello.pl  
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
#      CREATED: 10/18/2013 12:07:57 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);

my $q = new CGI ;
chomp(my $hostname = qx/hostname -f/);

print $q->header(-charset=>"utf-8"), $q->start_html;

    
if ( my $username = $q->param("name") ) {
    print $q->p("Hi $username, welcome to $hostname\.") ;
}
else {
    print $q->p("welcome, stranger!") ;;
}

print $q->end_html ;

