#!/bin/bash -
#===============================================================================
#
#          FILE: clamscan_daily.sh
#
#         USAGE: clamscan_daily.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
#  ORGANIZATION: datlet.com
#       CREATED: 06/22/2016 09:37
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

local_ip=`/sbin/ip ro | grep 'proto kernel' | awk '{print $9}' | tail -1`
fromUser='alarm@cks.com.hk'
recipients="moqq@cks.com.hk"
CLAMSCAN=/usr/local/clamav/bin/clamscan
LOGFILE="/usr/local/clamav/var/log/clamav/clamav-$(date +'%Y-%m-%d').log";


#-------------------------------------------------------------------------------
#  DO NOT EDIT BELOW
#  请勿修改以下内容
#-------------------------------------------------------------------------------

recordFile="/tmp/`basename $0`_output.txt"
IP_ADDR=`/sbin/ip a | grep -oP "(?<=inet )\S+(?=\/.*bond)"`


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  errorMail
#   DESCRIPTION:  mail the $MAILUSER with $recordFile
#    PARAMETERS:
#       RETURNS:
#-------------------------------------------------------------------------------
sendThisMail ()
{
    Subject="`basename \"$0\"` $local_ip error"
    Content="<html><body><pre>$ErrorMsg</pre><pre>$@</pre></body></html>"
    echo -e "From: $fromUser\nTo: $recipients\nSubject: $Subject \nContent-Type: text/html; charset=\"utf-8\" \n\n$Content"  | /usr/local/bin/msmtp $recipients


}   # ----------  end of function errorMail  ----------

$CLAMSCAN -ri /usr/local/bin /usr/bin /usr/local/sbin /usr/sbin /lib /lib64 /root/bin /root/.local/bin /home/*/.local/bin /home/*/bin >> "$LOGFILE";


ErrorMsg=`grep FOUND$ $LOGFILE`
[[ $ErrorMsg ]] && sendThisMail
