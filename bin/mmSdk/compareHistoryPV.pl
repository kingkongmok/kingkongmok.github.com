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
use Statistics::Descriptive;
use File::stat;
use POSIX "strftime";

my $diffThreshold = 0.25 ;

#-------------------------------------------------------------------------------
#  don't edit below
#-------------------------------------------------------------------------------
my $lastHour = `date -d -1hour +%H`;
#
# my @logArrays = (
#                     "/home/kk/Documents/logs/http_status_code_1.log",
#                     "/home/kk/Documents/logs/http_status_code_2.log",
#                     "/home/kk/Documents/logs/http_status_code_3.log",
#                     "/home/kk/Documents/logs/http_status_code_5.log",
#                 );
my @logArrays = ("/home/logs/1_mmlogs/crontabLog/http_status_code.log", 
                "/home/logs/4_mmlogs/crontabLog/http_status_code.log",
                "/home/logs/3_mmlogs/crontabLog/http_status_code.log",
                "/home/logs/5_mmlogs/crontabLog/http_status_code.log",
                );


sub getLastHourPV {
    my $lastHour = shift ;
    my $location = shift ;
    while (1) {
        my $nowHour = strftime "%H", localtime(time) ;
        my $stat_detail = stat $location ; 
        my $mtime = $stat_detail->[9];
        my $modifyHour = strftime "%H", localtime($mtime);
        if ( $nowHour == $modifyHour ) {
            last ;
        }
        sleep 30 ;
    }
    my $sum = 0;
    my $count;
    my @lastHourPV ;
    open my $fh, $location || die $! ;
    while ( <$fh> ) {
        if ( /^$lastHour:\d{2}\s+
                \d+\s+
                (\d+)\s+
                .*
             /x ) {
             $sum+=$1;
             $count++;
             push @lastHourPV, $1 ;
        }
    }
    close $fh;

    my $stat = Statistics::Descriptive::Full->new(); 
    $stat->add_data(\@lastHourPV);
    my $standard_deviation=$stat->standard_deviation();#标准差
    my $mean = $stat->mean();#平均值
    my $RSD=$standard_deviation/$mean * 100;

    if ( $count ) {
        my $average = $sum / $count;
        return ( $average , $RSD );
    } else {
        return 0;
    }
} ## --- end sub getLastHourPV


sub getHistoryAveragePV {
    my $lastHour = shift;
    my $logHistArray = shift ;
    my @histAverage;
    my @hist_RSD;
    my ( $totalSum, $totalCount) = ( 0, 0 ) ;
    foreach my $logFile ( @{$logHistArray} ) {
        my ( $sum, $count) = ( 0, 0 ) ;
        my @lastHourPV ;
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
                     push @lastHourPV, $1 ;
                 }
            }
            my $stat = Statistics::Descriptive::Full->new(); 
            $stat->add_data(\@lastHourPV);
            my $standard_deviation=$stat->standard_deviation();#标准差
            my $mean = $stat->mean();#平均值
            my $RSD=$standard_deviation/$mean * 100;
            push @hist_RSD, $RSD;
        }
        $totalCount += $count; 
        $totalSum += $sum;
        $count ||= 1 ;
        my $average = $sum/$count; 
        push @histAverage, $average;  
    }


    $totalCount ||= 1;
    my $totalAverage = $totalSum / $totalCount;
    return ( $totalAverage , \@histAverage, \@hist_RSD );
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
my @days_to_compare = ( 7, 14, 21, 28, 35, 42 );
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
    my ( $PV_now , $RSD ) = getLastHourPV($lastHour, $log) ;
    my ( $PV_hist, $PV_hist_array_ref , $hist_RSD_ref ) = getHistoryAveragePV($lastHour, \@logHistArray);
    my $diffValue = abs($PV_now - $PV_hist)/$PV_now || die $!;

    if ( $diffValue > $diffThreshold ) {
        my $diffString = $PV_now > $PV_hist ? "+" : "-";
        my $errorOutput = sprintf "%s%s%i%%,",$server_ip[ $serverIterator ],$diffString, $diffValue * 100;
        $mailSubj.=$errorOutput;
        my $iterator = 0;
        open my $fho, ">> /tmp/pv_mail_now.txt" || $! ;
        print $fho "<pre>";
        printf $fho "今天%02d:00~%02d:00在<font color='red'><b>%s</b></font>可能发生了异常, 对比过往的<b>PV/minute 每分钟访问数</b>过大或者过小<font color='red'><b>%s%d%%</b></font>:\ntoday %02d:00~%02d:00 PV/minute: <font color='blue'><b>%.2f</b></font>\n", $h, $h+1, $server_ip[ $serverIterator ],$diffString,$diffValue * 100, $h, $h+1,$PV_now;
        foreach my $day ( @logDays ) {
            printf $fho "%s %02d:00~%02d:00 PV/minute: <font color='green'><b>%.2f</b></font>\n",$day,$h, $h+1,$PV_hist_array_ref->[$iterator];
            $iterator++;
        }
        print $fho "</pre>";
        close $fho;
    }


