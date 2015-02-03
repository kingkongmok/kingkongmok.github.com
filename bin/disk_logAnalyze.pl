#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: disk_logAnalyze.pl
#
#        USAGE: ./disk_logAnalyze.pl  
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
        "/home/logs/smsmw/172.16.210.52/diskmw/diskMonitor.log.$nowdate", 
        "/home/logs/smsmw/172.16.210.53/diskmw/diskMonitor.log.$nowdate", 
        "/home/logs/smsmw/172.16.210.54/diskmw/diskMonitor.log.$nowdate"
    );
#my @logFiles = ("/tmp/disk_monitoring.log");


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
                "getWholeCatalog"    =>  [ 11, "获取整个目录结构信息" ],
                "getDisk"    =>  [ 11, "查询文件和子目录信息" ],
                "creatCatalog"    =>  [ 11, "创建彩云子目录" ],
                "copyContentCatalog"    =>  [ 11, "复制内容目录" ],
                "updateCatalogInfo"    =>  [ 11, "用户修改彩云目录名称" ],
                "moveContentCatalog"    =>  [ 11, "移动内容目录" ],
                "mgtVirDirInfo"    =>  [ 11, "管理虚拟目录信息" ],
                "qryCtnCtlgCount"    =>  [ 11, "查询用户彩云文件和目录总数" ],
                "getDiskInfo"    =>  [ 11, "获取彩云容量信息" ],
                "getContentInfo"    =>  [ 11, "查询内容信息" ],
                "delCatalogContent"    =>  [ 11, "删除用户网盘内的内容和目录" ],
                "updateContentInfo"    =>  [ 11, "修改内容信息" ],
                "downloadRequest"    =>  [ 11, "下载" ],
                "downloadZipPkgReq"    =>  [ 11, "打包下载" ],
                "getOutLink"    =>  [ 11, "获取外链" ],
                "delOutLink"    =>  [ 11, "删除文件外链" ],
                "dlFromOutLink"    =>  [ 11, "下载外链" ],
                "simpleSearch"    =>  [ 11, "搜索" ],
                "inviteShare"    =>  [ 11, "邀请共享" ],
                "cancelShare"    =>  [ 11, "取消共享" ],
                "getShareList"    =>  [ 11, "浏览发送共享和接收共享列表" ],
                "getShareInfo"    =>  [ 11, "获取共享信息" ],
                "leaveShare"    =>  [ 11, "退出共享" ],
                "replyShare"    =>  [ 11, "接收共享" ],
                "webUploadFile"    =>  [ 11, "web上传" ],
                "pcUploadFile"    =>  [ 11, "PC文件上传请求方法" ],
                "SyncUploadTaskInfo"    =>  [ 11, "断点续传" ],
                "uploadFile"    =>  [ 11, "内部上传" ],
                "directoryFileList"    =>  [ 11, "获取指定文件夹下的子文件夹" ],
                "getDirectorys"    =>  [ 11, "获取所有文件夹信息" ],
                "packageDownloadUrl"    =>  [ 11, "分布式获取打包下载url" ],
                "preUpload"    =>  [ 11, "分布式预上传服务" ],
                "applyAdditionalSize"    =>  [ 11, "容量调整" ],
                "manageAccount"    =>  [ 11, "注册" ],
            }, 
            8, '(?<=RequestTime=)(\d+)' ] ,

        "mergeInfo" =>  [ 
            12, {
                "disk:init"    =>  [ 11, "初始化接口" ],
                "disk:fileList"    =>  [ 11, "文件列表接口" ],
                "disk:getDirectorys"    =>  [ 11, "获取所有文件夹接口" ],
                "disk:delete"    =>  [ 11, "删除接口" ],
                "disk:createDirectory"    =>  [ 11, "创建文件夹接口" ],
                "disk:move"    =>  [ 11, "移动接口" ],
                "disk:download"    =>  [ 11, "获取下载URL接口" ],
                "disk:fastUpload"    =>  [ 11, "html5上传接口" ],
                "disk:resumeUpload"    =>  [ 11, "断点续传接口信息" ],
                "disk:normalUpload"    =>  [ 11, "获取普通上传URL接口" ],
                "disk:search"    =>  [ 11, "搜索接口" ],
                "disk:thumbnails"    =>  [ 11, "批量获取缩略图接口" ],
                "disk:attachUpload"    =>  [ 11, "附件存网盘接口" ],
                "disk:setCover"    =>  [ 11, "设置相册封面接口" ],
                "disk:share"    =>  [ 11, "共享接口" ],
                "disk:friendShareList"    =>  [ 11, "好友共享接口" ],
                "disk:myShareList"    =>  [ 11, "我的共享接口" ],
                "disk:cancelShare"    =>  [ 11, "取消共享接口" ],
                "disk:delShare"    =>  [ 11, "删除共享接口" ],
                "disk:shareCopyTo"    =>  [ 11, "好友共享文件存网盘接口" ],
                "disk:rename"    =>  [ 11, "重命名接口" ],
                "disk:backupBillMail"    =>  [ 11, "备份帐单至彩云对内接口" ],
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
