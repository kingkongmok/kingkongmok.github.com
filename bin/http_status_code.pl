#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: http_status_code.pl
#
#        USAGE: ./http_status_code.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: KK Mok (), kingkongmok@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 03/13/2015 11:42:38 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use Storable qw(store retrieve);

chomp(my $yesterday = `date -d -1day +%F`);
#-------------------------------------------------------------------------------
#  log location
#-------------------------------------------------------------------------------
#my @logArray = glob "/mmsdk/tomcat_77*/access.$yesterday.*.log" ;
my @logArray = glob "/home/kk/log*.txt" ;
my $outputfilename = "/tmp/http_status_code.txt" ;
my $hashFileLocation = "/tmp/http_status_code.hash";


my $httpstatusref ;
#-------------------------------------------------------------------------------
#  restore hash
#-------------------------------------------------------------------------------
if ( -r $hashFileLocation ) {
    $httpstatusref = retrieve("$hashFileLocation");
}
foreach my $filename ( @logArray ) {
    open my $fh , $filename || die $!;
    while ( <$fh> ) {
        chomp ; 
        if ( /^[^:]+:(\d{2}:\d{2}):\d{2} \+0800\] (\d)\d{2} / ) {
            $httpstatusref->{$1}{$2}++;
        }
    }
}
open my $fho, "> $outputfilename" ;
print $fho "#time\t1xx\t2xx\t3xx\t4xx\t5xx\n" ;
foreach my $time ( sort keys %{$httpstatusref} ) {
        printf $fho "%s\t", $time ;
        foreach my $httpCode ( 1..5 ) {
            if ( $httpstatusref->{$time}{$httpCode} ) {
                printf  $fho "%s\t", $httpstatusref->{$time}{$httpCode} ;
            }
            else {
                printf $fho "%s\t", 0 ;
            }
        }
        print $fho "\n";
}
close $fho;

#-------------------------------------------------------------------------------
#  backup hash
#-------------------------------------------------------------------------------
store($httpstatusref, "$hashFileLocation") or die "Can't store %hash in $hashFileLocation!\n";
