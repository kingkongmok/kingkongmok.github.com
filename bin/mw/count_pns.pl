#!/usr/bin/env perl 

#===============================================================================
# 请使用 ./count_pns.pl --help 获取帮助
#===============================================================================

use strict;
use warnings;
use Date::Parse;
use List::Util qw(sum);
use Getopt::Long;

# setup my defaults
my $logname;
my $keyword;
my $limit1;
my $limit2;
my $delayminute;
my $minimumCount;

GetOptions(
    'logname=s'    => \$logname,
    'keyword=s'     => \$keyword,
    'a=s'     => \$limit1,
    'b=s'     => \$limit2,
    'minute=s'     => \$delayminute,
    'count=s'     => \$minimumCount,
    'help|h!'     => \&help,
) or die "Incorrect usage!\n";

if ( -e $logname ) {

    open my $fh, "tail -c 50m $logname | tac |" || die $!; 
    my $now = time;
    my $count = 0;
    my $word1="allUseTime";
    my $word2="useTime";
    my $alarmMsg;
    my $sumA;
    my $sumB;

    while ( <$fh> ) {
        if ( /^\[(.*?)\]/ ) {
            my $time = str2time $1;
            last if $now - $time  > $delayminute*60;
        }
        if (/$keyword.*$word1=(\d+).$word2=(\d+)/){
            $count++;
            $sumA += $1;
            $sumB += $2;
        }
    }

    if ( $count ) {
        my $averageA = $sumA / $count ; 
        my $averageB = $sumB / $count ; 
        if ( $averageA > $limit1 || $averageB > $limit2 ) {
            $alarmMsg .= sprintf
            "$logname的50MB日志里,最近$delayminute分钟($word1,$word2)" .
            "两个关键字平均值为(%d,%d)ms,大于阀值($limit1,$limit2)ms\n"
            , $averageA, $averageB ;
        }

    }
    if ( $minimumCount > $count ) {
        $alarmMsg .=
        "$logname最近50MB日志里,最近$delayminute分钟" .
        "只出现$count条带'$keyword'的记录,少于阀值$minimumCount\n";
    }
    print $alarmMsg if $alarmMsg;

}
else {
    exit $!
}

sub help {
    print <<HELPTEXT;

    目的：检测日志看allUseTime和useTime是否超标

    example:
        $0 --logname /home/logs/pnsPush/pns.log --keyword "RsvClient messageReceived" --a 5000 --b 5000 --minute 1 --count 100

    参数：
        --logname   需要扫描的日志路径，按要求应该为
                       /home/logs/pnsPush/pns.log
                       /home/logs/pnsPush/pnspush.log
                       /home/logs/pnsPush/iospush.log
                       /home/logs/pnsPush/wnspush.log
                       /home/logs/pnsPush/webpoll.log
        --keyword   日志中出现该关键字才会进行统计
        --a         当有关键字的日志行中，设置allUseTime平均值的报警阀值，当日志平均值超出就会报警
        --b         当有关键字的日志行中，设置useTime平均值的报警阀值，当日志平均值超出就会报警
        --minute    统计至今多少分钟的日志
        --minimumCount
                    出现关键字的日志中，设置最少条目数阀值，少于该值就报警
        --help      display this help

HELPTEXT
    exit;
}
