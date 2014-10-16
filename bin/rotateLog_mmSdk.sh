#!/bin/bash - 
#===============================================================================
#
#          FILE: rotateLog_mmSdk.sh
# 
#         USAGE: crontab like this:
# 2 2 * * *   /opt/mmSdk/sbin/rotateLog_mmSdk.sh > /mmsdk/crontabLog/rotateLog_mmSdk_`date +%F`.log 2>&1
# 
#   DESCRIPTION: 删除昨天的mmlog，删除1天以前的log，压缩log文件
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
#   DESCRIPTION:  删除多余1天的tomcatlog
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
rm_old_tomcatlog ()
{
    nice -n 19 find ${LOG_LOCATION}/tomcat_77* -type f -mtime +0 -exec rm -v "{}" \; 2>>$TFILE
    nice -n 19 find ${LOG_LOCATION}/tomcat_77* -type f -mmin +60 -name catalina.20* -exec rm -v "{}" \; 2>>$TFILE
    nice -n 19 find ${LOG_LOCATION}/tomcat_77* -type f -mmin +60 -name access*log -empty -exec rm -v "{}" \; 2>>$TFILE
}	# ----------  end of function rm_old_tomcatlog  ----------



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  empty_catalina.out
#   DESCRIPTION:  empty the catalina.out
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
empty_catalina.out ()
{
    for i in 11 22 33 44 ; do
        echo "" >  /mmsdk/tomcat_77${i}/catalina.out 2>>$TFILE
    done
}	# ----------  end of function empty_catalina.out  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  gzip_old_tomcatlog
#   DESCRIPTION:  压缩log文件
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
gzip_old_tomcatlog ()
{
    nice -n 19 find ${LOG_LOCATION}/tomcat_77* -mmin +60 -type f -name \*\.log -exec gzip -v "{}" \; >>$TFILE
}	# ----------  end of function gzip_old_tomcatlog  ----------



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  rm_yesterday_mmlog
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
rm_yesterday_mmlog ()
{
    rm -rv ${LOG_LOCATION}/mmlog_77*/*/`date -d"yesterday" +%Y%m%d` 2>>$TFILE
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
    find ${LOG_LOCATION}/weblog_77*/*/* -type d -mtime +2 -exec rm -rv "{}" \; 
    #find ${LOG_LOCATION}/weblog_77*/*/* -type d -mtime +3 | xargs -i  nice -n 19 tar czf {}.tar.gz {} --remove-files 
    #find ${LOG_LOCATION}/weblog_77*/*/* -type d -empty -exec rm "{}" \;
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
tomcat_restart
empty_catalina.out
if [ -r "$TFILE" ] ; then
    errorMail
fi
if [ -w "$TFILE" ] ; then
    rm $TFILE
fi
