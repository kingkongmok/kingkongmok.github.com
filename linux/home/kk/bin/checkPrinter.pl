#!/usr/bin/perl
#===============================================================================
#
#         FILE: chechPrinter.pl
#
#        USAGE: ./chechPrinter.pl  
#
#  DESCRIPTION: check printer status ;
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 03/03/2014 09:33:56 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

require LWP::UserAgent;
require LWP::Simple;
use HTTP::Response ;
use Mail::Sendmail ;
use DateTime;


my @websites = qw( 
    https://192.1.6.110/
);
my $tomailuser='kk@gentoo.kk.igb';
my $frommailuser='kk@gentoo.kk.igb';

our $dt = DateTime->now ;
our $lockfile = "/tmp/checkPrinter.lock" ;
my $ua = LWP::UserAgent->new;

#-------------------------------------------------------------------------------
#  http://stackoverflow.com/questions/336575/can-i-force-lwpuseragent-to-accept-an-expired-ssl-certificate
#   Can I force LWP::UserAgent to accept an expired SSL certificate?
#-------------------------------------------------------------------------------
$ua->ssl_opts(verify_hostname => 0,
              SSL_verify_mode => 0x00); 

foreach my $website ( @websites ) {
    my $response = $ua->get($website);
    if ( $response->is_success ) {
        if ( $response->content =~ /LaserJet P2055d/ ) {
            unlink($lockfile);
        }
        else {
             mailError("HP2055 printer is not attached."); 
        }
    }
    else {
         mailError("the printer server is unfunc"); 
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
