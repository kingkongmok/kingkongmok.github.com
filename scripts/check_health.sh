#!/bin/bash - 
#===============================================================================
#
#          FILE: check_health.sh
# 
#         USAGE: ./check_health.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 08/25/2014 04:33:57 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
[ -r /etc/default/locale ] && . /etc/default/locale
[ -n "$LANG" ] && export LANG
#set -x 

#  接受报警邮件邮箱
MAILUSER='ayanami_0@163.com'

# 15分钟内负载的报警阀
LOADAVERAGE_TRIGER=50

# 各个分区的用量报警阀
DF_USAGE_TRIGER=80

# 监控文件夹的名称，数组
#WATCH_DIR=/mmsdk01/mmlog_7711/self/$(date "+%Y%m%d")
WATCH_DIR_LIST=(7711 7722 7733 7744)

# 多少分钟内文件夹必须做修改
WATCH_DIR_NOTCHANG_TRIGER=5

# 文件夹里有多少个增量
INCREASEFILENUMB_TRIGER=1

# tomcat端口，数值
PORT_LIST=(7711 7722 7733 7744)

# 挂载点
MOUNTPORT="mmsdk"



#-------------------------------------------------------------------------------
#  DO NOT EDIT BELOW
#  请勿修改以下内容
#-------------------------------------------------------------------------------

TFILE="/tmp/$(basename $0).$$.tmp"
IP_ADDR=`/sbin/ip a | grep -oP "(?<=inet )\S+(?=\/.*bond)"`

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  sendmail
#   DESCRIPTION:  以固定名称，发送$TFILE的内容到$MAILUSER邮箱
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
sendmail ()
{
    echo "Subject: `hostname`_"$IP_ADDR"_error" | cat - "$TFILE" | /usr/sbin/sendmail -f kk_richinfo@163.com -t "$MAILUSER" -s smtp.163.com -u "error" -xu kk_richinfo -xp 1q2w3e4r 
}	# ----------  end of function sendmail  ----------



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  checkLoadAverage
#   DESCRIPTION:  查看过去15分钟平均负载，比对$LOADAVERAGE_TRIGER
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
checkLoadAverage ()
{
    LOADAVERAGE_15=`uptime | perl -lane 'print int($F[$#F])'`
    if [ "$LOADAVERAGE_15" -gt "$LOADAVERAGE_TRIGER" ] ; then
        echo "loadaverage is $LOADAVERAGE_15" >> $TFILE
    fi
}	# ----------  end of function checkLoadAverage  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  checkTomcat
#   DESCRIPTION:  查看各个端口的tomcat是否正常
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
checkTomcat ()
{
    for port in ${PORT_LIST[@]} ; do
        if [ ! "$(curl -is http://127.0.0.1:${port}/healthcheck.jsp | grep 'HTTP/1.1 200 OK')" ] ; then
            echo "tomcat error" >> $TFILE
        fi
    done
}	# ----------  end of function checkTomcat  ----------
   


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  checkSpace
#   DESCRIPTION:  查看各个分区有否超过$DF_USAGE_TRIGER
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
checkSpace ()
{
    MAX_DF_USAGE="`df | perl -lane '$m=int($F[$#F-1])>$m?int($F[$#F-1]):$m}{print$m'`"

    if [ "$MAX_DF_USAGE" -gt "$DF_USAGE_TRIGER" ] ; then
        echo "disk usage error: $MAX_DF_USAGE" >> $TFILE 
    fi
}	# ----------  end of function checkSpace  ----------



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  checkFileStat
#   DESCRIPTION:  查看各个相应文件夹的修改时间，如果没有修改报警
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
checkFileStat ()
{
    for dir in ${WATCH_DIR_LIST[@]}; do
        WATCH_DIR=/${MOUNTPORT}/mmlog_${dir}/self/$(date "+%Y%m%d")
        TIMESTAMPDELAY_MINS=$(((`date "+%s"`-`stat -c "%Y" "$WATCH_DIR"`)/60))
        if [ "$TIMESTAMPDELAY_MINS" -gt "$WATCH_DIR_NOTCHANG_TRIGER" ] ; then
            echo "$WATCH_DIR is not changed more than $WATCH_DIR_NOTCHANG_TRIGER minuts" >> $TFILE 
        fi
    done
}	# ----------  end of function checkFileStat  ----------



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  checkIncreaseFileNumb
#   DESCRIPTION:  查看所在文件夹的硬链接个数增加情况，对比$INCREASEFILENUMB_TRIGER
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
checkIncreaseFileNumb ()
{
    for dir in ${WATCH_DIR_LIST[@]}; do
        WATCH_DIR=/${MOUNTPORT}/mmlog_${dir}/self/$(date "+%Y%m%d")
    LAST_FILENUMB_LOC="/tmp/$(basename $0).${dir}.filenumb"
    FILENUMB=`stat "$WATCH_DIR" | grep Links | awk '{print $NF}'`
    INCREASENUMB=`echo $FILENUMB-$(grep -oP '^\d+(?=\s)' $LAST_FILENUMB_LOC) | bc`
    INCREASELOCATENAME=$(grep -oP '(?<=\s)\S+$' $LAST_FILENUMB_LOC)
    if [ "$INCREASELOCATENAME" == "$WATCH_DIR" ] ; then
        if [ "$INCREASENUMB" -lt "$INCREASEFILENUMB_TRIGER" ] ; then
            echo "the increase for $WATCH_DIR is less than $INCREASEFILENUMB_TRIGER" >> $TFILE 
        fi
    fi
    echo "${FILENUMB}   ${WATCH_DIR}" > "$LAST_FILENUMB_LOC"
    done
}	# ----------  end of function checkIncreaseFileNumb  ----------

checkIncreaseFileNumb
checkFileStat
checkLoadAverage; 
checkSpace;
checkTomcat;

if [ -r "$TFILE" ] ; then
    sendmail;
    rm $TFILE;
fi
