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
use lib '/home/kk/bin';
use KK::Gpgutil;
use KK::Mlocate;
use feature 'say';

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
    say "\n\nFiles match:\n";
    my %mlocateResult;
    foreach my $word ( @{$keyword} ) {
        my $searchCommand = "locate -i -r '$word' | grep -P \"Videos|Pictures\"";
        my @mlocateResult = system($searchCommand);
        $mlocateResult{$word}=[@mlocateResult];
    }
    return %mlocateResult;
} 

sub md5FileSearch {
    my %md5Result;
    my	( $keyword )	= @_;
    my @md5File= [
        '/home/kk/Dropbox/home/kk/Downloads/mldonkey/torrent_done_before.md5',
        '/home/kk/Dropbox/Documents/comic.done',
    ];
    foreach my $md5File ( @md5File ) {
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
}
    return %md5Result;
} ## --- end sub md5FileSearch

sub comicSearch {
    my %comicResult;
    my	( $keyword )	= @_;
    my $comicFile= '/home/kk/Dropbox/Documents/comic.done';
    if ( -r $comicFile ) {
        foreach my $word ( @{$keyword} ) {
            my @comicResult;
            open my $fh , "< $comicFile";
            while ( <$fh> ) {
                push @comicResult,$_ if /$word/i ;
            }
            $comicResult{$word}=[@comicResult];
        }
    }
    return %comicResult;
} ## --- end sub comicFileSearch


if ( @ARGV ) {
    my %md5FileResult = &md5FileSearch(\@ARGV) ;
    my %mlocateResult = &mlocateSearch(\@ARGV) ;
    my %comicResult = &comicSearch(\@ARGV) ;
    if ( keys %md5FileResult ) {
        say "\n\ntorrent match:\n";
        foreach my $keys ( @ARGV ) {
            say $keys , " :";
            say @{$md5FileResult{$keys}};
        }
    }
    if ( keys %comicResult ) {
        say "\n\ncomic match:\n";
        foreach my $keys ( @ARGV ) {
            say $keys , " :";
            say @{$comicResult{$keys}};
        }
    }
}
else {
    &usage ;
}

