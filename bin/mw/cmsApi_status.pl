#!/usr/bin/perl
use strict;                                  
use warnings;

my $logfile = "/home/logs/cmsApi/cmsInterface.log";

#open my $fh, '-|:encoding(gbk)',  "tail -c 300m $logfile" || die $!; 
open my $fh, "tail -c 500m $logfile |" || die $!; 


my %H;
my %K;
while ( <$fh> ) {
    if ( /\[ERROR\].*(?:详细原因：|处理失败：)(.*?)$/ ) {
        my $thisTime = substr $_,0,4;
        $H{$thisTime}{ERROR}++;
        $H{$thisTime}{$1}++;
        $K{ERROR}{$1}++;

    }
    if ( /\[INFO\]/ ) {
        my $thisTime = substr $_,0,4;
        $H{$thisTime}{INFO}++;
    }
}


# print header;
my @ERRORTYPE = keys %{$K{ERROR}};
printf "time:\t";
foreach my $method ( ("INFO", "ERROR") ) {
    printf "%8s\t", $method
}
foreach my $method ( @ERRORTYPE ) {
    printf "%15s\t", $method
}
print "\n";
my @times = sort keys%H;
# cut 1st line. 
# shift @times ;


# print contents
foreach my $time ( @times ) {
    printf "%s0:\t", $time;
    foreach my $method ( ("INFO", "ERROR") ) {
        my $column = $H{$time}{$method} || 0;
        printf "%8s\t", $column;
    }
    foreach my $error ( @ERRORTYPE ) {
        my $errorOut = $H{$time}{$error} ? $H{$time}{$error} : 0 ;
        printf "%15s", $errorOut;
    }
    print "\n";
}

=pod
output example
time:       INFO       ERROR    ORA-01722: 无效数字  数据库查询异常 
00:00:     15051          20                 10             10
00:10:        30           0                  0              0
00:20:     15044          20                 10             10
00:30:         8           0                  0              0
00:40:         2           0                  0              0
=cut
