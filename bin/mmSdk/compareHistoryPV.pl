#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: compareHistoryPV.pl
#
#        USAGE: ./compareHistoryPV.pl  
#
#  DESCRIPTION: check every host's PV recursively, compare with 
#                history average || alarm
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

my $diffThreshold = 0.2 ;


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
        my $average = $sum / $count;
        return $average;
    } else {
        return 0;
    }
} ## --- end sub getLastHourPV


sub getHistoryAveragePV {
    my $logHistArray = shift ;
    my @histAverage;
    my ( $totalSum, $totalCount) = ( 0, 0 ) ;
    foreach my $logFile ( @{$logHistArray} ) {
        my ( $sum, $count) = ( 0, 0 ) ;
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
        $totalCount += $count; 
        $totalSum += $sum;
        $count ||= 1 ;
        my $average = $sum/$count; 
        push @histAverage, $average;  
    }
        $totalCount ||= 1;
        my $totalAverage = $totalSum / $totalCount;
        return ( $totalAverage , \@histAverage );
} ## --- end sub getHistoryAveragePV


my @serverArray = ( 1, 2, 3, 5 );
my @server_ip = (
                 "192.168.42.1",
                 "192.168.42.2",
                 "192.168.42.3",
                 "192.168.42.5",
            );
my $serverIterator = 0;
my $mailSubj ;
my $mailContent ;
my @days_to_compare = ( 7, 14, 21, 28, 35 );
my @logDays = map { my ($s, $min, $h, $d, $m, $y) = localtime(time()-$_*24*60*60); 
                sprintf "%02d-%02d",$m+1,$d}
                @days_to_compare;
my ($s, $min, $h, $d, $m, $y) = localtime(time()-60*60);
foreach my $log ( @logArrays ) {
    my @logHistArray;
#-------------------------------------------------------------------------------
#  check last 2 weeks' average
#-------------------------------------------------------------------------------
    foreach ( @days_to_compare ) {
        push @logHistArray,"$log.$_.gz";
    }
    my $PV_now = getLastHourPV($log) ;
    my ( $PV_hist, $PV_hist_array_ref) = getHistoryAveragePV(\@logHistArray);
    my $diffValue = abs($PV_now - $PV_hist)/$PV_now || die $!;
    if ( $diffValue > $diffThreshold ) {
        my $diffString = $PV_now > $PV_hist ? "+" : "-";
        my $errorOutput = sprintf "%s%s%i%%,",$server_ip[ $serverIterator ],$diffString, $diffValue * 100;
        $mailSubj.=$errorOutput;
        my $iterator = 0;
        open my $fho, ">> /tmp/pv_mail_now.txt" || $! ;
        print $fho "<pre>";
        printf $fho "some errors may occurd today in %02d:00~%02d:00 at <font color='red'><b>%s</b></font>, compare with history\nPV/min last hour's average flow <font color='red'><b>%s%d%%</b></font>:\n\ntoday: <font color='blue'><b>%.2f</b></font>\n", $h, $h+1, $server_ip[ $serverIterator ],$diffString,$diffValue * 100,$PV_now;
        foreach my $day ( @logDays ) {
            printf $fho "%s: <font color='green'><b>%.2f</b></font>\n",$day,$PV_hist_array_ref->[$iterator];
            $iterator++;
        }
        print $fho "</pre>";
        close $fho;
        
    }
    $serverIterator++;
}


if ( $mailSubj ) {
    my $systemCommand=qq#/opt/mmSdk/bin/pvAnalyze_now.sh mmSdk-host-$mailSubj#;
    `$systemCommand`;
}
