#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: logAnalyze.pl
#
#        USAGE: ./logAnalyze.pl  
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
#use warnings;
use Data::Dumper;
use CGI::Pretty qw(:standard);

chomp(my $nowdate = `date +%F -d -1day`);
chomp(my $olddate = `date +%F -d -8day`);

my @logFiles = (
        "/home/logs/smsmw/172.16.210.52/diskmw/diskMonitor.log.$nowdate", 
        "/home/logs/smsmw/172.16.210.53/diskmw/diskMonitor.log.$nowdate", 
        "/home/logs/smsmw/172.16.210.54/diskmw/diskMonitor.log.$nowdate"
    );
#my @logFiles = ("/tmp/disk_monitoring.log");

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
#  Don't edit below
#-------------------------------------------------------------------------------
my @countTime = (50, 100, 150, 200, 300, 500, 1000, 120000);
my ($dirname, $filename) = ($1,$3) if $0 =~ m/^(.*)(\\|\/)(.*)\.([0-9a-z]*)/;
my $tempFileDir = "$dirname/logAnalyzeTemp";
unless ( -d $tempFileDir ) {
    mkdir $tempFileDir;
}


#===  FUNCTION  ================================================================
#         NAME: getElemDetail
#      PURPOSE: get @Element = ( suffix, interfaceValue, oldinterfaceValue, new/old )
#   PARAMETERS: 
#      RETURNS: @ElemDetail
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub getElemDetail {
    my	( $suffix, $newVal, $oldVal, $wishUp, $average)	= @_;
    my ($percent, $prefix, $thirdElem, $color, $fontsuffix, $fontprefix, $percentMark);
    my @ElemDetail ;
    # if both are exist
    if ( $newVal && $oldVal ) {
        # if both are not zero
        if ( $newVal != 0 && $oldVal != 0 ) {
            $percent = $newVal/$oldVal*100;
            if ( $percent > 100 ) {
                $prefix = '+';
                if ( $wishUp ) {
                    $color = $wishUp?"lightgreen":"red";
                }
                if ( $average ) {
                    $color = $newVal>$average?"lightgreen":"red";
                }
            } elsif ($percent>0 && $percent<100){
                $prefix = '-';
                if ( $wishUp ) {
                    $color = $wishUp?"red":"green";
                }
                if ( $average ) {
                    $color = $newVal>$average?"red":"green";
                }
            }
            $percent = sprintf"%.1f",abs($percent-100) ;
            if ( $percent > 40) {
                $fontprefix .= "<b>";
                $fontsuffix .= "<\/b>";
            } 
            if ($percent > 20 ) {
                $fontprefix .= "<font color='$color'>";
                $fontsuffix .= "<\/font>";
            }
            if ( $suffix ) {
                $newVal = sprintf"%.1f",$newVal;
                $oldVal = sprintf"%.1f",$oldVal;
            }
            $newVal .= $suffix ;
            $oldVal .= $suffix ;
            $thirdElem = "$fontprefix" . "$prefix" . "$percent" . "%" . "$fontsuffix";
            if ($percent == 0) {
                $thirdElem = "=="
            } 
        } 
        # if there is a zeror
        else {
            if ( $suffix ) {
                    $newVal = sprintf"%.1f",$newVal if $newVal;
                    $oldVal = sprintf"%.1f",$oldVal if $oldVal;
                }
            $newVal .= $suffix if $newVal;
            $oldVal .= $suffix if $oldVal;
            $thirdElem = "n/a";
        }
    } 
    # if there is a undef.
    else {
        if ( $suffix ) {
                $newVal = sprintf"%.1f",$newVal if $newVal;
                $oldVal = sprintf"%.1f",$oldVal if $oldVal;
            }
        $newVal .= $suffix if $newVal;
        $oldVal .= $suffix if $oldVal;
        $thirdElem = "n/a";
    }
    return ($newVal, $oldVal, $thirdElem);
} ## --- end sub getElemDetail


