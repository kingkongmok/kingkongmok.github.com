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

sub torrentFileSearch {
    my	( $keyword )	= @_;
    my @torrentResult;
    my @torrentFiles = glob("~/Dropbox/var/log/mldonkey/torrentJoin.log");
    foreach my $torrentFile ( @torrentFiles ) {
        if ( -r $torrentFile ) {
            foreach my $word ( @{$keyword} ) {
                open my $fh , "< $torrentFile";
                while ( <$fh> ) {
                    push @torrentResult,$_ if /$word/i ;
                }
            }
        }
    }
    my %seen;
    my @removeduplicate = grep { !$seen{$_}++ } @torrentResult;

    return @removeduplicate;
} ## --- end sub torrentFileSearch

sub emuleFileSearch {
    my	( $keyword )	= @_;
    my @emuleResult;
    my @emuleFiles = glob("~/Dropbox/var/log/mldonkey/magnet.log");
    foreach my $emuleFile ( @emuleFiles ) {
        if ( -r $emuleFile ) {
            foreach my $word ( @{$keyword} ) {
                open my $fh , "< $emuleFile";
                while ( <$fh> ) {
                    push @emuleResult,$_ if /^(Added link :|Added link :|BitTorrent: ).*$word/i ;
                }
            }
        }
    }
    my %seen;
    my @removeduplicate = grep { !$seen{$_}++ } @emuleResult;

    return @removeduplicate;
} ## --- end sub emuleFileSearch

sub comicSearch {
    my	( $keyword )	= @_;
    my @comicResult;
    my @comicFiles = glob("~/Dropbox/var/log/wn_download/*");
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
    my @torrentResult = &torrentFileSearch(\@ARGV) ;
    my @emuleResult = &emuleFileSearch(\@ARGV) ;
    my @baidupanFileResult = &baidupanFileSearch(\@ARGV) ;
    my @mlocateResult = &mlocateSearch(\@ARGV) ;
    my @comicResult = &comicSearch(\@ARGV) ;
    if ( @torrentResult ) {
        say "\n[33;1mDownloaded torrent match[0;49m ";
        say @torrentResult
    }
    if ( @emuleResult ) {
        say "\n[33;1mDownloaded emule match[0;49m ";
        say @emuleResult
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

