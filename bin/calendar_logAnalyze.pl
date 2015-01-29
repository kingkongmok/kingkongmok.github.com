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

my @logFiles = qw#
    /tmp/calendar_monitoring.log 
    #;


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

#        "mergeInfo" =>  [ 
#            12, {
#                "mealInfo"    =>  [ 11, "套餐信息" ],
#                "mailInfo"    =>  [ 11, "邮箱属性" ],
#                "whoAddMe"    =>  [ 11, "谁加了我" ],
#                "dynamicInfo"    =>  [ 11, "动态信息" ],
#                "checkinInfo"    =>  [ 11, "签到信息" ],
#                "personalInfo"    =>  [ 11, "个人信息" ],
#                "weatherInfo"    =>  [ 11, "天气预报" ],
#                "birthdayInfo"    =>  [ 11, "好友生日提醒" ],
#            }, 
#            7, '(?<=RunTime=)(\d+)' ] ,
#
#        "ProfilesService" =>  [ 
#            11, {
#                "callPSMainUserInfo"    =>  [ 12, "查询邮箱属性" ],
#                "callPSPersonal"    =>  [ 12, "查询个人信息" ],
#                "callPS1003"    =>  [ 12, "查询配置表" ],
#                "callPS6201"    =>  [ 12, "修改配置表" ],
#            }, 
#            7, '(?<=RunTime=)(\d+)' ] ,
   );


#-------------------------------------------------------------------------------
#  Don't edit below
#-------------------------------------------------------------------------------

