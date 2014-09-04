#!/usr/bin/perl
#===============================================================================
#
#         FILE: mail.pl
#
#        USAGE: ./mail.pl  
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
#      CREATED: 11/08/2013 12:21:28 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use strict;
use warnings;
 
use CGI qw(:standard);          # Include standard HTML and CGI functions 
use CGI::Carp qw(fatalsToBrowser);  # Send error messages to browser 
 
 
my $sendmail = '/usr/lib/sendmail';    # Set the path for sendmail (don't use mail!!!) 
 
 
# 
# Start by printing the content-type, the title of the web page and a heading. 
#        
 
 
print header, start_html("Email Form"), h1("Email Form"); 
 
if (param()) {                  # If true,the form has already been filled out. 
 
    my $address = param("address");        # Extract the values passed from the form.
    my $subject = param("subject");           
    my $message = param("message");           
 
    open (MAIL, "| $sendmail -t") or die "Can't open pipe to $sendmail:$!\n"; 
    print MAIL "To: $address\n"; 
    print MAIL "Subject: $subject\n\n";         # Insert blank line between mail headers and message. 
    print MAIL "$message\n"; 
    close(MAIL) or die "Can't close pipe to $sendmail:$!\n"; 
 
    print p("Email has been sent to $address"); # Print confirmation. 
 
} 
else {                      # Else, first time through so present form. 
 
        print start_form();                     
        print p("Enter Email address? ", textfield("address"));
        print p("Enter Subject? ", textfield("subject"));
        print p("Enter Message? ", textarea("message"));
        print p(submit("Submit form"), reset("Clear form"));
        print end_form();
}
print end_html;
