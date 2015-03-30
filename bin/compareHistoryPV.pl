#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: compareHistoryPV.pl
#
#        USAGE: ./compareHistoryPV.pl  
#
#  DESCRIPTION: check every host's PV recursively, compare with 
#                history averarge || alarm
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: KK Mok (), kingkongmok@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 03/27/2015 10:31:46 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

my $diffThreshold = 0.1 ;


#-------------------------------------------------------------------------------
#  don't edit below
#-------------------------------------------------------------------------------
my $lastHour = `date -d -1hour +%H`;
#
#my @logArrays = ("/tmp/test/1/http_status_code.log", 
#                "/tmp/test/4/http_status_code.log",
#                "/tmp/test/3/http_status_code.log",
#                "/tmp/test/5/http_status_code.log",
#                );
my @logArrays = ("/home/logs/1_mmlogs/crontabLog/http_status_code.log", 
                "/home/logs/4_mmlogs/crontabLog/http_status_code.log",
                "/home/logs/3_mmlogs/crontabLog/http_status_code.log",
                "/home/logs/5_mmlogs/crontabLog/http_status_code.log",
                );


sub getLastHourPV {
    my $location = shift ;
    my $sum = 0;
    my $count;
    open my $fh, $location || die $! ;
    while ( <$fh> ) {
        if ( /^$lastHour:\d{2}\s+
                \d+\s+
                (\d+)\s+
                .*
             /x ) {
             $sum+=$1;
             $count++;
        }
    }
    close $fh;
    if ( $count ) {
        return $sum / $count;
    } else {
        return 0;
    }
} ## --- end sub getLastHourPV


sub getHistoryAveragePV {
    my $logHistArray = shift ;
    my ( $sum, $count) ;
    foreach my $logFile ( @{$logHistArray} ) {
        if ( -s $logFile ) {
            open my $fh, "zcat $logFile |" || die $!; 
            while ( <$fh> ) {
                if ( /^$lastHour:\d{2}\s+
                        \d+\s+
                        (\d+)\s+
                        .*
                     /x ) {
                     $sum+=$1;
                     $count++;
                 }
            }
        }
    }
    if ( $count ) {
        return $sum / $count;
    } else {
        return 0;
    }
} ## --- end sub getHistoryAveragePV


my @serverArray = ( 1, 2, 3, 5 );
my $serverIterator = 0;
my $mailSubj ;
foreach my $log ( @logArrays ) {
    my @logHistArray;
#-------------------------------------------------------------------------------
#  check last 2 weeks' average
#-------------------------------------------------------------------------------
    for ( 7, 14, 21 ) {
        push @logHistArray,"$log.$_.gz";
    }
    my $PV_now = getLastHourPV($log) ;
    my $PV_hist = getHistoryAveragePV(\@logHistArray);
    my $diffValue = abs($PV_now - $PV_hist)/$PV_now || die $!;
    if ( $diffValue > $diffThreshold ) {
        my $errorOutput = sprintf "host%s:%02i\%,",$serverArray[$serverIterator],$diffValue * 100;
        $mailSubj.=$errorOutput;
    }
    $serverIterator++;
}


if ( $mailSubj ) {
    my $systemCommand=qq#/home/moqingqiang/bin/pvAnalyze_now.sh mmSdk-host-$mailSubj#;
    `$systemCommand`;
}
