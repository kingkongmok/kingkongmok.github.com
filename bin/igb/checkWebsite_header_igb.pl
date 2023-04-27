#!/usr/bin/perl
#===============================================================================
#
#         FILE: chechWebsite.pl
#
#        USAGE: ./chechWebsite.pl  
#
#  DESCRIPTION: check if a website is served.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 02/26/2014 09:32:40 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

require LWP::UserAgent;
use HTTP::Response ;
use Mail::Sendmail ;
#use HTTP::Headers ;
#use File::Temp ;
use DateTime;

my @websites = qw( 
    http://www.igrandbuy.com/
);
my $tomailuser='xxxxx';
my $frommailuser='kk@gentoo.kk.igb';

our $dt = DateTime->now ;
our $lockfile = "/tmp/checkWebsite.lock" ;
my $ua = LWP::UserAgent->new;
$ua->timeout(10);

foreach my $website ( @websites ) {
    my $response = $ua->get($website);
    if ( $response->is_success ) {
        my $headerlength = $response->header("Content-Length") ;
        if ( $headerlength < 10000000 ) {
#        if ( $headerlength < 160000 ) {
             mailError("$website Content Length is $headerlength");
         }
         else {
            if ( -e $lockfile ) {
                unlink($lockfile);
            }
         }
    }
    else {
         mailError("$website is not response."); 
    }
}

sub mailError {
    use Mail::Sendmail ;
    if ( my $dt = &filelock ) {
        my	( $errorMessage )	= @_;
        my %errormail = ( To=>$tomailuser,
            From=>$frommailuser,
            Message=>"$errorMessage at $dt",
        );
        sendmail(%errormail) ||  die $Mail::Sendmail::error;
    }
    return ;
} ## --- end sub mailError

sub filelock {
    my	( $par1 )	= @_;
    if ( -e $lockfile ) {
        return 0;
    }
    else {
        open my $fh , "> ", $lockfile;
            print $fh $dt->ymd.'T'.$dt->hms;
        close $fh ;
        return $dt->ymd.'T'.$dt->hms;
    }
} ## --- end sub filelock
