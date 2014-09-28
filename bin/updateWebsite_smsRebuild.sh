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
#  REQUIREMENTS: 
#  需要相应的文件夹，可以新建用于测试： 新建所有需要的文件夹：
#   for i in sms mms disk calendar bmail card setting weather together mnote uec; do mkdir -p /home/appSys/smsRebuild/sbin/update/{local_${i}/${i}/WEB-INF,local_${i}/${i}cfg}; done ; mkdir /home/appBackup/
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


MODULES_ARRAY=( sms mms disk calendar bmail card setting weather together mnote uec )

#-------------------------------------------------------------------------------
#  don't edit below
#-------------------------------------------------------------------------------

MODULE=
REMOVE_WEBINF_TRIGER="1"
TEST_TRIGER=
RESTORE_TRIGER=
TOMCAT_RESTART_TRIGER=
ScriptVersion="1.0"


#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
function usage ()
{
	cat <<- EOT

    Usage :  ${0##/*/} [options] -m <ModulesName>

    Options: 
    -r|restore                  还原最近的备份的状态
    -m|module                   sms|mms|disk|calendar|bmail|card|file?|
                                setting|weather|together|mnote|uec
    -t|test                     生成bash script，观察运行的情况
    -h|help                     Display this message
    -v|version                  Display script version

    使用示范：
    ${0##/*/} -t -m sms      #测试升级sms模块，如果包含smscfg文件夹并升级config设置
    ${0##/*/} -t -r -m sms   #还原最近一次sms模块和config设置
    ${0##/*/} -m sms         #进行sms模块的升级

	EOT
}    # ----------  end of function usage  ----------


#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------

while getopts "rtm:hv" opt
do
  case $opt in
    r|restore      )   RESTORE_TRIGER="1" ;;   
    m|module       )   MODULE="$OPTARG" ;;   
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
    #TIMESTAMP="`date +%F`"
    TIMESTAMP="`date +%Y%m%d%H%M%S`"
    BACKUP_LOCATION=${BACKUP_LOCATION:-"/home/appBackup/$TIMESTAMP"}
    TFILE="/tmp/$(basename $0).$$.tmp"
    #IP_ADDR=`/sbin/ip a | grep -oP "(?<=inet )\S+(?=\/.*bond)"`
    IP_ADDR=`/bin/ip a | grep -oP "(?<=inet )\S+(?=\/.*bond)"`
    TOMCAT_MODULE_LOCATION="/home/appSys/smsRebuild/${TOMCAT_NAME}/webapps/${MODULE}"
    TOMCAT_CONFIG_LOCATION="/home/appSys/smsRebuild/AppConfig/${MODULE}cfg"
    LOCAL_TOMCAT_MODULE_LOCATION="/home/appSys/smsRebuild/sbin/update/local_${MODULE}/${MODULE}"
    LOCAL_TOMCAT_CONFIG_LOCATION="/home/appSys/smsRebuild/sbin/update/local_${MODULE}/${MODULE}cfg"
    RESTORE_LOCATION="/home/appBackup/`ls /home/appBackup/ -tr|tail -n1`"
    RESTORE_BAKCUP_MODULE_LOCATION="${RESTORE_LOCATION}/${MODULE}"
    RESTORE_BAKCUP_CONFIG_LOCATION="${RESTORE_LOCATION}/${MODULE}cfg"
    RESTORE_TOMCAT_MODULE_LOCATION="/home/appSys/smsRebuild/${TOMCAT_NAME}/webapps/"
    RESTORE_TOMCAT_CONFIG_LOCATION="/home/appSys/smsRebuild/AppConfig/"
}	# ----------  end of function setVariables  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  updateModule
#   DESCRIPTION:  updateModule tomcat modules 
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
updateModule ()
{
    echo -e "\n\n\t#updating the ${MODULE} modules.\n\n"
    for host in ${HOST_ARRAY[@]}; do
        $ECHO rsync -az "${LOCAL_TOMCAT_MODULE_LOCATION}/" "${host}":"${TOMCAT_MODULE_LOCATION}/" 
    done
    TOMCAT_RESTART_TRIGER=1
}	# ----------  end of function updateModule  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  updateWebInf
#   DESCRIPTION:  delete the old WEB-INF folder and copy the new one.
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
updateWebInf ()
{
    echo -e "\n\n\t#updating the ${MODULE} WEB-INF folder.\n\n"
    for host in ${HOST_ARRAY[@]}; do
        $ECHO rsync --delete -az "${LOCAL_TOMCAT_MODULE_LOCATION}/WEB-INF" "${host}":"${TOMCAT_MODULE_LOCATION}/"
    done
    TOMCAT_RESTART_TRIGER=1
}	# ----------  end of function updateWebInf  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  updateConfig
#   DESCRIPTION:  update tomcat config
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
updateConfig ()
{
    echo -e "\n\n\t#updating the ${MODULE} configs.\n\n"
    for host in ${HOST_ARRAY[@]}; do
        $ECHO rsync -az "${LOCAL_TOMCAT_CONFIG_LOCATION}/" "${host}":"${TOMCAT_CONFIG_LOCATION}/"
    done
    TOMCAT_RESTART_TRIGER=1
}	# ----------  end of function updateConfig  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  backupModule
#   DESCRIPTION:  backupModule tomcat modules and config
#   PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
backupModule ()
{
    echo -e "\n\n\t#backuping the ${MODULE} modules.\n\n"
    for host in ${HOST_ARRAY[@]}; do
        $ECHO ssh $host mkdir -p "$BACKUP_LOCATION"
        $ECHO ssh $host rsync -a "$TOMCAT_MODULE_LOCATION" "$BACKUP_LOCATION"/
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
    echo -e "\n\n\t#backuping the ${MODULE} configs.\n\n"
    for host in ${HOST_ARRAY[@]}; do
        $ECHO ssh $host mkdir -p "$BACKUP_LOCATION"
        $ECHO ssh $host rsync -a "$TOMCAT_CONFIG_LOCATION" "$BACKUP_LOCATION"/
    done
}	# ----------  end of function backupConfig  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  restoreModules
#   DESCRIPTION:  restore from backup files
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
restoreModules ()
{
    echo -e "\n\n\t#restoring the ${MODULE} modules.\n\n"
    for host in ${HOST_ARRAY[@]}; do
        $ECHO ssh $host rsync -a "$RESTORE_BAKCUP_MODULE_LOCATION" "$RESTORE_TOMCAT_MODULE_LOCATION"
    done
    TOMCAT_RESTART_TRIGER=1
}	# ----------  end of function restoreModules  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  restoreConfig
#   DESCRIPTION:  restore from backup files
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
restoreConfig ()
{
    echo -e "\n\n\t#restoring the ${MODULE} configs.\n\n"
    for host in ${HOST_ARRAY[@]}; do
        $ECHO ssh $host rsync -a "$RESTORE_BAKCUP_CONFIG_LOCATION" "$RESTORE_TOMCAT_CONFIG_LOCATION"
    done
    TOMCAT_RESTART_TRIGER=1
}	# ----------  end of function restoreConfig  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  restartTomcat
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
restartTomcat ()
{
    if [ "$TOMCAT_RESTART_TRIGER" ] ; then
        echo -e "\n\n\t#restarting the tomcat.\n\n"
        for host in ${HOST_ARRAY[@]}; do
            $ECHO ssh $host /home/appSys/smsRebuild/sbin/${TOMCAT_SCRIPT_NAME} restart
        done
    fi
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


containsElement "$MODULE" "${MODULES_ARRAY[@]}" || ( echo -e "\n  Modules does not exist \n" && exit 63 )


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
        echo "Module $MODULE is not found" && usage && exit 64;
        ;;
esac    # --- end of case ---


setVariables


# actions
if [ "$RESTORE_TRIGER" ] ; then
    if [ -d "$RESTORE_BAKCUP_MODULE_LOCATION" ]  ; then
        restoreModules
    else
        echo -e "\n\n\t#${MODULE} backup_modules not found.\n\n"
    fi
    if [ -d "$RESTORE_BAKCUP_CONFIG_LOCATION" ] ; then
        restoreConfig
    else
        echo -e "\n\n\t#${MODULE} backup_configs not found.\n\n"
    fi
    restartTomcat
else
    if [ -d "$LOCAL_TOMCAT_MODULE_LOCATION" ]  ; then
        backupModule 
        if [ -d "${LOCAL_TOMCAT_MODULE_LOCATION}/WEB-INF" ] ; then
            updateWebInf
        fi
        updateModule
    else
        echo -e "\n\n\t#${MODULE} modules not found.\n\n"
    fi

    if [ -d "$LOCAL_TOMCAT_CONFIG_LOCATION" ] ; then
        backupConfig && updateConfig
    else
        echo -e "\n\n\t#${MODULE} configs not found.\n\n"
    fi
    restartTomcat
fi