#-------------------------------------------------------------------------------
#  假设检验
#-------------------------------------------------------------------------------
   sub outlier_filter { return $_[1] > 0.1; } 
#-------------------------------------------------------------------------------
#  原始数据
#-------------------------------------------------------------------------------
   my $stat = Statistics::Descriptive::Full->new(); 
   $stat->add_data($hist_RSD_ref);
   $stat->set_outlier_filter( \&outlier_filter ); # 数据标准化排除一个数据 
   my $filtered_index = $stat->_outlier_candidate_index;
   my @filtered_data = $stat->get_data_without_outliers();
#-------------------------------------------------------------------------------
#  filtered_data
#-------------------------------------------------------------------------------
   $stat = Statistics::Descriptive::Full->new();
   $stat->add_data(\@filtered_data);
   my $max=$stat->max();
   my $RSD_Comparation = sprintf "%.2f", ( $RSD - $max ) / $RSD ;
    if ( $RSD_Comparation > $diffThreshold && $RSD > 5 ) {
	 my $errorOutput1 =  sprintf "%s-RSD+%.2f%%,",$server_ip[ $serverIterator ], $RSD;
	 $mailSubj.=$errorOutput1;
        my $iterator = 0;
        open my $fho, ">> /tmp/pv_mail_now.txt" || $! ;
        print $fho "<pre>";
        printf $fho "今天%02d:00~%02d:00在<font color='red'><b>%s</b></font>可能发生了异常, 对比过往的<b>Relative Standard Deviation 每分钟相对标准偏差</b>，抖动过大<font color='red'><b>+%02d%%</b></font>:\ntoday %02d:00~%02d:00 RSD: <font color='blue'><b>%.2f%%</b></font>\n", $h, $h+1, $server_ip[ $serverIterator ], $RSD_Comparation * 100, $h, $h+1,$RSD;
        foreach my $day ( @logDays ) {
            my $filed = "";
            $filed = " filtered_data" if $iterator == $filtered_index;
            printf $fho "%s %02d:00~%02d:00 RSD: <font color='green'><b>%.2f%%</b></font>%s\n",$day,$h, $h+1,$hist_RSD_ref->[$iterator], $filed;
            $iterator++;
        }
        print $fho "</pre>";
        close $fho;
    }

    $serverIterator++;
}


if ( $mailSubj ) {
    my $errorMailCommand = "/opt/mmSdk/bin/alarm_mail.sh mmSdk-pv-$mailSubj";
    `cp -f /tmp/pv_mail_now.txt /tmp/alarm_mail.txt` ;
    `$errorMailCommand` ;
    my $systemCommand=qq#/opt/mmSdk/bin/pvAnalyze_now.sh mmSdk-pv-$mailSubj#;
    `$systemCommand`;
}
