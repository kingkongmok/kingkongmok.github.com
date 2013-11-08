#!/usr/bin/perl
#===============================================================================
#
#         FILE: upload.pl
#
#        USAGE: ./upload.pl  
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
#      CREATED: 10/22/2013 02:57:36 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use CGI;
use CGI::Carp qw(fatalsToBrowser);

my $q = new CGI;

unless ( $q->param("file") ) {
    print $q->header, 
    $q->p("please insert a file"),
    $q->start_form,
    $q->filefield({-name=>"file"}),
    $q->submit,
    $q->end_form;
}
else {
    my $file = $q->upload("file");
    my $filename = $q->param("file");
    open FILE, "> /tmp/$filename";
    while ( <$file> ) {
        print FILE $_;
    }
    print $q->header, $q->p("$filename is saved");
}
