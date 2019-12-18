#!/bin/bash -
#===============================================================================
#
#          FILE: checkBackup.sh
#
#         USAGE: ./checkBackup.sh
#
#   DESCRIPTION: 检查 /home/mysqlbackup/ 上的目录，查找如果没有更新文件则报警
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
#  ORGANIZATION: datlet.com
#       CREATED: 05/25/2016 16:20
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

#local_ip=`/sbin/ip ro | grep 'proto kernel' | awk '{print $9}' | tail -1`
local_ip=$1
fromUser='alarm@cks.com.hk'
recipients="panpa@cks.com.hk chenxp@cks.com.hk chenyh@cks.com.hk moqq@cks.com.hk yanggy@cks.com.hk liuw@qualitrip.cn"
#recipients="moqq@cks.com.hk"

sendErrorMail(){
	Subject="`basename \"$0\"`: some error occurred in oracle $local_ip"
	Content="$ErrorMsg $@"
	echo -e "From: $fromUser\nTo: $recipients\nSubject: $Subject \nContent-Type: text/plain; charset=\"utf-8\" \n\n$Content"  | /usr/local/bin/msmtp $recipients
}

ErrorMsg=`/root/bin/checkAlertLog_message.sh -i $local_ip`
[[ -n $ErrorMsg ]] && sendErrorMail
