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

my $rsyncResult = qx#ssh fileserver.kk.igb " ps -ef | grep rsync.*datlet | wc -l "#;

my $if_mounted=qx{df | grep \"/media/usb_phdd\"};


unless ( $if_mounted ) {
    print "please insert usb";
    exit ;
}


unless ( -d "/media/usb_phdd/home/kk/Downloads/togo/" ) {
    qx#find /media/usb_phdd/home/kk/Downloads/togo/ -type d -empty -print0 | xargs -0 -I {} /bin/rmdir "{}"#;
    qx#mkdir -p /media/usb_phdd/home/kk/Downloads/togo/#;
}

unless ( $rsyncResult > 3 ) {
    qx#rsync --remove-source-files -azu fileserver.kk.igb:/home/kk/Downloads/togo/ /media/usb_phdd/home/kk/Downloads/togo#;
}
else {
    print "fileserver is running rsync, please try again later";
}

