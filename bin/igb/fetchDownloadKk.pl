#!/usr/bin/perl
#===============================================================================
#
#         FILE: fetchDownload.pl
#
#        USAGE: ./fetchDownload.pl  
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
#      CREATED: 10/28/2013 05:18:44 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

my $rsyncResult = qx#ps -ef | grep rsync | wc -l#;

my $if_mounted=qx{df | grep \"/media/usb_phdd\"};


unless ( $if_mounted ) {
    print "please insert usb";
    exit ;
}

unless ( -d "/media/usb_phdd/home/kk/Downloads/togo/" ) {
    print "not found folder in usb";
}

unless ( $rsyncResult > 3 ) {
    qx#rsync --remove-source-files -azu /media/usb_phdd/home/kk/Downloads/togo/ /home/kk/Downloads#;
}
else {
    print "running rsync, please try again later";
}

