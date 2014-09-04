#!/usr/bin/perl
#===============================================================================
#
#         FILE: pSearch.pl
#
#        USAGE: ./pSearch.pl  
#
#  DESCRIPTION: search p from mlocatedb and md5file
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 03/29/2014 10:17:01 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use lib '/home/kk/workspace/perl';
use KK::Gpgutil;
use KK::Mlocate;

sub usage {
print <<END
usage: pSearch.pl pattern..
END
;
} ## --- end sub usage

sub locateSearch {
    my	( $keyword )	= @_;
    return ;
} ## --- end sub locateSearch

sub getLocateFile {
    my	( $par1 )	= @_;
    return ;
} ## --- end sub getLocateFile

sub getMd5File {
    my	( $par1 )	= @_;
    return ;
} ## --- end sub getMd5File

sub mlocateSearch {
    my	( $keyword )	= @_;
    my %mlocateResult;
    my $mlocatedbDropboxLocation = '/home/kk/Dropbox/home/kk/Documents/personal/mlocate.db.asc' ;
    my $mlocatedbLocation = '/home/kk/Documents/personal/mlocate.db' ;
    if ( -r $mlocatedbLocation && -r $mlocatedbDropboxLocation ) {
        if ( -M $mlocatedbLocation > -M $mlocatedbDropboxLocation ) {
            system("/home/kk/bin//transfterDropboxGPG.pl /home/kk/Dropbox/home/kk/Documents/personal/mlocate.db.asc");
        }
        print "not going to decrypt\n\n";
    }
    else {
        system("/home/kk/bin//transfterDropboxGPG.pl /home/kk/Dropbox/home/kk/Documents/personal/mlocate.db.asc");
    }
    foreach my $word ( @{$keyword} ) {
        my $searchCommand = "locate -d /home/kk/Documents/personal/mlocate.db -i -r '$word'";
        my @mlocateResult = system($searchCommand);
        $mlocateResult{$word}=[@mlocateResult];
    }
    return %mlocateResult;
} 

sub md5FileSearch {
    my %md5Result;
    my	( $keyword )	= @_;
    my $md5File= '/home/kk/Dropbox/Downloads/mldonkey/torrent_done_before.md5';
    if ( -r $md5File ) {
        foreach my $word ( @{$keyword} ) {
            my @md5Result;
            open my $fh , "< $md5File";
            while ( <$fh> ) {
                push @md5Result,$_ if /$word/i ;
            }
            $md5Result{$word}=[@md5Result];
        }
    }
    return %md5Result;
} ## --- end sub md5FileSearch


if ( @ARGV ) {
    my %md5FileResult = &md5FileSearch(\@ARGV) ;
    my %mlocateResult = &mlocateSearch(\@ARGV) ;
use Data::Dumper;


print Dumper(\%md5FileResult);
print Dumper(\%mlocateResult);

}
else {
    &usage ;
}

