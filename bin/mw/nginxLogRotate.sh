#!/bin/bash - 
# nginx log rotate, run at 00:00 everyday.

# yesterday
dateFormate=$(date -d -1day +%F)
logLocation='/usr/local/nginx-1.9.4/logs'
pidFileLocation='/usr/local/nginx-1.9.4/logs/nginx.pid'
# logs backup to keep
backupNumb=90

if [ -w ${logLocation}/access.log ] ; then
    mv -f ${logLocation}/access.log ${logLocation}/access.log.$dateFormate
fi
if [ -w ${logLocation}/error.log ] ; then
    mv -f ${logLocation}/error.log ${logLocation}/error.log.$dateFormate
fi
kill -USR1 `cat "$pidFileLocation"`
sleep 1
gzip -f ${logLocation}/access.log.$dateFormate 
gzip -f ${logLocation}/error.log.$dateFormate
find ${logLocation} -name \*log*gz -type f -mtime +${backupNumb} -delete
