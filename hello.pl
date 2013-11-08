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


use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
print header, start_html("Hello"), h1("Hello");
if (param())    {
    my $who  = param("myname");
    print p("Hello, your name is $who");
}
else    {
    print start_form();         
    print p("What's your name? ", textfield("myname"));
    print p(submit("Submit form"), reset("Clear form"));
    print end_form();
}
print end_html;     
