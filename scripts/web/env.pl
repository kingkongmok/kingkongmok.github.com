#!/usr/bin/perl
#===============================================================================
#
#         FILE: test.pl
#
#        USAGE: ./test.pl  
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
#      CREATED: 10/15/2013 05:02:39 PM
#     REVISION: ---
#===============================================================================
use CGI;

print "Content-type:text/html\n\n";
print <<EndOfHTML;
<html><head><title>Perl Environment Variables</title></head>
<body>
<h1>Perl Environment Variables</h1>
EndOfHTML
my$q=new CGI;
foreach $key (sort(keys %ENV)) {
#-------------------------------------------------------------------------------
#  specify keys for parameter "name";
#-------------------------------------------------------------------------------
#    if ( $q->param("name") eq "$key") {
#        print "$key = $ENV{$key}<br>\n";
#    }
        print "$key = $ENV{$key}<br>\n";
}

print "</body></html>";
