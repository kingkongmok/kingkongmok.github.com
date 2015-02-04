#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: setting_logAnalyze.pl
#
#        USAGE: ./setting_logAnalyze.pl  
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
#my @logFiles = (
#        "/home/logs/smsmw/172.16.200.2/setting/monitoring.log.$nowdate",
#        "/home/logs/smsmw/172.16.200.8/setting/monitoring.log.$nowdate",
#        "/home/logs/smsmw/172.16.200.9/setting/monitoring.log.$nowdate",
#    );
my @logFiles = ("/tmp/setting_monitoring.log");
#my @logFiles = ("/home/operator/moqingqiang/bin/setting_monitoring.log");


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
                "unified:getUnifiedPositionContent"    =>  [ 11, "同一位置" ],
                "user:getInfoCenter"    =>  [ 11, "信息中心" ],
                "user:getMailNotify"    =>  [ 11, "邮件到达提醒" ],
                "user:getMainData"    =>  [ 11, "邮箱属性" ],
                "umc:getArtifact"     =>  [ 11, "用管中心凭证" ],
                "bill:getTypeList"    =>  [ 11, "账单信息" ],
                "user:setUserConfigInfo"    =>  [ 11, "用户配置信息" ],
                "info:getInfoSet"    =>  [ 11, "欢迎页信息" ],
            }, 
            8, '(?<=RequestTime=)(\d+)' ] ,

        "mergeInfo" =>  [ 
            12, {
                "mealInfo"    =>  [ 11, "套餐信息" ],
                "mailInfo"    =>  [ 11, "邮箱属性" ],
                "whoAddMe"    =>  [ 11, "谁加了我" ],
                "dynamicInfo"    =>  [ 11, "动态信息" ],
                "checkinInfo"    =>  [ 11, "签到信息" ],
                "personalInfo"    =>  [ 11, "个人信息" ],
                "weatherInfo"    =>  [ 11, "天气预报" ],
                "birthdayInfo"    =>  [ 11, "好友生日提醒" ],
            }, 
            7, '(?<=RunTime=)(\d+)' ] ,

        "ProfilesService" =>  [ 
            11, {
                "callPSMainUserInfo"    =>  [ 12, "查询邮箱属性" ],
                "callPSPersonal"    =>  [ 12, "查询个人信息" ],
                "callPS1003"    =>  [ 12, "查询配置表" ],
                "callPS6201"    =>  [ 12, "修改配置表" ],
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
my %interfaceDesc = %{&analyze( \@logFiles, \%interfaceField, \@countTime)};
my ($interfaceDescRef, $interfaceDescRefOLD) = &mergeResult(\%interfaceDesc, $tempFileDir, $filename, $nowdate, $olddate);
my @printArray = &calcHashs($interfaceDescRef, $interfaceDescRefOLD, \%interfaceField, \@countTime);
&make_table_from_AoA(0,1,1,1,\@printArray, $tempFileDir, $filename, $nowdate, $datesCompareWith);
$filename =~ s/_.*//;
if ( -e "/home/operator/moqingqiang/bin/sendUserMail.sh" ) {
    `/home/operator/moqingqiang/bin/sendUserMail.sh -m $filename -d yesterday -c $datesCompareWith`
}
