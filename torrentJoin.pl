#!/usr/bin/perl
#===============================================================================
#
#         FILE: torrentJoin.pl
#
#        USAGE: ./torrentJoin.pl  
#
#  DESCRIPTION: check MD5s foreach torrents from Downloads directory, then
#   put the uniq one into rtorrent's watch dir; 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 09/29/2013 03:46:59 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
my$dir="/home/kk/Downloads";
#my$md5file="/home/kk/Dropbox/torrent_done_before.md5";

#open FH,"</home/kk/.mldonkey/done_before.md5";
open FH,"</home/kk/Dropbox/torrent_done_before.md5";
my%md5record ;
my$k;
my$v;

while ( <FH> ) {
    next if /^\s?$/;
    ($k,$v)=split ;
    $md5record{$k}=$v;
}
close FH;

opendir(DIR, $dir) || die "can't opendir $dir: $!";
my@files = grep { /\.torrent/ && -f "$dir/$_" } readdir(DIR);
closedir DIR;

foreach my $file ( @files ) {
    my$filemd5 = qx#md5sum "$dir/$file"# ;
    if (  exists $md5record{+(split/\s/,$filemd5)[0]} ){
        print " $dir/$file 已经下载过。\n"; 
    } else {
        #qx#echo -n "$filemd5" >> /home/kk/.mldonkey/done_before.md5# ;
        qx#echo -n "$filemd5" >> /home/kk/Dropbox/torrent_done_before.md5# ;
        qx#mv "$dir/$file" /home/kk/.mldonkey/torrents/incoming/#;
    }
}
