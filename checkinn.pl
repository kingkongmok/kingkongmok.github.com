#!/usr/bin/perl
#===============================================================================
#
#         FILE: testget.pl
#
#        USAGE: ./testget.pl  
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
#      CREATED: 10/18/2013 02:33:53 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use CGI ;
my $cgi = new CGI ;

print $cgi->header(-charset=>"utf-8");
my $lang = $cgi->param("name");
my @array; 

if ( $lang ) {
    open my $fh, "< /home/kk/Downloads/2000/2000W/all.csv ";
    while ( <$fh> ) {
        print $_ . "<br>" if $_ =~ $lang ;
    }
}

