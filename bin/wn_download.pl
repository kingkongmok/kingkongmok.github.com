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
use Getopt::Std;

getopts('f');
our($opt_f);

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

use Tie::File; 
tie my @lines , "Tie::File", "/home/kk/Dropbox/comic_download.list" or die $!; 
# tie my @lines , "Tie::File", "/tmp/list.txt" or die $! ; 

# while ( @lines ){
my $index = 0;
my @deleteLines;
foreach my $line ( @lines ){
    my $result = 1;
    $line =~ s/photos/download/;
    my $message = `/usr/bin/proxychains4 curl $line`; 
    if ($message){
        if ( $message =~ /download_filename\"\>(.*?.zip)\<\/p\>
            .*?
            (http:\/\/wnacg.download\/down.*?zip)
            /sxm ){
            my $DownloadUrl = $2 ; 
            my $DownloadFilename = $1 ; 
            if (  exists $downloaded_url{$DownloadUrl} && ! $opt_f){ 
                print "$DownloadFilename 已经下载过。\n";
                $result = 0;
            } else {
                $result = system("/usr/bin/proxychains4 curl -C -  \"$DownloadUrl\"" . 
                    " -o /home/kk/Downloads/\"$DownloadFilename\""); 
                if ( $result == 0 ) {
                    system("echo $DownloadUrl \"$DownloadFilename\"" .
                        " >> $record_file")   ; 
                }
            }
        }
        if ( $result == 0 ) {
            push @deleteLines, $index; 
        }
    }
    $index++;
} 


foreach ( reverse @deleteLines ) {
    splice @lines,$_,1;
}

untie @lines ; 
