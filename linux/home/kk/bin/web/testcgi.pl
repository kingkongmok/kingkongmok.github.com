#!/usr/bin/perl
#===============================================================================
#
#         FILE: testcgi.pl
#
#        USAGE: ./testcgi.pl  
#
#  DESCRIPTION: test cgi 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 11/18/2013 04:18:20 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use CGI;
use CGI::Carp qw/fatalsToBrowser/;

my$q=new CGI;
#my $name ='<><><><>';
my $name ='<t100&lt';

#print $q->header(),
#    $q->start_html("hello world!"),
#    $q->p($q->escapeHTML("hello $name"));
#    $q->end_html;

print $q->p($name) ;
print "\n";
print $q->escape($q->p($name)) ;
print "\n";
print $q->unescape($q->p($name)) ;
print "\n";
print $q->escapeHTML($q->p($name)) ;
print "\n";
print $q->unescapeHTML($q->p($name)) ;
