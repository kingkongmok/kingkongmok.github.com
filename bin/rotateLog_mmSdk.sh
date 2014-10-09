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
MAILUSER='13725269365@139.com'


#-------------------------------------------------------------------------------
#  don't edit below
#-------------------------------------------------------------------------------

TFILE="/tmp/$(basename $0).$$.tmp"
LOG_LOCATION=`df | perl -lane 'print $F[-1] if /mmsdk/ && !/dev/'`
IP_ADDR=`/sbin/ip a | grep -oP "(?<=inet )\S+(?=\/.*bond)"`


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  rm_old_tomcatlog
#   DESCRIPTION:  删除多余3天的tomcatlog
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
rm_old_tomcatlog ()
{
    nice -n 19 find ${LOG_LOCATION}/tomcat_77* -type f -mtime +3 -exec rm "{}" \; 2>>$TFILE
    nice -n 19 find ${LOG_LOCATION}/tomcat_77* -type f -mmin +180 -name catalina.20* -exec rm "{}" \; 2>>$TFILE
}	# ----------  end of function rm_old_tomcatlog  ----------



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  gzip_old_tomcatlog
#   DESCRIPTION:  压缩log文件
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
gzip_old_tomcatlog ()
{
    nice -n 19 find ${LOG_LOCATION}/tomcat_77* -mmin +180 -type f -name \*\.log -exec gzip "{}" \; 2>>$TFILE
}	# ----------  end of function gzip_old_tomcatlog  ----------



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  rm_yesterday_mmlog
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
rm_yesterday_mmlog ()
{
    rm -r ${LOG_LOCATION}/mmlog_77*/*/`date -d"yesterday" +%Y%m%d` 2>>$TFILE
}	# ----------  end of function rm_yesterday_mmlog  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  errorMail
#   DESCRIPTION:  mail the $MAILUSER with $TFILE
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
errorMail ()
{
    echo "Subject: `hostname`_"$IP_ADDR"" | cat - $TFILE | /usr/sbin/sendmail -f kk_richinfo@163.com -t $MAILUSER -s smtp.163.com -u nicemail -xu kk_richinfo -xp 1q2w3e4r -m happy
}   # ----------  end of function errorMail  ----------



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  rm_weblog
#   DESCRIPTION:  remove weblog files
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
rm_weblog ()
{
    find ${LOG_LOCATION}/weblog_77*/*/* -type d -mtime +3 | xargs -i  nice -n 19 tar czf {}.tar {} --remove-files >> $TFILE
}	# ----------  end of function rm_weblog  ----------

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  tomcat_restart
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
tomcat_restart ()
{
    for i in 11 22 33 44 ; do /opt/mmSdk/sbin/tomcat_77${i}.sh restart ; done    
}	# ----------  end of function tomcat_restart  ----------


rm_old_tomcatlog
gzip_old_tomcatlog
rm_weblog
rm_yesterday_mmlog
if [ -x "$TFILE" ] ; then
    errorMail
    rm $TFILE
fi
#tomcat_restart

