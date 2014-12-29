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
MAILUSER='moqingqiang@richinfo.cn'


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
    #nice find ${LOG_LOCATION}/tomcat_77* -type f -mtime +0 -delete
    nice find ${LOG_LOCATION}/tomcat_77* -type f -mmin +1600 -delete
    nice find ${LOG_LOCATION}/tomcat_77* -type f -mmin +60 -name catalina.20* -delete 
}	# ----------  end of function rm_old_tomcatlog  ----------



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  empty_catalina
#   DESCRIPTION:  empty the catalina.out
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
empty_catalina ()
{
    
    for i in 11 22 33 44 ; do
        if [ -w "${LOG_LOCATION}/tomcat_77${i}/catalina.out" ] ; then
            echo "" >  ${LOG_LOCATION}/tomcat_77${i}/catalina.out
        else
            echo "${LOG_LOCATION}/tomcat_77${i}/catalina.out" CAN NOT be flushed
        fi
    done
}	# ----------  end of function empty_catalina  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  gzip_old_tomcatlog
#   DESCRIPTION:  压缩log文件
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
gzip_old_tomcatlog ()
{
    nice find ${LOG_LOCATION}/tomcat_77* -mmin +60 -type f -name \*\.log -exec gzip "{}" \;
}	# ----------  end of function gzip_old_tomcatlog  ----------



#---  FUNCTION  ---------------------------------------------------------------- 
#          NAME:  remove mmlog
#   DESCRIPTION: /mmsdk/mmlog_77* 
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
rm_mmlog ()
{
    nice find ${LOG_LOCATION}/mmlog_77*/* -type f -mtime +0 -delete
    nice find ${LOG_LOCATION}/mmlog_77*/* -type d -mtime +0 -empty -delete
}	# ----------  end of function rm_mmlog  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  remove gamedatalog
#   DESCRIPTION:  /mmsdk/gamelog_77*
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
rm_gamelog ()
{
    nice find ${LOG_LOCATION}/gamelog_77*/* -type f -mtime +0 -delete
    nice find ${LOG_LOCATION}/gamelog_77*/* -type d -mtime +0 -empty -delete
}	# ----------  end of function rm_gamelog  ---------- 


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  errorMail
#   DESCRIPTION:  mail the $MAILUSER with $TFILE
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
errorMail ()
{
    echo -e "Subject: ${IP_ADDR}_`basename $0`\n" | cat - $TFILE | /usr/local/bin/msmtp $MAILUSER
}   # ----------  end of function errorMail  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  count_visits
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
count_visits ()
{
    #for i in seq -w 24 ; do zcat ${LOG_LOCATION}/tomcat_77*/access.`date -d -1day +%F`.${i}.log.gz ; done | perl -nae ' if(/(?<=\s)\S+?(?=&)/){$h{$&}++;$S++}}{printf"%12i\t%s\n",$h{$_},$_ for keys%h;printf"%12i\ttotal\n",$S' > ${LOG_LOCATION}/crontabLog/pv.`date -d -1day +%F`.log
    zcat ${LOG_LOCATION}/tomcat_77*/access.`date -d -1day +%F`.*.gz | perl -nae ' if(/(?<=\s)\S+?(?=&)/){$h{$&}++;$S++}}{printf"%12i\t%s\n",$h{$_},$_ for sort{$h{$a}<=>$h{$b}}keys%h;printf"%12i\ttotal\n",$S' > ${LOG_LOCATION}/crontabLog/pv.log
}	# ----------  end of function count_visits  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  rm_weblog
#   DESCRIPTION:  remove weblog files
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
rm_weblog ()
{
    find ${LOG_LOCATION}/weblog_77*/*/* -type d -mtime +2 -exec rm -rv "{}" \; 
}	# ----------  end of function rm_weblog  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  rm_crontab_log
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
rm_crontab_log ()
{
    nice /usr/sbin/logrotate -s /mmsdk/crontabLog/logrotate.stat.log -f /opt/mmSdk/sbin/logrotate.conf_logs 
}	# ----------  end of function rm_crontab_log  ----------


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


action() {
    rm_old_tomcatlog 
    gzip_old_tomcatlog 
    rm_gamelog 
    tomcat_restart 
    empty_catalina 
    count_visits
}

action >> ${LOG_LOCATION}/crontabLog/rotateLog_mmSdk.log 2>$TFILE
rm_weblog >> ${LOG_LOCATION}/crontabLog/rotateLog_mmSdk.log 2>/dev/null
rm_mmlog  >> ${LOG_LOCATION}/crontabLog/rotateLog_mmSdk.log 2>/dev/null
rm_crontab_log >> $TFILE 2>/dev/null

if [ -r "$TFILE" ] ; then
    errorMail
fi
if [ -w "$TFILE" ] ; then
    rm $TFILE
fi
