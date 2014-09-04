#!/usr/bin/perl
#===============================================================================
#
#         FILE: filedownload.pl
#
#        USAGE: ./filedownload.pl  
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
#      CREATED: 11/16/2013 09:21:58 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use CGI ':standard';  
use CGI::Carp qw(fatalsToBrowser);   

my $files_location;   
my $ID;   
my @fileholder;  
  
#$files_location = "/usr50/home/webdata/photos";  
$files_location = "/tmp";  
$ID = param('ID');  
  
if ($ID eq '') {   
    print "Content-type: text/htmlnn";   
    print "You must specify a file to download.";   
} else {  
    open(DLFILE, "<$files_location/$ID") || die "$!";   
    @fileholder = <DLFILE>;   
    close (DLFILE) || Error ('close', 'file');   
    print "Content-Type:application/x-downloadn";   
    print "Content-Disposition:attachment;filename=$ID\n\n";  
    print @fileholder  
}