#===  FUNCTION  ================================================================
#         NAME: calcHashs
#      PURPOSE: 
#   PARAMETERS: ????
#      RETURNS: ????
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#==============================================================================
sub calcHashs {
    my	( $interfaceDescRef , $interfaceDescRefOLD)	= @_;
    my @printArray ;
    foreach my $intName (keys%$interfaceDescRef) {
        push @printArray, (["", "Description", "<b>访问</b>", "LWeek", "CMP", "", "<b>响应</b>", "LWeek", "CMP", "", "<b>0~50ms</b>", "LWeek", "CMP", "", "<b>50~100ms</b>", "LWeek", "CMP", "", "<b>100~150ms</b>", "LWeek", "CMP", "", "<b>150~200ms</b>", "LWeek", "CMP", "", "<b>200~300ms</b>", "LWeek", "CMP", "", "<b>300~500ms</b>", "LWeek", "CMP", "", "<b>500ms~1s</b>", "LWeek", "CMP", "", "<b>>1000ms</b>", "LWeek", "CMP"]) ;
        my @line = ( "<b>模块$intName</b>", "all" );
        push @line, &getElemDetail("" , ${$interfaceDescRef}{$intName}{stat}{intCount}, ${$interfaceDescRefOLD}{$intName}{stat}{intCount} , "1" );
        push @line, "";
        push @line, &getElemDetail("ms" , ${$interfaceDescRef}{$intName}{stat}{intAverageTime}, ${$interfaceDescRefOLD}{$intName}{stat}{intAverageTime} , "0" );
        push @printArray,[ @line ] ;
        foreach my $modName ( keys${$interfaceDescRef}{$intName}{mod} ) {
            @line = ($modName, ${$interfaceField{$intName}[1]}{$modName}[1],);
            push @line, &getElemDetail("", ${$interfaceDescRef}{$intName}{mod}{$modName}{count}{modCount}, ${$interfaceDescRefOLD}{$intName}{mod}{$modName}{count}{modCount}, "1" );
            push @line, "";
            push @line, &getElemDetail("ms" ,${$interfaceDescRef}{$intName}{mod}{$modName}{count}{modAverageTime}, ${$interfaceDescRef}{$intName}{mod}{$modName}{count}{modAverageTime}, "1" ); 
            foreach ( @countTime ) {
            push @line, "";
            push @line, &getElemDetail("%", ${$interfaceDescRef}{$intName}{mod}{$modName}{percent}{"$_"."%"}, ${$interfaceDescRefOLD}{$intName}{mod}{$modName}{percent}{"$_"."%"}, "" , ${$interfaceDescRef}{$intName}{mod}{$modName}{count}{modAverageTime});
            }
            push @printArray,([@line]);
        }
    }
    return \@printArray;
} ## --- end sub calcHashs


#===  FUNCTION  ================================================================
#         NAME: getLogArray
#      PURPOSE: input filename and get log's @lines
#   PARAMETERS: $filenames
#      RETURNS: @lines
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub getLogArray {
    my @lines;
    foreach my $file (@_) {
        open my $fh , "<", $file;
        push @lines, <$fh>;
        close $fh ;
    }
    return \@lines;
} ## --- end sub getLogArray


#===  FUNCTION  ================================================================
#         NAME: analyze
#      PURPOSE: input @lines and get @printArray
#   PARAMETERS: log's content @lines
#      RETURNS: \%interfaceDesc
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub analyze {
    my %interfaceDesc;
    my $linesRef = shift;
    for my $line ( @{$linesRef} ) {
        foreach my $intName ( keys %interfaceField ) {
            my @F = split /\|/,$line;
            my $timeRegex = $interfaceField{$intName}[3] ;
            my $timeNumb = $interfaceField{$intName}[2] ;
            my $intNumb = $interfaceField{$intName}[0]; 
            if ($F[$intNumb] =~ /$intName/) {
                $interfaceDesc{$intName}{stat}{intCount}++;
                $interfaceDesc{$intName}{stat}{intTotalTime}+= $& if $F[$timeNumb] =~ /$timeRegex/;
                if ( $interfaceDesc{$intName}{stat}{intTotalTime} && $interfaceDesc{$intName}{stat}{intCount}) {
                    $interfaceDesc{$intName}{stat}{intAverageTime}=$interfaceDesc{$intName}{stat}{intTotalTime}/$interfaceDesc{$intName}{stat}{intCount};
                foreach my $modName ( keys %{$interfaceField{$intName}[1]} ) {
                    my $modNumb = ${$interfaceField{$intName}[1]}{$modName}[0]; 
                    if ( $F[$modNumb] =~ /$modName/  ) {
                        if ($F[$timeNumb] =~ /$timeRegex/){
                            my $requesttime = $&;
                            foreach ( @countTime ) {
                                if ($requesttime < $_) {
                                    $interfaceDesc{$intName}{mod}{$modName}{time}{$_}++;
                                    last;
                                }
                            }
                            $interfaceDesc{$intName}{mod}{$modName}{count}{modTotalTime}+=$requesttime;
                            $interfaceDesc{$intName}{mod}{$modName}{count}{modCount}++;
                            foreach ( @countTime ) {
                                if ($interfaceDesc{$intName}{mod}{$modName}{time}{$_} && $interfaceDesc{$intName}{mod}{$modName}{count}{modCount} ){
                                    $interfaceDesc{$intName}{mod}{$modName}{percent}{$_."%"}= $interfaceDesc{$intName}{mod}{$modName}{time}{$_} / $interfaceDesc{$intName}{mod}{$modName}{count}{modCount} * 100;
                                }
                                else {
                                    $interfaceDesc{$intName}{mod}{$modName}{percent}{$_."%"}="0";
                                }
                                unless ($interfaceDesc{$intName}{mod}{$modName}{time}{$_} ){
                                    $interfaceDesc{$intName}{mod}{$modName}{time}{$_}=0
                                }
                            }
                        }
                    $interfaceDesc{$intName}{mod}{$modName}{count}{modAverageTime}=$interfaceDesc{$intName}{mod}{$modName}{count}{modTotalTime}/$interfaceDesc{$intName}{mod}{$modName}{count}{modCount};
                    }
                }
            }
            }
        }
    }
    return \%interfaceDesc;
} ## --- end sub analyze


