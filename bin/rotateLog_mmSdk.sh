#!/bin/bash - 
#===============================================================================
#
#          FILE: rotateLog_mmSdk.sh
# 
#         USAGE: ./rotateLog_mmSdk.sh 
# 
#   DESCRIPTION: 删除昨天的mmlog，删除3天以前的tomcatzip，压缩log文件
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 10/04/2014 01:21:16 AM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
[ -r /etc/default/locale ] && . /etc/default/locale
[ -n "$LANG" ] && export LANG

MAILUSER='13725269365@139.com'


#-------------------------------------------------------------------------------
#  don't edit below
#-------------------------------------------------------------------------------

TFILE="/tmp/$(basename $0).$$.tmp"
LOG_LOCATION=`df | perl -lane 'print $F[-1] if /mmsdk/ && !/dev/'`


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  rm_old_tomcatlog
#   DESCRIPTION:  删除多余3天的tomcatlog
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
rm_old_tomcatlog ()
{
    find ${LOG_LOCATION}/tomcat_77* -type f -mtime +3 -exec rm "{}" \; 2>$TFILE
}	# ----------  end of function rm_old_tomcatlog  ----------



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  gzip_old_tomcatlog
#   DESCRIPTION:  压缩log文件
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
gzip_old_tomcatlog ()
{
    find ${LOG_LOCATION}/tomcat_77* -type f ! -name \*\.gz -exec gzip "{}" \; 2>$TFILE
}	# ----------  end of function gzip_old_tomcatlog  ----------



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  rm_yesterday_mmlog
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
rm_yesterday_mmlog ()
{
    rm -r ${LOG_LOCATION}/mmlog_77*/*/`date -d"yesterday" +%Y%m%d` 2>$TFILE
}	# ----------  end of function rm_yesterday_mmlog  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  errorMail
#   DESCRIPTION:  mail the $MAILUSER with $TFILE
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
errorMail ()
{
    IP=${IP:-"/sbin/ip"}
    SENDMAIL=${SENDMAIL:-"/usr/sbin/sendmail"}
    CURL=${CURL:-"/usr/bin/curl"}
    PRIV_IP="${IP_ADDR:-`$IP -f inet addr | grep -oP "(?<=inet )\S+(?=\/.*global)"`}"
    AUTHORITY="-s smtp.163.com -xu kk_richinfo -xp 1q2w3e4r"
    SUBJECT="`hostname`_`basename $0`_${PRIV_IP}"
    MAIL_CONTENT=`cat "$TFILE"`;
    MAIL="Subject: $SUBJECT\n${MAIL_CONTENT:-"error"}"
    echo -e $MAIL | $SENDMAIL $AUTHORITY "$MAILUSER"
}   # ----------  end of function errorMail  ----------


rm_old_tomcatlog
gzip_old_tomcatlog
rm_yesterday_mmlog
errorMail
rm $TFILE
