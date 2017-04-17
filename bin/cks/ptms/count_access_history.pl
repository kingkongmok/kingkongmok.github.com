#!/usr/bin/env perl
#===============================================================================
#
#         FILE: count_access_history.pl
#
#        USAGE: 计算日志的50天历史记录，
#               配合tomcat_stats.pl|iis_stats.pl的-a参数使用
#
#  DESCRIPTION: print only
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
# ORGANIZATION: datlet.com
#      VERSION: 1.0
#      CREATED: 10/31/2016 10:44:27 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use Data::Dumper;
use Date::Parse;
use feature 'say';
use POSIX; 


#-------------------------------------------------------------------------------
# %F datetime for last 50 days.
#-------------------------------------------------------------------------------
# my @dates = map {sprintf"2016-11-%02d",$_ }8..31;
my @dates; 
foreach my $day ( 0..50 ) {
    push @dates , strftime "%F", localtime time - 24*60*60*$day; 
}


#-------------------------------------------------------------------------------
#  ignore this client
#-------------------------------------------------------------------------------
my @remote_monitor_ip = (
    '172.16.40.74',
    '172.26.45.12',
);


foreach my $date ( sort @dates  ) {
    # my $log = "/home/logs/172.16.45.243/localhost_access_log." . $date . ".txt" ;
#-------------------------------------------------------------------------------
#  /home/logs/172.16.45.243/localhost_access_log.2017-04-06.txt
#-------------------------------------------------------------------------------
    my $log = "/home/logs/172.16.45.243/localhost_access_log." . $date . ".txt" ;
    if ( -r $log ) {
        open my $fh, $log || die $! ;
        my $count;
        while ( <$fh> ) {
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
                (\S+)\s*
                $/x
            ) {
                my $l = $_;
                my $time = str2time($time_local) || next ;
                my $reqms = int($request_time) || next ;
                next if grep { /^$remote_addr$/ } @remote_monitor_ip;
                $count++;
            }
        }
            close $fh;
            say "$date $count";
    }
    else {
        say "$log not found"
    }
}
