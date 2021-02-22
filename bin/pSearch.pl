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

sub mlocateSearch {
    my	( $keyword )	= @_;
    my @mlocateResultArray;
    foreach my $word ( @{$keyword} ) {
        my $searchCommand = "locate -i -r '$word' | grep -P \"Downloads|Videos|Pictures\"";
        push @mlocateResultArray , `$searchCommand`;
    }
    my %seen;
    my @removeduplicate = grep { !$seen{$_}++ } @mlocateResultArray;
    return @removeduplicate;
} 

sub baidupanFileSearch {
    my @baidupanResultArray;
    my	( $keyword )	= @_;
    my @baidupanFiles = glob("~/Dropbox/pan/*");
    foreach my $baidupanFile ( @baidupanFiles ) {
        if ( -r $baidupanFile ) {
            foreach my $word ( @{$keyword} ) {
                open my $fh , "< $baidupanFile";
                while ( <$fh> ) {
                    push @baidupanResultArray,$_ if /$word/i ;
                }
            }
        }
    }
    my %seen;
    my @removeduplicate = grep { !$seen{$_}++ } @baidupanResultArray;
    return @removeduplicate;
} ## --- end sub baidupanFileSearch

sub md5FileSearch {
    my	( $keyword )	= @_;
    my @md5Result;
    my @md5Files = glob("~/Dropbox/home/kk/Downloads/mldonkey/*");
    foreach my $md5File ( @md5Files ) {
        if ( -r $md5File ) {
            foreach my $word ( @{$keyword} ) {
                open my $fh , "< $md5File";
                while ( <$fh> ) {
                    push @md5Result,$_ if /$word/i ;
                }
            }
        }
    }
    my %seen;
    my @removeduplicate = grep { !$seen{$_}++ } @md5Result;

    return @removeduplicate;
} ## --- end sub md5FileSearch

sub comicSearch {
    my	( $keyword )	= @_;
    my @comicResult;
    my @comicFiles = glob("/home/kk/Dropbox/var/log/wn_download/*");
    foreach my $comicFile ( @comicFiles ) {
        if ( -r $comicFile ) {
            foreach my $word ( @{$keyword} ) {
                open my $fh , "< $comicFile";
                while ( <$fh> ) {
                    push @comicResult,$_ if /$word/i ;
                }
            }
        }
    }
    my %seen;
    my @removeduplicate = grep { !$seen{$_}++ } @comicResult;

    return @removeduplicate;
} ## --- end sub comicFileSearch


if ( @ARGV ) {
    my @md5FileResult = &md5FileSearch(\@ARGV) ;
    my @baidupanFileResult = &baidupanFileSearch(\@ARGV) ;
    my @mlocateResult = &mlocateSearch(\@ARGV) ;
    my @comicResult = &comicSearch(\@ARGV) ;
    if ( @md5FileResult ) {
        say "\n[33;1mDownloaded torrent match[0;49m ";
        say @md5FileResult
    }
    if ( @baidupanFileResult ) {
        say "\n[33;1mBaidupan match[0;49m ";
        say @baidupanFileResult
    }
    if ( @comicResult ) {
        say "\n[33;1mDownloaded Comic match[0;49m ";
        say @comicResult
    }
    if ( @mlocateResult ) {
        say "\n[33;1mMlocate match[0;49m ";
        say @mlocateResult
    }
}
else {
    &usage ;
}

