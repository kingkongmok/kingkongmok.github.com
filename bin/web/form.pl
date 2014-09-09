#!/usr/bin/perl
#===============================================================================
#
#         FILE: form.pl
#
#        USAGE: ./form.pl  
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
#      CREATED: 10/17/2013 05:27:49 PM
#     REVISION: ---
#===============================================================================

#use strict;
#use warnings;


use CGI qw(:cgi);                       # Include CGI functions
use CGI::Carp qw(fatalsToBrowser);      # Send error messages to browser


#
# Generate an HTML page and start a list.
#

print <<END_of_HTML;
Content-type: text/html

<HTML>
 <HEAD>
  <TITLE> Thank You</TITLE>
 </HEAD>

 <BODY>
  <H1>Order Confirmation</H1>
  <UL>
END_of_HTML

#
# Now print a list of all parameters and their values.
#

    foreach $key (param) {
    @values = param($key);
    print "<LI><B>$key:</B> ";
        print join(", ",@values),"</LI>\n";
    }

#
# ...and finally close list and finsh page.
#

print <<END_of_HTML;
  </UL>
 </BODY>

</HTML>
END_of_HTML

