#!/bin/sh

key="agent.alive"

zabbix_bin=/opt/zabbix/bin
zabbix_sbin=/opt/zabbix/sbin
zabbix_conf=/opt/zabbix/conf
config_file=$zabbix_conf/zabbix_agentd.conf

#dos2unix $config_file
port=`cat $config_file |grep -v "^#"|sed 's/
if [ -z "${port}" ];then
        port=10050
else
        port=`cat $config_file |grep -v "^#"|sed 's/
fi

proc_count=`ps -ef | grep zabbix_agentd | grep -v grep | wc -l`
conn_count=`netstat -an | grep $port | grep LISTEN | wc -l`
work_status=`$zabbix_bin/zabbix_get -s 127.0.0.1 -p $port -k agent.ping`

hostname_status=`cat $config_file |grep -v '^#'|sed 's/
if [ $hostname_status -eq 1 ];then
        host=`cat $config_file |grep -v '^#'|sed 's/
else
        host=`hostname`
fi

#if [ $proc_count -ge 1 ]&&[ $conn_count -ge 1 ]&&[ $work_status -eq 1 ];then
if [ $proc_count -ge 1 -a $conn_count -ge 1 -a $work_status -eq 1 ];then
        $zabbix_bin/zabbix_sender -c $zabbix_conf/zabbix_agentd.conf -s $host -k $key -o 1
else
        $zabbix_bin/zabbix_sender -c $zabbix_conf/zabbix_agentd.conf -s $host -k $key -o 0
fi