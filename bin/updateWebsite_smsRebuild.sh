#!/bin/bash - 
#===============================================================================
#
#          FILE: updateWebsite_smsRebuild.sh
# 
#         USAGE: ./updateWebsite_smsRebuild.sh 
# 
#   DESCRIPTION: update smsRebuild modules & configs from 172.16.210.33.
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: SOURCE FILES should be put in ~/sbin/update/local_$modulename.
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 09/19/2014 03:26:44 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
[ -r /etc/default/locale ] && . /etc/default/locale
[ -n "$LANG" ] && export LANG


#MODULES_ARRAY=( sms mms disk calendar bmail card file setting weather together mnote uec )
MODULES_ARRAY=( sms mms disk calendar bmail card setting weather together mnote uec )

#-------------------------------------------------------------------------------
#  don't edit below
#-------------------------------------------------------------------------------

TIMESTAMP="`date +%F_%T`"
BACKUP_LOCATION=${BACKUP_LOCATION:-"/home/appBackup/$TIMESTAMP"}
TFILE="/tmp/$(basename $0).$$.tmp"
#IP_ADDR=`/sbin/ip a | grep -oP "(?<=inet )\S+(?=\/.*bond)"`
IP_ADDR=`/bin/ip a | grep -oP "(?<=inet )\S+(?=\/.*bond)"`


MODULE=
REMOVE_WEBINF_TRIGER="1"
TEST_TRIGER=
RESTORE_TRIGER=

ScriptVersion="1.0"

#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
function usage ()
{
	cat <<- EOT

    Usage :  ${0##/*/} [options] [--] 

    Options: 
    -r|restore                  restore the modules and restart.
    -m|module                   sms|mms|disk|calendar|bmail|card|file?|
                                setting|weather|together|mnote|uec
    -w|NOT_REMOVE_WEBINF_TRIGER     Remove WEB_INF in module.
    -t|test                     See what will happen, echo only.
    -h|help                     Display this message
    -v|version                  Display script version

	EOT
}    # ----------  end of function usage  ----------

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------

while getopts "rwtm:hv" opt
do
  case $opt in
    r|restore      )   RESTORE_TRIGER="1" ;;   
    m|module       )   MODULE="$OPTARG" ;;   
    w|REMOVE_WEBINF_TRIGER )   REMOVE_WEBINF_TRIGER="0" ;;
    t|test )                   TEST_TRIGER="1" ;;
    h|help     )  usage; exit 0   ;;
    v|version  )  echo "$0 -- Version $ScriptVersion"; exit 0   ;;
    \? )  echo -e "\n  Option does not exist : $OPTARG\n"
          usage; exit 1   ;;

  esac    # --- end of case ---
done
shift $(($OPTIND-1))

[ "${TEST_TRIGER}" ] && ECHO="echo "
#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  setVariables
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
setVariables ()
{
    TOMCAT_MODULE_LOCATION="/home/appSys/smsRebuild/${TOMCAT_NAME}/webapps/${MODULE}"
    TOMCAT_CONFIG_LOCATION="/home/appSys/smsRebuild/AppConfig/${MODULE}cfg"
    LOCAL_TOMCAT_MODULE_LOCATION="/home/appSys/smsRebuild/sbin/update/local_${MODULE}/${MODULE}"
    LOCAL_TOMCAT_CONFIG_LOCATION="/home/appSys/smsRebuild/sbin/update/local_${MODULE}/${MODULE}cfg"
}	# ----------  end of function setVariables  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  updateModule
#   DESCRIPTION:  updateModule tomcat modules 
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
updateModule ()
{
    for host in ${HOST_ARRAY[@]}; do
        if [ "${REMOVE_WEBINF_TRIGER}" ] ; then
            if [ -d "${LOCAL_TOMCAT_MODULE_LOCATION}/WEB_INF" ] ; then
                $ECHO rsync --delete -az "${LOCAL_TOMCAT_MODULE_LOCATION}/WEB_INF" "${host}":"${TOMCAT_MODULE_LOCATION}/"
            else
                echo "${LOCAL_TOMCAT_MODULE_LOCATION}/WEB_INF" not exits
                exit 56
            fi
        fi
        $ECHO rsync -az "${LOCAL_TOMCAT_MODULE_LOCATION}/" "${host}":"${TOMCAT_MODULE_LOCATION}/"
    done
}	# ----------  end of function updateModule  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  updateConfig
#   DESCRIPTION:  update tomcat config
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
updateConfig ()
{
    for host in ${HOST_ARRAY[@]}; do
        $ECHO rsync -az "${LOCAL_TOMCAT_CONFIG_LOCATION}/" "${host}":"${TOMCAT_CONFIG_LOCATION}/"
    done
}	# ----------  end of function updateConfig  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  backupModule
#   DESCRIPTION:  backupModule tomcat modules and config
#   PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
backupModule ()
{
    
    for host in ${HOST_ARRAY[@]}; do
        $ECHO ssh $host rsync -a "$TOMCAT_MODULE_LOCATION" "$BACKUP_LOCATION"
    done
}	# ----------  end of function backupModule  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  backupConfig
#   DESCRIPTION:  backup tomcat config
#   PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
backupConfig ()
{
    
    for host in ${HOST_ARRAY[@]}; do
        $ECHO ssh $host rsync -a "$TOMCAT_CONFIG_LOCATION" "$BACKUP_LOCATION"
    done
}	# ----------  end of function backupConfig  ----------

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  restoreModulesConfig
#   DESCRIPTION:  restore from backup files
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
restoreModulesConfig ()
{
   
    $ECHO ssh $host rsync -a "$TOMCAT_MODULE_LOCATION" "$BACKUP_LOCATION"
    $ECHO ssh $host rsync -a "$TOMCAT_CONFIG_LOCATION" "$BACKUP_LOCATION"
}	# ----------  end of function restoreModulesConfig  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  restartTomcat
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
restartTomcat ()
{
    for host in ${HOST_ARRAY[@]}; do
        $ECHO ssh $host /home/appSys/smsRebuild/sbin/${TOMCAT_SCRIPT_NAME} restart
    done
}	# ----------  end of function restartTomcat  ----------

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  containsElement
#   DESCRIPTION:  search string is the first argument and the rest are the array elements
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
containsElement () {
    local e
    for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
    return 1
}