my @countTime = (50, 100, 150, 200, 300, 500, 1000, 120000);
my ($dirname, $filename) = ($1,$3) if $0 =~ m/^(.*)(\\|\/)(.*)\.([0-9a-z]*)/;
my($day, $month, $year) = (localtime)[3,4,5];
my $nowdate =  $year+1900 . sprintf"%02d",$month+1 . sprintf"%02d",$day;
my $NUM_DAYS = 7;
my $time = time();
my ($oldday,$oldmonth,$oldyear)=+(localtime (time() - (60*60*24*7)))[3,4,5];
my $olddate =  $oldyear+1900 . sprintf"%02d",$oldmonth+1 . sprintf"%02d",$oldday;
my $tempFileDir = "$dirname/logAnalyzeTemp";
unless ( -d $tempFileDir ) {
    mkdir $tempFileDir;
}

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
        push @printArray, (["名称", "Description", "访问", "LWeek", "CMP", "", "响应", "LWeek", "CMP", "", "0~50ms", "LWeek", "CMP", "", "50~100ms", "LWeek", "CMP", "", "100~150ms", "LWeek", "CMP", "", "150~200ms", "LWeek", "CMP", "", "200~300ms", "LWeek", "CMP", "", "300~500ms", "LWeek", "CMP", "", "500ms~1s", "LWeek", "CMP", "", ">1000ms", "LWeek", "CMP"]) ;
        my $contentTemp =  (${$interfaceDescRef}{$intName}{stat}{intCount} && ${$interfaceDescRefOLD}{$intName}{stat}{intCount})?${$interfaceDescRef}{$intName}{stat}{intCount}/${$interfaceDescRefOLD}{$intName}{stat}{intCount}*100:0;
            my $tempComp ;
            if ($contentTemp == 100) {
                $tempComp = '==';
            }
            elsif ($contentTemp == 0) {
                $tempComp = 'n/a';
            }
            else {
                $tempComp = sprintf("%s",$contentTemp>100?"+":"-") . sprintf("%.1f",abs($contentTemp-100)) . "%";
                if ( abs($contentTemp-100) > 30 ) {
                    $tempComp =~ s/$tempComp/<font color=red>$&<\/font>/;
                }
                if ( abs($contentTemp-100) > 50 ) {
                    $tempComp =~ s/$tempComp/<b>$&<\/b>/;
                }
            }
            my $contentTemp2 =  (${$interfaceDescRef}{$intName}{stat}{intAverageTime} && ${$interfaceDescRefOLD}{$intName}{stat}{intAverageTime})?${$interfaceDescRef}{$intName}{stat}{intAverageTime}/${$interfaceDescRefOLD}{$intName}{stat}{intAverageTime}*100:0;
            my $tempComp2 ;
            if ($contentTemp2 == 100) {
                $tempComp2 = '==';
            }
            elsif ($contentTemp2 == 0) {
                $tempComp2 = 'n/a';
            }
            else {
                $tempComp2 = sprintf("%s",$contentTemp2>100?"+":"-") . sprintf("%.1f",abs($contentTemp2-100)) . "%";
                if ( abs($contentTemp2-100) > 30 ) {
                    $tempComp2 =~ s/$tempComp2/<font color=red>$&<\/font>/;
                }
                if ( abs($contentTemp2-100) > 50 ) {
                    $tempComp2 =~ s/$tempComp2/<b>$&<\/b>/;
                }
            }
        push @printArray,(["<b>模块$intName</b>", "all", ${$interfaceDescRef}{$intName}{stat}{intCount}, ${$interfaceDescRefOLD}{$intName}{stat}{intCount}, $tempComp, "", sprintf("%.2f",${$interfaceDescRef}{$intName}{stat}{intAverageTime}), sprintf("%.2f",${$interfaceDescRefOLD}{$intName}{stat}{intAverageTime}), "$tempComp2"]);
        foreach my $modName ( keys${$interfaceDescRef}{$intName}{mod} ) {
            my @contentArray = ();
            push @contentArray,$modName;
            push @contentArray, ${$interfaceField{$intName}[1]}{$modName}[1];
            # pv
            push @contentArray, ${$interfaceDescRef}{$intName}{mod}{$modName}{count}{modCount};
            push @contentArray, ${$interfaceDescRefOLD}{$intName}{mod}{$modName}{count}{modCount};
            $contentTemp =  (${$interfaceDescRef}{$intName}{mod}{$modName}{count}{modCount} && ${$interfaceDescRefOLD}{$intName}{mod}{$modName}{count}{modCount})?${$interfaceDescRef}{$intName}{mod}{$modName}{count}{modCount}/${$interfaceDescRefOLD}{$intName}{mod}{$modName}{count}{modCount}*100:0;
            if ($contentTemp == 100) {
                push @contentArray, '==';
            }
            elsif ($contentTemp == 0) {
                push @contentArray, 'n/a';
            }
            else {
                push @contentArray, sprintf("%s",$contentTemp>100?"+":"-") . sprintf("%.1f",abs($contentTemp-100)) . "%";
            }
            push @contentArray,"";
            # response
            push @contentArray, sprintf ("%.2f",${$interfaceDescRef}{$intName}{mod}{$modName}{count}{modAverageTime}) . "ms";
            push @contentArray, sprintf ("%.2f",${$interfaceDescRefOLD}{$intName}{mod}{$modName}{count}{modAverageTime}) . "ms";
            $contentTemp = (${$interfaceDescRef}{$intName}{mod}{$modName}{count}{modAverageTime} && ${$interfaceDescRefOLD}{$intName}{mod}{$modName}{count}{modAverageTime})?${$interfaceDescRef}{$intName}{mod}{$modName}{count}{modAverageTime}/${$interfaceDescRefOLD}{$intName}{mod}{$modName}{count}{modAverageTime}*100:0;
            if ($contentTemp == 100) {
                push @contentArray, '==';
            }
            elsif ($contentTemp == 0) {
                push @contentArray, 'n/a';
            }
            else {
                push @contentArray, sprintf("%s",$contentTemp>100?"+":"-") . sprintf("%.1f",abs($contentTemp-100)) . "%";
            }
            push @contentArray,"";
            # percents
            foreach ( @countTime ) {
                #push @contentArray, sprintf ("%.2f",${$interfaceDescRef}{$intName}{mod}{$modName}{percent}{"$_"."%"}) . "%";
                if ( ${$interfaceDescRef}{$intName}{mod}{$modName}{percent}{"$_"."%"} ) {
                    push @contentArray, sprintf ("%.2f",${$interfaceDescRef}{$intName}{mod}{$modName}{percent}{"$_"."%"}) . "%";
                } else {
                    push @contentArray, "0";
                }

                
                #push @contentArray, sprintf ("%.2f",${$interfaceDescRefOLD}{$intName}{mod}{$modName}{percent}{"$_"."%"}) . "%";
                if ( ${$interfaceDescRefOLD}{$intName}{mod}{$modName}{percent}{"$_"."%"} ) {
                    push @contentArray, sprintf ("%.2f",${$interfaceDescRefOLD}{$intName}{mod}{$modName}{percent}{"$_"."%"}) . "%";
                } else {
                    push @contentArray, "0";
                }
                $contentTemp = (${$interfaceDescRef}{$intName}{mod}{$modName}{percent}{"$_"."%"} && ${$interfaceDescRefOLD}{$intName}{mod}{$modName}{percent}{"$_"."%"})?${$interfaceDescRef}{$intName}{mod}{$modName}{percent}{"$_"."%"}/${$interfaceDescRefOLD}{$intName}{mod}{$modName}{percent}{"$_"."%"}*100:0;
                if ($contentTemp == 100) {
                    push @contentArray, '==';
                }
                elsif ($contentTemp == 0) {
                    push @contentArray, 'n/a';
                }
                else {
                    push @contentArray, sprintf("%s",$contentTemp>100?"+":"-") . sprintf("%.1f",abs($contentTemp-100)) . "%";
                }
                push @contentArray,"";
            }
            push @printArray,([@contentArray]);
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
    my $fileoutName = "$tempFileDir/$filename" . "_data_" . "$nowdate" . ".html";
    open my $fileout, "> $fileoutName" ;
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
    print $fileout h3("$filename" . "分析");
    print $fileout table( {-border=>$border},
        $use_th?th([@{shift @l_array}]):undef,
        map{Tr(map{td($_)}@$_)}@l_array
    );
    print $fileout h5("LWeek是上周数据，CMP是对比上周的增长率");
}


my $linesRef = &getLogArray(@logFiles);
my %interfaceDesc = %{&analyze($linesRef)};
#print Dumper \%interfaceDesc;
my @printArray = &mergeRusult(\%interfaceDesc, $tempFileDir);
&make_table_from_AoA(0,1,1,1,@printArray);

