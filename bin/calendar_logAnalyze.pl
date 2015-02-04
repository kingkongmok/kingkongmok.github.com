#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: calendar_logAnalyze.pl
#
#        USAGE: ./calendar_logAnalyze.pl  
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
        "/home/logs/smsmw/172.16.210.52/calendar/monitor.log.$nowdate",
        "/home/logs/smsmw/172.16.210.53/calendar/monitor.log.$nowdate",
        "/home/logs/smsmw/172.16.210.54/calendar/monitor.log.$nowdate",
    );
#my @logFiles = ("/tmp/calendar_monitoring.log");


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
                "calendar:addLabel"    =>  [ 11, "添加日历" ],
                "calendar:updateLabel"    =>  [ 11, "更新日历" ],
                "calendar:deleteLabel"    =>  [ 11, "删除日历" ],
                "calendar:getLabelById"    =>  [ 11, "根据日历ID查询日历" ],
                "calendar:subscribeLabel"     =>  [ 11, "订阅公共日历" ],
                "calendar:cancelSubscribeLabel"    =>  [ 11, "取消订阅公共日历" ],
                "calendar:getLabels"    =>  [ 11, "查询用户日历列表" ],
                "calendar:listTopLabels"    =>  [ 11, "查询前十个公共日历" ],
                "calendar:getCalendarListView"    =>  [ 11, "查询活动列表视图" ],
                "calendar:getCalendarView"    =>  [ 11, "查询用户活动列表" ],
                "calendar:getCalendar"    =>  [ 11, "查询用户某个活动" ],
                "calendar:addCalendar"    =>  [ 11, "添加活动" ],
                "calendar:updateCalendar"    =>  [ 11, "更新活动" ],
                "calendar:deleteCalendar"    =>  [ 11, "取消活动" ],
                "api:getCalendarListView"    =>  [ 11, "运营-查询活动列表视图" ],
                "api:addCalendar"    =>  [ 11, "运营-添加活动" ],
                "api:updateCalendar"    =>  [ 11, "运营-更新活动" ],
                "api:getCalendar"    =>  [ 11, "运营-查询某个活动" ],
                "api:deleteCalendar"    =>  [ 11, "运营-删除活动" ],
                "api:subscribeLabel"    =>  [ 11, "运营-订阅公共日历" ],
                "calendar:searchPublicLabel"    =>  [ 11, "搜索公共日历" ],
                "calendar:getPublishedLabelByOper"    =>  [ 11, "得到公共日历详情" ],
                "api:publishLabelByOper"    =>  [ 11, "发布公共日历" ],
                "api:updatePublishedLabelByOper"    =>  [ 11, "修改公共日历" ],
                "calendar:copyCalendar"    =>  [ 11, "复制活动" ],
                "calendar:getCalendarList"    =>  [ 11, "酷版时间轴接口" ],
                "calendar:setCalendarRemind"    =>  [ 11, "设置自定义提醒" ],
                "calendar:shareCalendar"    =>  [ 11, "活动分享接口" ],
                "calendar:getCalendarsByLabel"    =>  [ 11, "通过labelID获取所有活动详情" ],
                "calendar:getHuangliData"    =>  [ 11, "黄历查询接口" ],
                "calendar:getMessageCount"    =>  [ 11, "未读消息数量" ],
                "calendar:getMessageList"    =>  [ 11, "得到消息列表" ],
                "calendar:getMessageById"    =>  [ 11, "单个消息详情" ],
                "calendar:delMessage"    =>  [ 11, "删除消息" ],
                "calendar:getCalendarView"    =>  [ 11, "查询用户活动视图" ],
            }, 
            8, '(?<=RequestTime=)(\d+)' ] ,
    );


#-------------------------------------------------------------------------------
#  各个时间点(ms)的百分比数
#-------------------------------------------------------------------------------
my @countTime = (50, 100, 150, 200, 300, 500, 1000, 120000);


#-------------------------------------------------------------------------------
#  用于发邮件的脚本，传递文件名让其发邮件
#-------------------------------------------------------------------------------
my $emailCommand = "/home/operator/moqingqiang/bin/sendUserMail.sh" ;


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
if ( -e $emailCommand ) {
    `$emailCommand -m $filename -d yesterday -c $datesCompareWith`
}
