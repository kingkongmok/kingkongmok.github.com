#!/bin/bash - 
#===============================================================================
#
#          FILE: accountlog.sh
# 
#         USAGE: put it in /etc/profile.d/
# 
#   DESCRIPTION:  log shell user histories.
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 05/30/2014 03:04:51 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

historyLog(){
    logDir=/data/accountlog
    dateStamp=`date +"[%F %T]"`
    dateDir="`date +%Y`/`date +%m`/`date +%d`"
    curHistory=`history 1`
    user=`/usr/bin/whoami`
    realUserInfor=`/usr/bin/who -u am i|awk '{print $1,$2,$3"~"$4,$7}'`
    
    if [ ! -e $logDir ];then
        mkdir -p $logDir
        chmod 777 $logDir
    fi
 
    logDateDir=$logDir/$dateDir
    if [ ! -e $logDateDir ];then
        mkdir -p $logDateDir
        chmod -R 777 $logDir 2>/dev/null
    fi 
 
    accountLogDir=$logDateDir/${user:=`hostname`}
    if [ ! -e $accountLogDir ];then
        mkdir -p $accountLogDir
        #chmod 777 $accountLogDir
    fi
 
    accountLogName=${user:=`hostname`}.his
    accountLog=$accountLogDir/$accountLogName
    if [ ! -e "$accountLog" ];then
        touch $accountLog
        #chmod 777 $accountLog
    fi
    echo "$realUserInfor $dateStamp =>$curHistory" >>$accountLog
}
export PROMPT_COMMAND=historyLog
 
