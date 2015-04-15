#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: proxychange.pl
#
#        USAGE: ./proxychange.pl  
#
#  DESCRIPTION: set best proxyserver for SS
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 04/13/2015 10:56:53 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use Tie::File;

open my $fh , "/home/kk/Dropbox/Documents/shadowsocks_list.txt" || die $!;

my $hostArray = join " ",                   # join " " with first column 
                map {  s/^(\S+).*/$1/sr }   # get first column 
                readline($fh);              # get line array

#-------------------------------------------------------------------------------
#  /usr/sbin/fping
#  -s   Print cumulative statistics upon exit.
#  -q   Quiet. Don't show per-probe results, but only the final summary. Also 
#        don't show ICMP error messages.
#  -c   n Number of request packets to send to each target.  In this mode, 
#        a line is displayed for each received response (this can suppressed 
#        with -q or -Q).  Also, statistics about responses for each target 
#        are displayed when all requests have been sent (or when interrupted).
#-------------------------------------------------------------------------------
my @fpingResult = `sudo fping -s -q -c 10 $hostArray 2>&1` ;


#-------------------------------------------------------------------------------
#  [ "fpingResult", "lostRate", "response time" ] ;
#-------------------------------------------------------------------------------
my @host_Schwartzian_AOA;              

foreach (@fpingResult) {
    if ( $_ =~ /^\w/ ) {
         $_ =~ m{.*/
                (\d+)           # $1, as lostRate% in INTEGER
                \%.*?/
                ([^/]*?)        # $2, as average msec respone time
                /[^/]*?$}x ; 
         if ( defined  $1 && defined $2 ) {
             push @host_Schwartzian_AOA , [ "$_" , "$1", "$2" ];
         }
    }
}

my @SortedHostArray = map { $_->[0] } 
                      sort {
                           $a->[1] <=> $b->[1]   # sort the lostRate  
                           ||
                           $a->[2] <=> $b->[2]   # then the response time
                      }
                      @host_Schwartzian_AOA ;

my $bestProxy = +(                          # choose the 1st 
                    map {s/^(\S+).*/$1/r}   # first colum for the @SortedHostArrayn
                    @SortedHostArray        
                )[0];                      
chomp ( $bestProxy );

#-------------------------------------------------------------------------------
#  edit config file
#-------------------------------------------------------------------------------
tie my @configArray, 'Tie::File', "/opt/shadowsocks/config.json" or die ;
if ( $configArray[3] ) {
    $configArray[3] =~ s/(?<=")(.*?)(?=:)/$bestProxy/;
};
untie @configArray;

system("sudo /etc/init.d/shadowsocks restart");
