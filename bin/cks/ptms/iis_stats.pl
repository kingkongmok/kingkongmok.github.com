#!/usr/bin/perl -w
##===============================================================================
##
##         FILE: iis_stats
##
##        USAGE: ./iis_stats
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
use Tie::File;
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
my $thisDay = strftime"%y%m%d", localtime $now;


getopts('s:d:l:m:c:t:k:rpah');
our($opt_s, $opt_d, $opt_l, $opt_m, $opt_c, $opt_t, $opt_k, $opt_r, $opt_p, $opt_a, $opt_h);
my $LogPath ;
if ( $opt_s or $opt_d ) {
    $opt_s = $opt_s ? $opt_s : 212 ; 
    my $logDate = strftime"%y%m%d", localtime ( $now - ($opt_d ? $opt_d : 0)*24*60*60 ) ;
    $LogPath = "/home/logs/172.16.45.$opt_s/LogFiles/W3SVC1/u_ex$logDate.log";
    $now = $now - ($opt_d?$opt_d:0)*24*60*60 ;
} else {
    $opt_s = $opt_s ? $opt_s : 212 ; 
    $LogPath = $opt_l ? $opt_l : 
    "/home/logs/172.16.45.212/LogFiles/W3SVC1/u_ex$thisDay.log";
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
my $hist_PV_stats_file = "/home/kk/.pv_stats/$ServerIP.log";


sub help {
    print <<HELPTEXT;

    目的： 统计iis accesslog

    显示：
            第1列为地址
            第2列为时间段内的pv统计，ip对应pv百分比；
            第3列为时间段内的平均响应时间，ip对应响应时间百分比。

            223.255.137.66  |       2100(pv)    39.89%  |      11933ms  83.81%
            210.13.114.43   |       1097(pv)    20.84%  |        577ms   2.12%
            119.29.235.125  |       1017(pv)    19.32%  |       1026ms   3.49%

    参数：
            -s          选择host点，默认212代表172.16.45.212
            -d          选择多少天前的日志，默认 -d 0 ，表示今天
            -l          log的路径，例如 /home/logs/172.16.45.212/LogFiles/W3SVC1/u_ex161111.log
                        默认 -l /home/logs/172.16.45.212/LogFiles/W3SVC1/u_ex$thisDay.log
            -m          统计距今x分钟的数据，默认 -n 3
            -c          设置pv报警阈值，默认 -c 1
            -t          设置平均response time的ms阈值，默认 -t 1
            -k          列时间段段数默认20
            -p          html格式输出
            -a          记录总数以便历史对比
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

my @remote_monitor_ip = (
    '172.16.40.74',
    '172.26.45.12',
);

my %ip_hash = ( 
    '223.255.137.66' => '永安',
    '210.13.114.43' => '永安', 
    '182.254.201.72' => '讯隆船务', 
    '112.65.178.188' => '威富通', 
    '182.254.200.172' => '讯隆船务', 
    '223.223.218.48' => '中港客运联营', 
    '61.145.229.171' => '九洲港', 
    '61.145.229.172' => '九洲港', 
    '61.145.229.173' => '九洲港', 
    '61.145.229.174' => '九洲港', 
    '45.115.36.29' => '中山港', 
    '119.29.111.146' => '迅隆船务', 
    '119.29.32.186' => '迅隆船务', 
    '203.195.128.193' => '迅隆船务', 
    '119.29.235.125' => '迅隆船务', 
    '123.207.245.128' => '迅隆船务', 
    '202.82.66.140' => 'CKSIT', 
    '210.13.114.43' => '携程', 
    '47.90.95.42' => '深圳盼游', 
    '110.12.19.12' => 'TOURBAKSA', 
    '110.12.19.36' => 'TOURBAKSA', 
    '110.12.19.18' => 'TOURBAKSA', 
    '112.175.92.181' => 'TOURBAKSA', 
    '112.175.92.182' => 'TOURBAKSA', 
    '112.175.92.183' => 'TOURBAKSA', 
    '112.175.92.185' => 'TOURBAKSA', 
    '112.175.92.186' => 'TOURBAKSA', 
    '112.175.92.188' => 'TOURBAKSA', 
    '10.100.101.20' => 'CKS华为防火墙', 
    '192.168.198.*' => '蛇口港', 
    '172.16.45.243' => 'PTMS_API', 
) ;

my $s_request_time = Statistics::Descriptive::Full->new(); 
my %remote_addr_hash; 
my %remote_addr_time; 
my $reqcount = 0;
my %pathHash;
my %path_time;
my $pathCount = 0;
my $reqmscount = 0;
my $ignored = 0;
my $lasttime = 0 ;
my $firstTime = $now;
my %time_hash;


while(<$fh>){
    if (
        my (
            $time_local,
            $local_addr,
            $path,
            $port,
            $remote_addr,
            $user_agent,
            $referer,
            $status,
            $request_time,
        ) = 
        m/
        ^(\S+\s+\S+)\s+  #time_local
        (\S+)\s+         #local_addr
        (?:GET|POST)\s+(\S+)\s+\S+\s+   #request
        (\d+)\s+\S+\s+   #port
        (\S+)\s+         #remote_addr
        (\S+)\s+         #ua
        (\S+)\s+         #referer
        (\d+)\s+\d+\s+\d+\s+    #status
        (\d+)\s*         #time
        $/x
    ) {
        my $l = $_;
        my $time = str2time($time_local) || next ;
        # my $reqms = int($request_time) || next ;
        $request_time =~ /\d+/ || next; 
        my $reqms = $request_time;
        next if grep { /^$remote_addr$/ } @remote_monitor_ip;
        my @split_ks = ( 0..$keys ) ;
        foreach my $ks ( @split_ks ) {
            if ( 
                ($now-($split_time*$ks)) > $time && 
                ($now-($split_time*($ks+1))) < $time 
            ) {
                $time_hash{$ks}{statuscount}->{$status < 400 ? 'success' : 'failure'}++;
                $time_hash{$ks}{resptime} += $reqms;
            }
        }
        if ( ($now - $MAXAGE < $time) && ($now > $time )) {
            $lasttime = $time > $lasttime ? $time : $lasttime ;
            $firstTime = $firstTime > $time ? $time : $firstTime ;
            #my ($method, $path) = split(' ', $request, 3);
            #$path =~ s/\?.*//;
            $pathCount += 1;
            $pathHash{$path}++;
            $path_time{$path} += $reqms;
            $s_request_time->add_data($reqms);
            $reqcount += 1;
            $remote_addr_hash{"$remote_addr"} += 1;
            $remote_addr_time{"$remote_addr"} += $reqms;
            $reqmscount += $reqms ;
        } 
    } 
}


sub getHistPVStats{
    my $reqcount = shift;
    my @days;
    my $result;
    my $logDate = strftime"%F", localtime ( $now ) ; 
    my $weekago_1 = strftime"%F", localtime ( $now - 7*24*60*60 ) ; 
    my $weekago_2 = strftime"%F", localtime ( $now - 14*24*60*60 ) ; 
    my $weekago_3 = strftime"%F", localtime ( $now - 21*24*60*60 ) ; 
    my $weekago_4 = strftime"%F", localtime ( $now - 28*24*60*60 ) ; 
    @days = ( $logDate, $weekago_1, $weekago_2, $weekago_3, $weekago_4);
    tie my @linearray, 'Tie::File', $hist_PV_stats_file or die $!;
    if ( $opt_a ) {
        push @linearray, "$logDate $reqcount";
    }
    foreach my $oldday ( @days ) {
        $result->{"$oldday"} //= 0;
        foreach my $thisline ( @linearray ) {
            my ($day,$count) = split /\s+/, $thisline ;
            if ( $oldday =~ /^$day$/ ) {
                if ( $result->{$oldday} < $count ) {
                    $result->{$oldday}=$count;
                }
            }
        }
        $result->{"$oldday"} //= "-";
    }
    untie @linearray;
    return $result, $logDate;
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
        #
        if ( $opt_r ) {
            my ($history_PV_stats, $logDate) = getHistPVStats($reqcount);
        }
        print "\n";
        #
        foreach my $ip 
        ( 
            sort {$remote_addr_hash{$b}<=>$remote_addr_hash{$a}}
            keys %remote_addr_hash 
        ) {
            # my $physical_ip = $ip_hash{$ip} ? $ip_hash{$ip} : "未知" ;
            my $physical_ip; 
            foreach my $ip_pattern ( keys %ip_hash ) {
                if ( grep {/^$ip_pattern/} $ip ) {
                    $physical_ip = $ip_hash{$ip_pattern};
                } 
            }
            $physical_ip //= "未知";
            printf "%12s\t%8s\t|\t%8s(pv)\t%5.2f%%\t|\t%8dms\t%5.2f%%\n", 
            $ip, 
            $physical_ip,
            $remote_addr_hash{$ip}, 
            100*$remote_addr_hash{$ip}/$reqcount,
            $remote_addr_time{$ip}/$remote_addr_hash{$ip},
            100*$remote_addr_time{$ip}/$reqmscount;
        }
        print "\n";
        #
        foreach my $path ( reverse sort {$pathHash{$a}<=>$pathHash{$b}} keys %pathHash ) {
            printf "%24s\t|\t%8s(pv)\t%5.2f%%\t|\t%8dms\t%5.2f%%\n", 
            $path,
            $pathHash{$path},
            100*$pathHash{$path}/$pathCount,
            $path_time{$path}/$pathHash{$path},  
            100*$path_time{$path}/$reqmscount,
        }
        print "\n";
        #
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
        #
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
        #
        if ( $opt_r ) {
            my ($history_PV_stats, $logDate) = getHistPVStats($reqcount);
            my $tablecontent=
            [$q->th([
                        '时间',
                        'PV',
                        '当天比较', 
                    ])];
            my @day_array = reverse sort keys %{$history_PV_stats};
            print $q->h3("PV每日和上几周对比");
            foreach my $day ( 
                @day_array
            ) {
                my $operater = $history_PV_stats->{$logDate}>$history_PV_stats->{$day} ? "" : "+";
                my $perc = sprintf "%.2f%%",(100*$history_PV_stats->{$day}/$history_PV_stats->{$logDate}-100);
                # my $result = $history_PV_stats->{$logDate}=$history_PV_stats->{$day}?"-":$operater.$perc;
                push @$tablecontent,  $q->td([
                        $day,
                        $history_PV_stats->{$day},  
                        $operater.$perc,
                    ]) ;
            } 
            print $q->table( { border => 1,},
                $q->Tr( $tablecontent),
            );
            print "\n";
        }
        #
        my $tablecontent=
        [$q->th([
                    'ip',
                    '地理位置',
                    '该IP的访问量(PV)', 
                    'PV百分比', 
                    '该IP平均处理时间(ms)', 
                    '处理时间百分比',
                ])];
        my @ip_array =
        sort {$remote_addr_hash{$b}<=>$remote_addr_hash{$a}} keys %remote_addr_hash;
        if ( $opt_r ) {
            print $q->h3("访问量最多的前100个IP的统计情况");
            if ( keys %remote_addr_hash > 100 ) {
                @ip_array = 
                +(sort 
                    {$remote_addr_hash{$b}<=>$remote_addr_hash{$a}} 
                    keys %remote_addr_hash)[0..99];
            } 
        }
        foreach my $ip ( 
            @ip_array
        ) {
            # my $physical_ip = $ip_hash{$ip} ? $ip_hash{$ip} : "未知" ;
            my $physical_ip; 
            foreach my $ip_pattern ( keys %ip_hash ) {
                if ( grep {/^$ip_pattern/} $ip ) {
                    $physical_ip = $ip_hash{$ip_pattern};
                } 
            }
            $physical_ip //= "未知";
            push @$tablecontent,  $q->td([
                    $ip,
                    $physical_ip,  
                    $remote_addr_hash{$ip}, 
                    sprintf ("%.2f%%", 100*$remote_addr_hash{$ip}/$reqcount), 
                    sprintf ("%.2fms", $remote_addr_time{$ip}/$remote_addr_hash{$ip}),  
                    sprintf ("%.2f%%", 100*$remote_addr_time{$ip}/$reqmscount)
                ]) ;
        } 
        # }
        print $q->table( { border => 1,},
            $q->Tr( $tablecontent),
        );
        #
        $tablecontent=[$q->th([
                    'URI', 
                    '访问次数', 
                    '访问百分比', 
                    '该URI平均处理时间(ms)', 
                    '处理时间百分比',
                ])];
        my @path_array = reverse sort {$pathHash{$a}<=>$pathHash{$b}} keys %pathHash ;
        if ( $opt_r ) {
            print $q->h3("访问量最多的前100个URI的统计情况");
            if ( keys %pathHash > 100 ) {
                @path_array = +(reverse sort {$pathHash{$a}<=>$pathHash{$b}} keys %pathHash)[0..99];
            } 
        }
        foreach my $path ( @path_array  ) {
            push @$tablecontent,  $q->td([
                    $path,
                    $pathHash{$path},
                    sprintf ("%.2f%%", $pathHash{$path}*100/$pathCount),
                    sprintf ("%.2fms", $path_time{$path}/$pathHash{$path}),  
                    sprintf ("%.2f%%", 100*$path_time{$path}/$reqmscount),
                ]) ;
        } 
        #print $q->table( { border => 1, -width => '100%'},
        print $q->table( { border => 1},
            $q->Tr( $tablecontent),
        );
        print "\n";
        #
        print $q->h3("每时段PV情况");
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
