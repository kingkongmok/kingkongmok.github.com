#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: http_status.pl
#
#        USAGE: ./http_status.pl  
#
#  DESCRIPTION: 请使用 ./http_status.pl --help 获取帮助
#
#      OPTIONS: --day|-d n
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
# ORGANIZATION: datlet.com
#      VERSION: 1.0
#      CREATED: 06/20/2016 02:17:14 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use Data::Dumper;
use Date::Parse;
use List::Util qw(sum);
use Getopt::Long;
use POSIX "strftime";

# setup my defaults
my $logname;
my $delayDate = 0 ;

GetOptions(
    'day|d=i'    => \$delayDate,
    'help|h!'     => \&help,
) or die "Incorrect usage!\n";

my $searchtime = time - $delayDate*24*60*60; 

my $timestamp = strftime "%Y%m%d", localtime $searchtime;
my $timestampF = strftime "%F", localtime $searchtime;

my %logs = ( 
    "apache3" => "/logs/app3/access_$timestamp.log",
    "apache4" => "/logs/app4/access_$timestamp.log",
    "1-1" => "/logs/1-1/cks_access_log.$timestampF.log",
    "1-2" => "/logs/1-2/cks_access_log.$timestampF.log",
    "2-1" => "/logs/2-1/cks_access_log.$timestampF.log",
    "2-2" => "/logs/2-2/cks_access_log.$timestampF.log",
);

sub getLogDetail {
    my	 ($logalias, $logname, $result )	= @_;
    if ( -e $logname ) {
        #open my $fh, "tail -c 50m $logname | tac |" || die $!; 
        open my $fh, $logname || die $!; 
        my $now = time;
        my $alarmMsg;
        while ( <$fh> ) {
            if ( /:(\d{2}:\d)\d:.*\" (\d+) \S+$/ ) {
                if ( $2 < 400 ) {
                    $result->{$logalias}{$1}{s}++;
                }
                else{
                    $result->{$logalias}{$1}{f}++;
                }
            }
                
        }
    }
    return $result;
} ## --- end sub getValue


my $result;

foreach my $key ( keys %logs ) {
    $result = getLogDetail( $key , $logs{$key}, $result);
    # print Dumper $result; 
}

my @lognames =  keys %$result;
my @times = sort keys %{$result->{'1-1'}};


my %total;


print "\n";
printf "%-12s\t","$timestampF";
foreach my $logname ( sort @lognames ) {
    printf "%12s\t", $logname; 
}
print "\n";

foreach my $time ( @times ) {
    printf "%-12s\t",$time . "0" ;
    foreach my $logname ( sort @lognames ) {
        printf "%12s+%s\t", $result->{"$logname"}{$time}{s}//"0" , $result->{"$logname"}{$time}{f}//"0";
        ${total}{$logname}{s}+=$result->{"$logname"}{$time}{s}//"0";
        ${total}{$logname}{f}+=$result->{"$logname"}{$time}{f}//"0";
    }
    print "\n";
}

printf "%-12s\t","total";
foreach my $logname ( sort @lognames ) {
    printf "%12s+%s\t", ${total}{$logname}{s}//"0", ${total}{$logname}{f}//"0";
}
print "\n";




sub help {
    print <<HELPTEXT;

    目的： 统计各个accesslog的http code数量
    
    显示：
               首行是各个服务器的名称，其中:

               "1-1", "1-2" 位于 app1服务器，
               "2-1", "2-2" 位于 app2服务器，
               "apache3"    位于 app3服务器；
               "apache4"    位于 app4服务器；

    

    example:

        log        1-1         1-2
        00:00     1928+0       422+0

        表示在 "0:00" ~ "0:10" 时间段中，出现在 "1-1"和"1-2"accesslog的成功次数和失败次数

        成功次数是统计 http code 小于400的次数， 例如200
        失败次数是统计 http code 大于等于400的次数， 例如404，503

    参数：
        --help          display this help
        --day|-d n      n日前数据的统计(根据accesslog是否存在来统计)

HELPTEXT
    exit;
}
