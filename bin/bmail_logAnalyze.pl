#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: bmail_logAnalyze.pl
#
#        USAGE: ./bmail_logAnalyze.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: KK Mok (), kingkongmok@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 01/27/2015 10:03:06 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use lib '/home/operator/moqingqiang/bin';
use LogAnalyze;
chomp(my $nowdate = `date +%F -d -1day`);


#-------------------------------------------------------------------------------
#  需要分析的日志地址
#-------------------------------------------------------------------------------
my @logFiles = (
        "/home/logs/smsmw/172.16.210.52/bmail/monitoring.log.$nowdate",
        "/home/logs/smsmw/172.16.210.53/bmail/monitoring.log.$nowdate",
        "/home/logs/smsmw/172.16.210.54/bmail/monitoring.log.$nowdate",
    );
#my @logFiles = ("/tmp/bmail_monitoring.log");


#-------------------------------------------------------------------------------
# 需要和几天前的日志进行对比 
#-------------------------------------------------------------------------------
my $datesCompareWith = 1 ;


#-------------------------------------------------------------------------------
#  接口和模块的定义
#-------------------------------------------------------------------------------
my %interfaceField = (
        "RequestTime" =>  [ 
            8, {
                "mbox:searchMessages"    =>  [ 11, "总搜索接口" ],
            }, 
            8, '(?<=RequestTime=)(\d+)' ] ,

        "mergeInfo" =>  [ 
            12, {
                "SearchContacts"    =>  [ 11, "通信录接口" ],
                "rm SearchMessages"    =>  [ 11, "RM调用接口" ],
            }, 
            7, '(?<=RunTime=)(\d+)' ] ,
    );


#-------------------------------------------------------------------------------
#  各个时间点(ms)的百分比数
#-------------------------------------------------------------------------------
my @countTime = (50, 100, 150, 200, 300, 500, 1000, 120000);


#-------------------------------------------------------------------------------
#  Don't edit below
#-------------------------------------------------------------------------------
my $olddateCommand = 'date +%F -d ' . int(-1 - $datesCompareWith) . 'day' ;
chomp(my $olddate = `$olddateCommand`);
my ($dirname, $filename) = ($1,$3) if $0 =~ m/^(.*)(\\|\/)(.*)\.([0-9a-z]*)/;
my $tempFileDir = "$dirname/logAnalyzeTemp";
unless ( -d $tempFileDir ) {
    mkdir $tempFileDir;
}
my $linesRef = &getLogArray(@logFiles);
my %interfaceDesc = %{&analyze($linesRef, \%interfaceField, \@countTime)};
my ($interfaceDescRef, $interfaceDescRefOLD) = &mergeResult(\%interfaceDesc, $tempFileDir, $filename, $nowdate, $olddate);
my @printArray = &calcHashs($interfaceDescRef, $interfaceDescRefOLD, \%interfaceField, \@countTime);
&make_table_from_AoA(0,1,1,1,\@printArray, $tempFileDir, $filename, $nowdate, $datesCompareWith);
$filename =~ s/_.*//;
if ( -e "/home/operator/moqingqiang/bin/sendUserMail.sh" ) {
    `/home/operator/moqingqiang/bin/sendUserMail.sh -m $filename -d yesterday -c $datesCompareWith`
}
