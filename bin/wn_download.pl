#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: wn_download.pl
#
#        USAGE: ./wn_download.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
# ORGANIZATION: datlet.com
#      VERSION: 1.0
#      CREATED: 04/05/2017 10:16:15 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
# use utf8;
use Data::Dumper;
use feature 'say';

my $record_file = "/home/kk/Dropbox/Documents/comic.done"; 
my%downloaded_url ;
my$k;
my$v;

open my $fh , $record_file || die $!; 
while ( <$fh> ) {
    next if /^\s?$/;
    ($k,$v)=split ;
    $downloaded_url{$k}=();
}
close $fh;

use Tie::File ; 
tie my @lines , "Tie::File", "/home/kk/Dropbox/toDown1.txt" or die $! ; 
# tie my @lines , "Tie::File", "/tmp/list.txt" or die $! ; 

while ( @lines ){
    my $line = shift @lines; 
    $line =~ s/photos/download/;
    my $message = `proxychains curl $line`; 
    if ($message){
        if ( $message =~ /download_filename\"\>(.*?.zip)\<\/p\>
            .*?
            (http:\/\/wnacg.download\/down.*?zip)
            /sxm ){
            my $DownloadUrl = $2 ; 
            my $DownloadFilename = $1 ; 


            if (  exists $downloaded_url{$DownloadUrl} ){ 
                print "$DownloadFilename 已经下载过。\n";
            } else {
                system("proxychains curl -C -  \"$DownloadUrl\" -o /home/kk/Downloads/\"$DownloadFilename\"")   ; 
                system("echo $DownloadUrl \"$DownloadFilename\" >> $record_file")   ; 
            }
        }
    }
} 

untie @lines ; 