#===  FUNCTION  ================================================================
#         NAME: mergeRusult
#      PURPOSE: get @printArray
#   PARAMETERS: %interfaceDesc, $tempFileDir, 
#      RETURNS: ????
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub mergeRusult {
    my	( $interfaceDescRef, $tempFileDir )	= @_;
    use Storable qw(store retrieve);
    my $newhashfile = "$tempFileDir/$filename" . "_hashdump_" . "$nowdate";
    store($interfaceDescRef, "$newhashfile") or die "Can't store %interfaceDescRef in $newhashfile!\n";
    my $interfaceDescRefOLD = ();
    my $oldhashfile = "$tempFileDir/$filename" . "_hashdump_" . "$olddate";
    if ( -r $oldhashfile ) {
        $interfaceDescRefOLD = retrieve("$oldhashfile"); 
    }
    my $txtfileoutName = "$tempFileDir/$filename" . "_data_" . "$nowdate" . ".txt";
    open my $txtFH, "> $txtfileoutName" ;
    print $txtFH Dumper $interfaceDescRef ;
    return &calcHashs($interfaceDescRef, $interfaceDescRefOLD);
} ## --- end sub mergeRusult


#===  FUNCTION  ================================================================
#         NAME: make_table_from_Aoa
#      PURPOSE: 
#   PARAMETERS: ????
#      RETURNS: ????
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
####################
#
#   make_table_from_Aoa
#
#   parameters
#   1)  $use_th : if this is true, the first line of the passed array will be used
#                   as an HTML header.
#   2)  $transpose : swap axis of array
#   3)  $check_array_size : if true, make sure each array has same # of elements
#   4)  $border : size of border to put around table.
#   5)  @l_array : holding tank for passed array.
#
####################
sub make_table_from_AoA {
    my $use_th = shift;
    my $transpose = shift;
    my $check_array_size = shift;
    my $border = shift;
    my @l_array = @_;
    my $htmlfileoutName = "$tempFileDir/$filename" . "_data_" . "$nowdate" . ".html";
    open my $htmlFH, "> $htmlfileoutName" ;
    #Make sure arrays are the same size. if not, die.
    if ($check_array_size){
        my $size =scalar(@{$l_array[0]});
        map  {die "funky arrays : First array is $size, found one of ".scalar(@{$_}) if scalar(@{$_}) != $size}@l_array;
    }
    if ($transpose) {
        my @tary;
        map {my $x=0;
            map {push @{$tary[$x]}, $_;$x++;} @$_;
        } @l_array;
        @l_array=@tary;
    }
    print $htmlFH h3("$filename" . "分析");
    print $htmlFH table( {-border=>$border},
        $use_th?th([@{shift @l_array}]):undef,
        map{Tr(map{td($_)}@$_)}@l_array
    );
    print $htmlFH h5("LWeek是上周数据，CMP是对比上周的增长率");
}


my $linesRef = &getLogArray(@logFiles);
my %interfaceDesc = %{&analyze($linesRef)};
my @printArray = &mergeRusult(\%interfaceDesc, $tempFileDir);
&make_table_from_AoA(0,1,1,1,@printArray);
