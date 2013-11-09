#!/usr/bin/perl
#===============================================================================
#
#         FILE: show.pl
#
#        USAGE: ./show.pl  
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
#      CREATED: 10/17/2013 05:03:53 PM
#     REVISION: ---
#===============================================================================


use CGI qw(:cgi);                       # Include CGI functions
use CGI::Carp qw(fatalsToBrowser);      # Send error messages to browser

print 
<FORM METHOD=POST ACTION="/cgi-bin/cgitutor/form2b.cgi">

Name: <INPUT NAME="name"> 
<p>

Phone: <INPUT NAME="phone"> 
<p>

What food would you like to order.  You can choose more than one.
<p>

<SELECT MULTIPLE NAME="food" SIZE=7>
  <OPTION VALUE="Coke" SELECTED> Coke
  <OPTION VALUE="Pepsi"> Pepsi
  <OPTION VALUE="Orange Juice"> Orange Juice
  <OPTION VALUE="Pizza" SELECTED> Pizza
  <OPTION VALUE="Garlic Bread"> Garlic Bread
  <OPTION VALUE="Apple Pie"> Apple Pie
  <OPTION VALUE="Ice Cream"> Vanilla Ice Cream
</SELECT>

<p>
<INPUT TYPE=submit VALUE="Submit Order">  <INPUT TYPE=reset VALUE="Reset Form"> 

</FORM>
