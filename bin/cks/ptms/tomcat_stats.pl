#!/usr/bin/perl -w

use strict;
use File::Basename;
use POSIX;
use Statistics::Descriptive;
use Date::Parse;
use File::Temp ();
use Data::Dumper;
use Getopt::Std;
use feature 'say';

my $now = time();
my $thisDay = strftime"%F", localtime $now;


getopts('s:d:l:m:c:t:k:ph');
our($opt_s, $opt_d, $opt_l, $opt_m, $opt_c, $opt_t, $opt_k, $opt_p, $opt_h);
my $LogPath ;
if ( $opt_s or $opt_d ) {
    my $logDate = strftime"%F", localtime ( $now - ($opt_d?$opt_d:0)*24*60*60 ) ; 
    $LogPath = "/home/logs/172.16.45.$opt_s/localhost_access_log.$logDate.txt";
} else {
    $LogPath = $opt_l ? $opt_l : "/home/logs/172.16.45.206/localhost_access_log.$thisDay.txt";
}
our $MAXAGE = $opt_m ? $opt_m*60 : 3*60;
my $Trigger_reqCount = $opt_c ? $opt_c : 900;
my $Trigger_reqTime = $opt_t ? $opt_t : 5000;
my $keys = $opt_k ? $opt_k : 10 ; 


sub help {
    print <<HELPTEXT;

    目的： 统计tomcat accesslog

    显示：
            第1列为地址
            第2列为时间段内的pv统计，ip对应pv百分比；
            第3列为时间段内的平均响应时间，ip对应响应时间百分比。

            223.255.137.66  |       2100(pv)    39.89%  |      11933ms  83.81%
            210.13.114.43   |       1097(pv)    20.84%  |        577ms   2.12%
            119.29.235.125  |       1017(pv)    19.32%  |       1026ms   3.49%

    参数：
            -s          选择host点，例如206代表172.16.45.206
            -d          选择多少天前的日志，默认 -d 0 ，表示今天
            -l          log的路径，例如 /home/logs/172.16.45.206/localhost_access_log.2016-09-14.txt 
                        默认 -l /home/logs/$thisDay/localhost_access_log.$thisDay.txt
            -m          统计距今x分钟的数据，默认 -n 3
            -c          设置pv报警阈值，默认 -c 900
            -t          设置平均response time的ms阈值，默认 -t 5000
            -k          列时间段段数
            -p          html格式输出
            -h          print this help

    example:
            $0 -m 5 -t 1 -c 1 -k10
HELPTEXT
    exit;
}

if($opt_h ) {
    help;
    exit;
}

open my $fh , $LogPath || die $! ; 

my $parseerrors = 0;

my %ip_hash = ( 
    '223.255.137.66' => '永安',
    '210.13.114.43' => '永安', 
) ;

my $s_request_time = Statistics::Descriptive::Full->new(); 
my %remote_addr_hash; 
my %remote_addr_time; 
my $oldcount = 0;
my $reqcount = 0;
my $reqmscount = 0;
my $ignored = 0;
my $lasttime = 0 ;
my $firstTime = $now;
my %time_hash;



while(<$fh>){
    if (
        my (
            $remote_addr,
            $hostname,
            $remote_user,
            $time_local,
            $request,
            $status,
            $body_bytes_sent,
            $request_time,
        ) = 
        m/  (\S+)\s+
        (\S+)\s+
        (\S+)\s+
        \[(.*?)\]\s+
        "(.*?)"\s+
        (\S+)\s+
        (\S+)\s+
        (\S+)\s*/x
    ) {
        my $l = $_;
        my $time = str2time($time_local);
        my $diff = time() - $time;
        my @split_ks = ( 0..$keys ) ;
        foreach my $ks ( @split_ks ) {
            if ( ($now-($MAXAGE*$ks)) > $time && ($now-($MAXAGE*($ks+1))) < $time ) {
                $time_hash{$ks}{statuscount}->{$status < 400 ? 'success' : 'failure'}++;
                $time_hash{$ks}{resptime} += int($request_time);
            }
        }
        if ($now - $time < $MAXAGE) {
            $lasttime = $time > $lasttime ? $time : $lasttime ;
            $firstTime = $firstTime > $time ? $time : $firstTime ;
            my ($method, $path) = split(' ', $request, 3);
            my $reqms = int($request_time);
            $s_request_time->add_data($reqms);
            $reqcount += 1;
            $remote_addr_hash{"$remote_addr"} += 1;
            $remote_addr_time{"$remote_addr"} += $reqms;
            $reqmscount += $reqms ;

        } else {
            $oldcount += 1;
        }
    } else {
        $parseerrors += 1;
    }
}

sub printScreen {
    if ( $s_request_time > $Trigger_reqTime && $reqcount > $Trigger_reqCount ) {
        my $oldtime = $now - $MAXAGE ; 
        printf 
        "some errors may be occured.\nAVG RespTime: %.2f, warning trigger: %s\nPV: %i, warning trigger: %s\n\n",
        $MAXAGE/60,
        $s_request_time->mean(),
        $Trigger_reqTime,
        $reqcount,
        $Trigger_reqCount;
        printf "<%s> ~ <%s> on $LogPath \n",
        (strftime "%F_%T", localtime $firstTime),
        (strftime "%F_%T", localtime $lasttime); 
        foreach my $ip ( sort {$remote_addr_hash{$b}<=>$remote_addr_hash{$a}} keys %remote_addr_hash ) {
            my $physical_ip = $ip_hash{$ip} ? $ip_hash{$ip} : "未知" ;
            printf "%12s\t%8s\t|\t%8s(pv)\t%5.2f%%\t|\t%8dms\t%5.2f%%\n", 
            $ip, 
            $physical_ip,
            $remote_addr_hash{$ip}, 
            100*$remote_addr_hash{$ip}/$reqcount,
            $remote_addr_time{$ip}/$remote_addr_hash{$ip},
            100*$remote_addr_time{$ip}/$reqmscount;
        }
    }
    print "\n";
    printf "%16s | %8s+%-8s | %16s\n" , "time", "success", "fail(pv)", "RespTime(ms)"; 
    foreach my $ks ( reverse sort {$a<=>$b} keys %time_hash ) {
        my $success = $time_hash{$ks}{statuscount}{'success'} ? $time_hash{$ks}{statuscount}{'success'} : 0;
        my $failure = $time_hash{$ks}{statuscount}{'failure'} ? $time_hash{$ks}{statuscount}{'failure'} : 0;
        my $totalcount = ( $success  + $failure ) ? ( $success  + $failure ) : 1 ;
        printf "%s~%s | %8d+%-8d | %8.2f\n" ,
        (strftime "%T",localtime ($now - ($ks+1)*$MAXAGE)),
        (strftime "%T",localtime ($now - $ks*$MAXAGE)),
        $success,
        $failure,
        $time_hash{$ks}{resptime}/$totalcount ;
    }
}

sub printHtml {
    say "html";
}

if ( $opt_p ) {
    printHtml
} else {
    printScreen
}
