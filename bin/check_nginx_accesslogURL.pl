#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: test.pl
#
#        USAGE: ./test.pl  
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
#      CREATED: 01/11/2016 09:45:12 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use Data::Dumper;
use feature 'say';

my @urls = (
    "/phpinfotest.php", 
    "/phpinfo.php", 
    "/index.html",
);



#-------------------------------------------------------------------------------
#  don't edit below
#-------------------------------------------------------------------------------

sub analyze {
    my $fh = shift;
    my $urls = shift;
    my %H ;
    my %K ;
    while ( <$fh> ) {
        if ($_ =~ /:(\d{2}:\d{2}):\d{2} \+0800\]/){
            my $time = $1; 
            my @F = split ;
            $K{$time}++;
            if ( grep /$F[6]/, @$urls ) {
                $H{$time}{$F[6]}++;
            }
            else {
                $H{$time}{"other"}++;
            }
        }
    }
    return (\%H , \%K);
} ## --- end sub analyze

sub display {
    my	( $par1 )	= @_;
    return ;
} ## --- end sub display

sub printForm {
    my	$urls = shift;
    my $H = shift;
    my $K = shift;
    foreach ("timeForm", @$urls, "other", "total") {
        printf "%20s", $_; 
    }
    print "\n";
    foreach my $time ( sort keys %$H ) {
        printf "%20s", $time, " ";
        foreach my $url ( @$urls ) {
            printf "%20s",  $H->{$time}{$url} ?  $H->{$time}{$url} : "0", " ";
        }
        printf "%20s",  $H->{$time}{"other"} ? $H->{$time}{"other"} : "0", " "; 
        printf "%20s", $K->{$time};
        print "\n";
    }
    return ;
} ## --- end sub printForm

open my $fh, "sudo tail -n 100 /var/log/nginx/access.log |" || die $! ;
my ($H, $K)  = analyze( $fh, \@urls);
# print Dumper $H;
printForm(\@urls, $H, $K);