containsElement "$MODULE" "${MODULES_ARRAY[@]}" || echo -e "\n  Modules does not exist \n"
containsElement "$MODULE" "${MODULES_ARRAY[@]}" || exit 34 

case $MODULE in
    sms)
        HOST_ARRAY=(172.16.210.52 172.16.210.53 172.16.210.54) ;
        TOMCAT_NAME="tomcat_7.0.20_A";
        TOMCAT_SCRIPT_NAME="tomcat_sms_mms_card.sh";
        ;;
    mms)
        HOST_ARRAY=(172.16.210.52 172.16.210.53 172.16.210.54) ;
        TOMCAT_NAME="tomcat_7.0.20_A";
        TOMCAT_SCRIPT_NAME="tomcat_sms_mms_card.sh";
        ;;
    card)
        HOST_ARRAY=(172.16.210.52 172.16.210.53 172.16.210.54) ;
        TOMCAT_NAME="tomcat_7.0.20_A";
        TOMCAT_SCRIPT_NAME="tomcat_sms_mms_card.sh";
        ;;
    disk)
        HOST_ARRAY=(172.16.210.52 172.16.210.53 172.16.210.54) ;
        TOMCAT_NAME="tomcat_7.0.20_B";
        TOMCAT_SCRIPT_NAME="tomcat_disk_bmail_calendar.sh";
        ;;
    bmail)
        HOST_ARRAY=(172.16.210.52 172.16.210.53 172.16.210.54) ;
        TOMCAT_NAME="tomcat_7.0.20_B";
        TOMCAT_SCRIPT_NAME="tomcat_disk_bmail_calendar.sh";
        ;;
    calendar)
        HOST_ARRAY=(172.16.210.52 172.16.210.53 172.16.210.54) ;
        TOMCAT_NAME="tomcat_7.0.20_B";
        TOMCAT_SCRIPT_NAME="tomcat_disk_bmail_calendar.sh";
        ;;
#    file)
#        HOST_ARRAY=(172.16.210.52 172.16.210.53 172.16.210.54) ;
#        TOMCAT_NAME="tomcat_7.0.20_A";
#        TOMCAT_SCRIPT_NAME="tomcat_sms_mms_card.sh";
#        ;;
    setting)
        HOST_ARRAY=(172.16.200.2 172.16.200.8 172.16.200.9) ;
        TOMCAT_NAME="tomcat_7.0.20_C";
        TOMCAT_SCRIPT_NAME="tomcat_setting_together.sh";
        ;;
    together)
        HOST_ARRAY=(172.16.200.2 172.16.200.8 172.16.200.9) ;
        TOMCAT_NAME="tomcat_7.0.20_C";
        TOMCAT_SCRIPT_NAME="tomcat_setting_together.sh";
        ;;
    mnote)
        HOST_ARRAY=(172.16.200.2 172.16.200.8 172.16.200.9) ;
        TOMCAT_NAME="tomcat_7.0.20_D";
        TOMCAT_SCRIPT_NAME="tomcat_mnote_uec.sh";
        ;;
    uec)
        HOST_ARRAY=(172.16.200.2 172.16.200.8 172.16.200.9) ;
        TOMCAT_NAME="tomcat_7.0.20_D";
        TOMCAT_SCRIPT_NAME="tomcat_mnote_uec.sh";
        ;;
    weather)
        HOST_ARRAY=(172.16.200.2 172.16.200.8 172.16.200.9) ;
        TOMCAT_NAME="tomcat_7.0.20_E";
        TOMCAT_SCRIPT_NAME="tomcat_weather.sh";
        ;;
    *)
        echo all;
        ;;
esac    # --- end of case ---


# actions
if [ "$RESTORE_TRIGER" ] ; then
    setVariables
    restoreModulesConfig ;
else
    setVariables
    if [ -d "$LOCAL_TOMCAT_MODULE_LOCATION" ]  ; then
        backupModule && updateModule
    fi
    if [ -d "$LOCAL_TOMCAT_CONFIG_LOCATION" ] ; then
        backupConfig && updateConfig
    fi
    restartTomcat
fi
