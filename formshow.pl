#!/usr/bin/perl
#===============================================================================
#
#         FILE: formshow.pl
#
#        USAGE: ./formshow.pl  
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
#      CREATED: 10/21/2013 03:55:46 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use CGI;

my $q = new CGI ;
my $default_user_name = $q->param("value") || "name_here" ;
my $default_user_age = $q->param("age") || "8?" ;

print 
$q->header,
$q->start_html,
$q->start_form(
-action=>"displayform.pl",
-name=>"submit",
),
$q->input({-name=>"name",-value=>$default_user_name}),
$q->input({-name=>"age"}),
$q->submit();
$q->end_form,
$q->end_html;
