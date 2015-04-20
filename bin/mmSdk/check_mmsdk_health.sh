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

#  接受报警邮件邮箱
MAILUSER='13725269365@139.com'

# 15分钟内负载的报警阀
LOADAVERAGE_TRIGER=15

# 各个分区的用量报警阀
DF_USAGE_TRIGER=85

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
MOUNTPORT=`df | perl -nae 'print "$F[-1]\n" if $F[-1] =~ /\/mmsdk/i'`



#-------------------------------------------------------------------------------
#  DO NOT EDIT BELOW
#  请勿修改以下内容
#-------------------------------------------------------------------------------

TFILE="/tmp/$(basename $0).$$.tmp"
IP_ADDR=`/sbin/ip a | grep -oP "(?<=inet )\S+(?=\/.*bond)"`
CURL=/usr/bin/curl


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  errorMail
#   DESCRIPTION:  mail the $MAILUSER with $TFILE
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
errorMail ()
{
    echo -e "Subject: ${IP_ADDR}_`basename $0`\n" | cat - $TFILE | /usr/local/bin/msmtp $MAILUSER 
}   # ----------  end of function errorMail  ----------

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
#   DESCRIPTION:  查看各个端口的tomcat是否正常, 否则重启
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
checkTomcat ()
{
    for port in ${PORT_LIST[@]} ; do
#        if [ ! "$(curl -is http://127.0.0.1:${port}/healthcheck.jsp | grep 'HTTP/1.1 200 OK')" ] ; then
#            echo "tomcat error" >> $TFILE
#        fi
        j=0
        for i  in `seq 10` ; do
            if [ "$($CURL -i -s http://127.0.0.1:${port}/healthcheck.jsp  | grep '200 OK')" ]  ; then
                break ; 
            else
                j=$(($j+1))
                sleep 2 ;
            fi
        done
        if [ $j == 10 ] ; then
            /opt/mmSdk/sbin/tomcat_${port}.sh restart
            echo "tomcat_${port} restarted" >> $TFILE
            break;
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
        WATCH_DIR=${MOUNTPORT}/mmlog_${dir}/self/$(date "+%Y%m%d")
        if [ -d "WATCH_DIR" ] ; then 
            TIMESTAMPDELAY_MINS=$(((`date "+%s"`-`stat -c "%Y" "$WATCH_DIR"`)/60))
            if [ "$TIMESTAMPDELAY_MINS" -gt "$WATCH_DIR_NOTCHANG_TRIGER" ] ; then
                echo "$WATCH_DIR is not changed more than $WATCH_DIR_NOTCHANG_TRIGER minuts" >> $TFILE 
            fi
        fi
    done
}	# ----------  end of function checkFileStat  ----------



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  checkBondInterface
#   DESCRIPTION:  check bonding interface
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
checkBondInterface ()
{
    perl -00ne 'print if /MII Status: (?!up)/m' /proc/net/bonding/bond0 >> $TFILE
}	# ----------  end of function checkBondInterface  ----------


checkZombieProcess ()
{
    if  ! grep -w zombie "/mmsdk/crontabLog/checkZombie.log" &> /dev/null  ; then
        for pid in `ps -e -o pid,stat | grep -w Z | awk '{ print $1 }'`; do 
            j=0 
            for i  in `seq 10` ; do 
                if [ ! -e /proc/$pid ]  ; then
                    break ;  
                else
                    j=$(($j+1))
                    sleep 2 ;  
                fi  
            done
            if [ $j == 10 ] ; then
                echo "zombie founded in ${IP_ADDR} :" >> $TFILE
                echo "zombie founded in ${IP_ADDR} :" >> /mmsdk/crontabLog/checkZombie.log
                ps -p $pid -o pid,stat,cmd | tail -n1 >> $TFILE
                ps -p $pid -o pid,stat,cmd | tail -n1 >> /mmsdk/crontabLog/checkZombie.log
            fi  
        done
    fi
}	# ----------  end of function checkZombieProcess  ----------


checkStorageMultipath ()
{
    sudo /sbin/multipath -ll|grep -qP "fault|fail|inactive" && echo "multipath error" >> $TFILE 
}


checkRouter ()
{
    #if ! nc -nz 10.101.13.1 80 &>/dev/null ; then
    if ! nc -nz 10.101.13.1 80 &>/dev/null ; then
        echo -n "tracing route start at " >> /mmsdk/crontabLog/checkRouter.log
        date +"%F %T" >> /mmsdk/crontabLog/checkRouter.log 
        echo "tracepath to 10.101.13.1" >> /mmsdk/crontabLog/checkRouter.log
        /bin/tracepath -n 10.101.13.1 >> /mmsdk/crontabLog/checkRouter.log 
        echo "tracepath to 192.168.63.20" >> /mmsdk/crontabLog/checkRouter.log
        /bin/tracepath -n 192.168.63.20 >> /mmsdk/crontabLog/checkRouter.log 
        echo "bond0 info" >> /mmsdk/crontabLog/checkRouter.log
        cat /proc/net/bonding/bond0 | sed -n '/./p' >> /mmsdk/crontabLog/checkRouter.log
        echo -e "tracing route end\n">> /mmsdk/crontabLog/checkRouter.log 
    fi
}


checkFileStat
checkLoadAverage; 
checkSpace;
checkTomcat;
checkBondInterface;
checkZombieProcess;
checkStorageMultipath;
checkRouter;


if [ -r "$TFILE" ] ; then
    if [ "`cat $TFILE`" ] ; then
        errorMail
    fi
    rm $TFILE
fi
