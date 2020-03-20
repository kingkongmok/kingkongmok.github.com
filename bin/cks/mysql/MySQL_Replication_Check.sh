#!/bin/bash -
#===============================================================================
#
#          FILE: MySQL_Replication_Check.sh
#
#         USAGE: ./MySQL_Replication_Check.sh
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
fromUser='FROMMAIL@example.com'
recipients="toMail@example.com"


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

ErrorMsg=`/root/bin/MySQL_Replication_Check_message.sh`
[[ $ErrorMsg ]] && sendThisMail
