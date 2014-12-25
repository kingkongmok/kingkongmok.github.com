#!/bin/bash - 
#===============================================================================
#
#          FILE: check_mmSdk_status.sh
# 
#         USAGE: ./check_mmSdk_status.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 12/03/2014 03:54:19 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

TRUNCATETRIGGER=80
TRUNCATE_MINUTES=900
#-------------------------------------------------------------------------------
#  don't edit below
#-------------------------------------------------------------------------------

MOUNTPOINT=`df | perl -nae 'print "$F[-1]\n" if $F[-1] =~ /\/mmsdk/i'`
TIMESTAMP=`date +%F_%T`

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  recordSpaceUsage
#   DESCRIPTION:  记录当前mmsdk盘的使用百分比
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
recordSpaceUsage ()
{
    USAGE_PERCENT=`df | perl -lnae 'print $F[-2] if /\/mmsd/'`
    USAGE_PERCENT_INT=`df | perl -lnae 'print int($F[-2]) if /\/mmsd/'`
    echo $USAGE_PERCENT $TIMESTAMP >> ${MOUNTPOINT}/crontabLog/space_usage.log 2>&1
}	# ----------  end of function recordSpaceUsage  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  recordNginxStatus
#   DESCRIPTION:  记录当前的nginx status页面
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
recordNginxStatus ()
{
    NGINXSTAT=`curl 192.168.42.2:8090/nginxstatus/ -s | xargs`
    echo $NGINXSTAT $TIMESTAMP >> ${MOUNTPOINT}/crontabLog/nginx_status.log 2>&1
}	# ----------  end of function recordNginxStatus  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  removeTempLogs
#   DESCRIPTION:  当不够空间的时候，删除mmlog和gamelog，
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
removeTempLogs ()
{
    while [ "$USAGE_PERCENT_INT" -gt "$TRUNCATETRIGGER" -a "$TRUNCATE_MINUTES" -gt 600 ]  ; do
        nice -n 19 find ${MOUNTPOINT}/mmlog_77* -type f -mmin +${TRUNCATE_MINUTES} -exec rm -v "{}" \; >> ${MOUNTPOINT}/crontabLog/rm_mmlog.log 2>&1
        #nice -n 19 find ${MOUNTPOINT}/gamelog_77* -type f -mmin +${TRUNCATE_MINUTES} -exec rm -v "{}" \; >> ${MOUNTPOINT}/crontabLog/rm_mmlog.log 2>&1
        TRUNCATE_MINUTES=$((TRUNCATE_MINUTES-60))
    done
}	# ----------  end of function removeTempLogs  ----------

#-------------------------------------------------------------------------------
#  actions
#-------------------------------------------------------------------------------

recordSpaceUsage
recordNginxStatus
removeTempLogs
