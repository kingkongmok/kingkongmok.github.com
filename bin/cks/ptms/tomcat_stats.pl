#!/usr/bin/perl -w
##===============================================================================
##
##         FILE: tomcat_stats
##
##        USAGE: ./tomcat_stats
##
##  DESCRIPTION: 
##
##      OPTIONS: ---
## REQUIREMENTS: ---
##         BUGS: ---
##        NOTES: ---
##       AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
## ORGANIZATION: datlet.com
##      VERSION: 1.0
##      CREATED: 09/23/2016 03:25:46 PM
##     REVISION: ---
##===============================================================================

use strict;
use File::Basename;
use POSIX;
use Statistics::Descriptive;
use Date::Parse;
use File::Temp ();
use Data::Dumper;
use Getopt::Std;
use CGI;
use feature 'say';

my $now = time();
my $thisDay = strftime"%F", localtime $now;


getopts('s:d:l:m:c:t:k:rph');
our($opt_s, $opt_d, $opt_l, $opt_m, $opt_c, $opt_t, $opt_k, $opt_r, $opt_p, $opt_h);
my $LogPath ;
if ( $opt_s or $opt_d ) {
    $opt_s = $opt_s ? $opt_s : 206 ; 
    my $logDate = strftime"%F", localtime ( $now - ($opt_d ? $opt_d : 0)*24*60*60 ) ; 
    $LogPath = "/home/logs/172.16.45.$opt_s/localhost_access_log.$logDate.txt";
    $now = $now - ($opt_d?$opt_d:0)*24*60*60 ;
} else {
    $opt_s = $opt_s ? $opt_s : 206 ; 
    $LogPath = $opt_l ? $opt_l : 
    "/home/logs/172.16.45.206/localhost_access_log.$thisDay.txt";
}
my $ServerIP="172.16.45." . $opt_s ;
our $MAXAGE = $opt_m ? $opt_m*60 : 3*60;
my $split_time = $opt_m ? $opt_m*60 : 3*60;
my $Trigger_reqCount = $opt_c ? $opt_c : 1;
my $Trigger_reqTime = $opt_t ? $opt_t : 1;
my $keys = $opt_k ? $opt_k : 20 ; 
if ( $opt_r ) {
    my $s_day = strftime"%F", localtime $now; 
    my $s_day_time = $s_day . " 23:59:59";
    $now = str2time $s_day_time ;
    $MAXAGE = 24*60*60;
    $keys = $opt_k ? $opt_k : 480; 
}


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
            -s          选择host点，默认206代表172.16.45.206
            -d          选择多少天前的日志，默认 -d 0 ，表示今天
            -l          log的路径，例如 /home/logs/172.16.45.206/localhost_access_log.2016-09-14.txt 
                        默认 -l /home/logs/$thisDay/localhost_access_log.$thisDay.txt
            -m          统计距今x分钟的数据，默认 -n 3
            -c          设置pv报警阈值，默认 -c 1
            -t          设置平均response time的ms阈值，默认 -t 1
            -k          列时间段段数默认20
            -p          html格式输出
            -h          print this help

    example:
            $0 -t 3000 -c 900 -k50 -s 205
            $0 -d7
HELPTEXT
    exit;
}

if($opt_h ) {
    help;
    exit;
}

open my $fh , $LogPath || die $! ; 


my %ip_hash = ( 
    '223.255.137.66' => '永安',
    '210.13.114.43' => '永安', 
) ;

my $s_request_time = Statistics::Descriptive::Full->new(); 
my %remote_addr_hash; 
my %remote_addr_time; 
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
        my @split_ks = ( 0..$keys ) ;
        foreach my $ks ( @split_ks ) {
            if ( 
                ($now-($split_time*$ks)) > $time && 
                ($now-($split_time*($ks+1))) < $time 
            ) {
                $time_hash{$ks}{statuscount}->{$status < 400 ? 'success' : 'failure'}++;
                $time_hash{$ks}{resptime} += int($request_time);
            }
        }
        if ( ($now - $MAXAGE < $time) && ($now > $time )) {
            $lasttime = $time > $lasttime ? $time : $lasttime ;
            $firstTime = $firstTime > $time ? $time : $firstTime ;
            my ($method, $path) = split(' ', $request, 3);
            my $reqms = int($request_time);
            $s_request_time->add_data($reqms);
            $reqcount += 1;
            $remote_addr_hash{"$remote_addr"} += 1;
            $remote_addr_time{"$remote_addr"} += $reqms;
            $reqmscount += $reqms ;
        } 
    } 
}


