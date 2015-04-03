#!/usr/bin/perl
#===============================================================================
#
#         FILE: downloadEShopBackup.pl
#
#        USAGE: ./downloadEShopBackup.pl  
#
#  DESCRIPTION: to download http://192.9.9.19:81 backup file 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 01/25/2014 03:47:08 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

my $string = qx#curl -s http://192.9.9.19:81/#;
my @splitResult = split'\s+',$string ;
my @filesList ;

while ( $string =~ m/(\S+)(?=\s+)/gsm ) {
    if ( $1 =~ m#(?<=HREF="/)(\S+?\.bak)(?="\>)# ) {
         push @filesList,"$1" ;
    }
}

my $fileToDown= $filesList[-1];

my $fileLength = &getDownloadFileLength ;

if ( $fileLength > 21071070208 ) {
    system("mv /var/spool/samba/kk/9.19_database_backup/latest.bak /var/spool/samba/kk/9.19_database_backup/yesterday.bak") == 0 or die "move failed";
    system("curl -s http://192.9.9.19:81/$fileToDown -o /var/spool/samba/kk/9.19_database_backup/latest.bak") ;
}
else {
    system("echo backup http 9.9.19 backup failed| mailx -s backFailed kk\@gentoo.kk.igb");
}

sub getDownloadFileLength {
    my $result = 0;
    my @curlResult = qx"curl -s -I http://192.9.9.19:81/$fileToDown";     
    foreach my $thisresult ( @curlResult ) {
        $result = $1 if $thisresult =~ /Content-Length: (\S+)/;
    }
    return $result ;
} ## --- end sub getDownloadFileLength
