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
my $default_user_name = $q->param("value") || "" ;

print 
$q->header(-charset=>"utf-8"),
$q->start_html(-title => "酒店记录查询"),
$q->start_form(
-action=>"checkinn.pl",
-name=>"submit",
),
$q->p("这是之前漏出的酒店登记记录，可输入姓名地址电话进行查询"),
$q->input({-name=>"name",-value=>$default_user_name}),
$q->submit(-value=>"给我查！");
$q->end_form,
$q->end_html;
