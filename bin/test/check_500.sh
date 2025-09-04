#!/bin/bash - 
#===============================================================================
#
#          FILE: check_500.sh
# 
#         USAGE: ./check_500.sh 
# 
#   DESCRIPTION: check tomcat accesslog for httpcode 50X
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
#  ORGANIZATION: datlet.com
#       CREATED: 07/18/2019 08:56
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error


# logtail

LOG=/xxx/localhost_access_log.`date +%F`.txt
LOGTAIL=/usr/local/bin/logtail
LOGTAIL_TMP="/tmp/`basename $0`.tail"



local_ip=`/sbin/ip ro | grep 'proto kernel' | grep -v docker | awk '{print $9}' | tail -1`
#local_ip=`/bin/ip ro | grep 'proto kernel' | grep -v docker | awk '{print $9}' | tail -1`
fromUser='from@email.com'
recipients="to@email.com"
ELK_URL='http://192.168.46.29:5601/goto/9afcf85ba510c0546c4d7b4709582317'

sendErrorMail(){
	Subject="API too much 50X error occurs"
	Content="$ErrorMsg $@"
	echo -e "From: $fromUser\nTo: $recipients\nSubject: $Subject \nContent-Type: text/plain; charset=\"utf-8\" \n\n$Content"  | /usr/local/bin/msmtp $recipients
}

$LOGTAIL -o $LOGTAIL_TMP $LOG > "/tmp/`basename $0`.cache"


if [ ! -s  "/tmp/`basename $0`.cache" ]  ; then
    ErrorMsg="时间段内 API 没有流量出现，请检查$(basename $0)" && sendErrorMail
    exit 23 ;
fi

SUCCESSRATE=`perl -naE '$countSum++ ; $countFail++ if $F[-3] > 499 }{ printf "%d", 100*$countFail/$countSum' "/tmp/$(basename $0).cache"`
[[ "$SUCCESSRATE" -gt 20 ]] &&  ErrorMsg="时间段内 API 较多50X异常出现，请检查 $ELK_URL " && sendErrorMail

