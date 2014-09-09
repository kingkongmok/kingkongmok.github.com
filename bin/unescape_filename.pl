#!/usr/bin/perl -l
#===============================================================================
#
#         FILE: unescape_filename.pl
#
#        USAGE: ./unescape_filename.pl filename
#
#  DESCRIPTION: to rename the file from escaped UNI download name;
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 03/12/2014 11:39:39 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use CGI ;
use File::Basename;

if (@ARGV) {
    my ( $fullname ) = @ARGV ;
    my ($name,$path) = fileparse($fullname);
    
    my $unescapename = CGI->unescape($name);
    if ( $unescapename eq $name ) {
        print "$name do not need unescaped." ;
    }

    chdir ($path);

    if ( ! -e $name ) {
        print "$name is not exists. \n" ;
        exit 23 ;
    }

    if ( ! -w $name ) {
        print "$name is not renamable. \n" ;
        exit 24 ;
    }
    rename $name, $unescapename ;

} else {
    print q{usage: ./unescape_filename FILENAME};
}