sub printScreen {
    if ( 
        $s_request_time->mean() > $Trigger_reqTime && 
        $reqcount > $Trigger_reqCount 
    ) {
        if ( $opt_c or $opt_t ) {
            printf 
            "some errors may be occured.
            AVG RespTime: %.2f, warning trigger: %s
            PV: %i, warning trigger: %s\n\n",
            $s_request_time->mean(),
            $Trigger_reqTime,
            $reqcount,
            $Trigger_reqCount;
        }
        printf "<%s> ~ <%s> on $LogPath \n",
        (strftime "%F_%T", localtime $firstTime),
        (strftime "%F_%T", localtime $lasttime); 
        foreach my $ip 
        ( 
            sort {$remote_addr_hash{$b}<=>$remote_addr_hash{$a}}
            keys %remote_addr_hash 
        ) {
            my $physical_ip = $ip_hash{$ip} ? $ip_hash{$ip} : "未知" ;
            printf "%12s\t%8s\t|\t%8s(pv)\t%5.2f%%\t|\t%8dms\t%5.2f%%\n", 
            $ip, 
            $physical_ip,
            $remote_addr_hash{$ip}, 
            100*$remote_addr_hash{$ip}/$reqcount,
            $remote_addr_time{$ip}/$remote_addr_hash{$ip},
            100*$remote_addr_time{$ip}/$reqmscount;
        }
        print "\n";
        printf "%17s | %8s+%-8s | %16s\n" 
        , "time", "success", "fail(pv)", "RespTime(ms)"; 
        foreach my $ks ( reverse sort {$a<=>$b} keys %time_hash ) {
            my $success = $time_hash{$ks}{statuscount}{'success'} ? 
            $time_hash{$ks}{statuscount}{'success'} : 0;
            my $failure = $time_hash{$ks}{statuscount}{'failure'} ? 
            $time_hash{$ks}{statuscount}{'failure'} : 0;
            my $totalcount = ( $success  + $failure ) ? 
            ( $success  + $failure ) : 1 ;
            printf "%s~%s | %8d+%-8d | %8.2f\n" ,
            (strftime "%T",localtime ($now - ($ks+1)*$split_time)),
            (strftime "%T",localtime ($now - $ks*$split_time)),
            $success,
            $failure,
            $time_hash{$ks}{resptime}/$totalcount ;
        }
        print "\n";
    }
}


sub printHtml {
    if ( 
        ($s_request_time->mean() > $Trigger_reqTime) && 
        ($reqcount > $Trigger_reqCount) 
    ) {
        my $q= new CGI;
        if ( $opt_r ) {
            print $q->start_html('Problems'),
            $q->h2("$ServerIP 日流量统计报表 ");
        }
        else {
            print $q->start_html('Problems'),
            $q->h2("$ServerIP 可能出现流量异常 ");
            if ( $opt_c or $opt_t ) {
                printf 
                "some errors may be occured.<br>AVG RespTime: %.2f, warning trigger: %s<br>PV: %i, warning trigger: %s<br>",
                # $MAXAGE/60,
                $s_request_time->mean(),
                $Trigger_reqTime,
                $reqcount,
                $Trigger_reqCount;
            }
        }
        my $ERRORMSG = sprintf ("%s ~ %s on $ServerIP", 
            (strftime "%F_%T", localtime $firstTime), (strftime "%F_%T", localtime $lasttime)
        ); 
        print $q->h3($ERRORMSG);
        my $tablecontent=
        [$q->th(['ip', '地理位置', '该IP的访问量(PV)', 
                    'PV百分比', '该IP平均处理时间(ms)', '处理时间百分比'])];
        foreach my $ip ( 
            sort {$remote_addr_hash{$b}<=>$remote_addr_hash{$a}} keys %remote_addr_hash 
        ) {
            my $physical_ip = $ip_hash{$ip} ? $ip_hash{$ip} : "未知" ;
            push @$tablecontent,  $q->td([
                    $ip,
                    $physical_ip,  
                    $remote_addr_hash{$ip}, 
                    sprintf ("%.2f%%", 100*$remote_addr_hash{$ip}/$reqcount), 
                    sprintf ("%.2fms", $remote_addr_time{$ip}/$remote_addr_hash{$ip}),  
                    sprintf ("%.2f%%", 100*$remote_addr_time{$ip}/$reqmscount)
                ]) ;
        } 
        print $q->table( { border => 1,},
            $q->Tr( $tablecontent),
        );
        $tablecontent=[$q->th(['时间段', 'PV(成功数+失败数)', '平均响应时间(ms)'])];
        foreach my $ks ( reverse sort {$a<=>$b} keys %time_hash ) {
            my $success = $time_hash{$ks}{statuscount}{'success'} ? 
            $time_hash{$ks}{statuscount}{'success'} : 0;
            my $failure = $time_hash{$ks}{statuscount}{'failure'} ? 
            $time_hash{$ks}{statuscount}{'failure'} : 0;
            my $totalcount = ( $success  + $failure ) ? ( $success  + $failure ) : 1 ;
            push @$tablecontent,  $q->td([
                    (strftime "%H:%M",localtime ($now - ($ks+1)*$split_time)) 
                    . "~" .  
                    (strftime "%H:%M",localtime ($now - $ks*$split_time)),
                    $success . "+" .  $failure,
                    sprintf ("%.2f",$time_hash{$ks}{resptime}/$totalcount)
                ]) ;
        } 
        #print $q->table( { border => 1, -width => '100%'},
        print $q->table( { border => 1},
            $q->Tr( $tablecontent),
        );
    }
}


if ( $opt_p ) {
    printHtml
} else {
    printScreen
}
