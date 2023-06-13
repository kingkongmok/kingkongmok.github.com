#!/bin/bash - 

# =======
# 脚本说明
# 检测各个offset checkport文件，如果相关topic的数量无变化则报警。
# 检测zookeeper的zookeeper.out是否有更新
# =======

#mail_user="moqingqiang@richinfo.cn fengxy@richinfo.cn"
mail_user="moqingqiang@richinfo.cn"
local_ip=`/sbin/ip ro | grep 'proto kernel' | awk '{print $9}' | tail -1`
#ErrorMsg="some logs is NOT changed in last 5min, please check\n"
ErrorMsg="以下日志在5分钟内没更新，请查看kafka和zookeeper以下log日志的相关进程\n"

zooKeeperFileList="/home/logs/zookeeper/zookeeper.out"

file_list="\
/home/logs/kafka/kafka-logs-0/replication-offset-checkpoint \
/home/logs/kafka/kafka-logs-1/replication-offset-checkpoint \
/home/logs/kafka/kafka-logs-2/replication-offset-checkpoint"


####

sendErrorMail(){
	Subject="`basename \"$0\"` $local_ip error"
	Content="$ErrorMsg $@"
	echo -e "To: $mail_user\nSubject: $Subject \nContent-Type: text/plain; charset=\"utf-8\" \n\n$Content"  | /usr/local/bin/msmtp $notify_mail_addr $mail_user
}




# 计算kafka 的 复制是否正常
for logFile in $file_list; do
    NumbThisTime=`perl -nae '$s+=$F[-1] if /log_report_topic/ }{ print $s' $logFile`
    if [ -w ${logFile}.last ] ; then
        NumbLastTime=`cat ${logFile}.last`
        if [ $NumbThisTime -ne $NumbLastTime ] ; then
            echo "OK|offset_Changed"
            echo $NumbThisTime > ${logFile}.last
        else
            sendErrorMail $logFile
            echo "ERROR|replication-offset-checkpoint is NOT changed"
            echo $NumbThisTime > ${logFile}.last
            exit 1
        fi
    else
        echo $NumbThisTime > ${logFile}.last
    fi
done


# 检查 zookeeper的日志是否有更新
for logFileZK in $zooKeeperFileList ; do
    if [ "$(( $(date +"%s") - $(stat -c "%Y" $logFileZK ) ))" -gt "300" ]; then
	echo "ERROR|zookeeper's log is NOT changed"
	sendErrorMail $logFileZK
    else 
	echo "OK|zookeeper_Changed"
    fi
done
