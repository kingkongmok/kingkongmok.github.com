#!/bin/bash - 
#===============================================================================
#
#          FILE: updateWebsite_smsRebuild.sh
# 
#         USAGE: ./updateWebsite_smsRebuild.sh [options] -m <ModulesName>
# 
#   DESCRIPTION: 升级smsRebuild各个模块使用,请务必先使用-t参数来测试
#       OPTIONS: ---
#  REQUIREMENTS: 需在172.16.210.33运行
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: richinfo.cn
#       CREATED: 09/19/2014 03:26:44 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
[ -r /etc/default/locale ] && . /etc/default/locale
[ -n "$LANG" ] && export LANG



#-------------------------------------------------------------------------------
#  don't edit below
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
#  模块名称，可以添加删除，但须配合 case $MODULE in 处进行模块声明
#-------------------------------------------------------------------------------
MODULES_ARRAY=( sms mms disk calendar bmail card setting weather together mnote uec )


#-------------------------------------------------------------------------------
#  default values
#-------------------------------------------------------------------------------
MODULE=
REMOVE_WEBINF_TRIGER="1"
TEST_TRIGER=
RESTORE_TRIGER=
WEBINFO_TRIGER=
TOMCAT_RESTART_TRIGER=
CAL_TRIGER=
CAL_TOMCAT_RESTART_TRIGER=
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
    -r|restore     开启还原模式，还原最近的备份的状态
    -w|WEB-INF     同步前删除原WEB-INF文件夹
    -t|test        生成bash script，只做测试,不执行
    -c|cal_local   只针对calendar的，即升级定时服务，默认不执行
    -h|help        Display this message
    -v|version     Display script version

    ModuleName: 
                   sms|mms|disk|calendar|bmail|card|
                   setting|weather|together|mnote|uec

    使用示范：
    ${0##/*/} -t -m sms         #测试升级sms模块和config
    ${0##/*/} -t -r -m mms      #还原最近一次mms模块和config
    ${0##/*/} -m mms -w         #删除WEB-INF文档,进行sms模块和config的升级,
    ${0##/*/} -c -m calendar    #升级calendar模块和配置，并升级本地的定时服务

	EOT
}    # ----------  end of function usage  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  showerror
#   DESCRIPTION:  display mkdir messages.
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
showerror ()
{
    
	cat <<- EOT
       
    无法检测所需文件，如果是测试，请生成多个虚假文件夹，请勿在生产机上运行以下命令！
    for i in sms mms disk calendar bmail card setting weather together mnote uec; do mkdir -p /home/appSys/smsRebuild/sbin/update/{local_\${i}/\${i}/WEB-INF,local_\${i}/\${i}cfg}; mkdir -p /home/appBackup/`date +%Y%m%d%H%M%S`/\${i}{,cfg};  done

    删除上面的虚假文件夹，请勿在生产机上运行以下命令！
    find /home/appSys/ -type d -empty -delete && find /home/appBackup/ -type d -empty -delete

	EOT
    exit 77
}	# ----------  end of function showerror  ----------

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------

while getopts "wrtcm:hv" opt
do
  case $opt in
    r|restore      )   RESTORE_TRIGER="1" ;;   
    w|WEB-INF      )   WEBINFO_TRIGER="1" ;;   
    m|module       )   MODULE=$OPTARG ;;   
    t|test         )   TEST_TRIGER="1" ;;
    c|cal_local    )   CAL_TRIGER="1" ;;
    h|help     )  usage; showerror   ;;
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
    RESTORE_LOCATION="/home/appBackup/`ls /home/appBackup/ -tr|tail -n1`"
    #
    TOMCAT_MODULE_LOCATION="/home/appSys/smsRebuild/${TOMCAT_NAME}/webapps/${MODULE}"
    TOMCAT_CONFIG_LOCATION="/home/appSys/smsRebuild/AppConfig/${MODULE}cfg"
    LOCAL_TOMCAT_MODULE_LOCATION="/home/appSys/smsRebuild/sbin/update/local_${MODULE}/${MODULE}"
    LOCAL_TOMCAT_CONFIG_LOCATION="/home/appSys/smsRebuild/sbin/update/local_${MODULE}/${MODULE}cfg"
    RESTORE_BAKCUP_MODULE_LOCATION="${RESTORE_LOCATION}/${MODULE}"
    RESTORE_BAKCUP_CONFIG_LOCATION="${RESTORE_LOCATION}/${MODULE}cfg"
    RESTORE_TOMCAT_MODULE_LOCATION="/home/appSys/smsRebuild/${TOMCAT_NAME}/webapps/"
    RESTORE_TOMCAT_CONFIG_LOCATION="/home/appSys/smsRebuild/AppConfig/"
}	# ----------  end of function setVariables  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  cal_setVariables
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
cal_setVariables ()
{
    CAL_TOMCAT_MODULE_LOCATION="/home/appSys/smsRebuild/${CAL_TOMCAT_NAME}/webapps/${CAL_MODULE}"
    CAL_RESTORE_TOMCAT_MODULE_LOCATION="/home/appSys/smsRebuild/${CAL_TOMCAT_NAME}/webapps/${CAL_MODULE}"
    CAL_RESTORE_BAKCUP_MODULE_LOCATION="${RESTORE_LOCATION}/${CAL_MODULE}"
    CAL_RESTORE_BAKCUP_CONFIG_LOCATION="${RESTORE_LOCATION}/${CAL_MODULE}cfg"
}	# ----------  end of function cal_setVariables  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  updateModule
#   DESCRIPTION:  updateModule tomcat modules 
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
updateModule ()
{
    echo -e "\n#updating the ${MODULE} modules."
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
    echo -e "\n#updating the ${MODULE} WEB-INF folder."
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
    echo -e "\n#updating the ${MODULE} configs."
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
    echo -e "\n#backuping the ${MODULE} modules."
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
    echo -e "\n#backuping the ${MODULE} configs."
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
    echo -e "\n#restoring the ${MODULE} modules."
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
    echo -e "\n#restoring the ${MODULE} configs."
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
        echo -e "\n#restarting the tomcat."
        for host in ${HOST_ARRAY[@]}; do
            $ECHO ssh $host /home/appSys/smsRebuild/sbin/${TOMCAT_SCRIPT_NAME} restart
        done
    fi
}	# ----------  end of function restartTomcat  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  cal_updateModule
#   DESCRIPTION:  cal_updateModule tomcat modules 
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
cal_updateModule ()
{
    echo -e "\n#updating the local ${MODULE} modules."
    $ECHO rsync -az "${LOCAL_TOMCAT_MODULE_LOCATION}/" "${CAL_TOMCAT_MODULE_LOCATION}/" 
    CAL_TOMCAT_RESTART_TRIGER=1
}	# ----------  end of function cal_updateModule  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  cal_updateWebInf
#   DESCRIPTION:  delete the old WEB-INF folder and copy the new one.
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
cal_updateWebInf ()
{
    echo -e "\n#updating the local ${MODULE} WEB-INF folder."
    $ECHO rsync --delete -az "${LOCAL_TOMCAT_MODULE_LOCATION}/WEB-INF" "${CAL_TOMCAT_MODULE_LOCATION}/"
    CAL_TOMCAT_RESTART_TRIGER=1
}	# ----------  end of function cal_updateWebInf  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  cal_updateConfig
#   DESCRIPTION:  update tomcat config
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
cal_updateConfig ()
{
    echo -e "\n#updating the local ${MODULE} configs."
    $ECHO rsync -az "${LOCAL_TOMCAT_CONFIG_LOCATION}/" "${TOMCAT_CONFIG_LOCATION}/"
    CAL_TOMCAT_RESTART_TRIGER=1
}	# ----------  end of function cal_updateConfig  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  cal_backupModule
#   DESCRIPTION:  cal_backupModule tomcat modules and config
#   PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
cal_backupModule ()
{
    echo -e "\n#backuping the local ${MODULE} modules."
    $ECHO mkdir -p "$BACKUP_LOCATION"
    $ECHO rsync -a "$CAL_TOMCAT_MODULE_LOCATION" "$BACKUP_LOCATION"/
}	# ----------  end of function cal_backupModule  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  cal_backupConfig
#   DESCRIPTION:  backup tomcat config
#   PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
cal_backupConfig ()
{
    echo -e "\n#backuping the local ${MODULE} configs."
    $ECHO mkdir -p "$BACKUP_LOCATION"
    $ECHO rsync -a "$TOMCAT_CONFIG_LOCATION" "$BACKUP_LOCATION"/
}	# ----------  end of function cal_backupConfig  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  cal_restoreModules
#   DESCRIPTION:  restore from backup files
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
cal_restoreModules ()
{
    echo -e "\n#restoring the local ${MODULE} modules."
    $ECHO rsync -a "${CAL_RESTORE_BAKCUP_MODULE_LOCATION}/" "${CAL_RESTORE_TOMCAT_MODULE_LOCATION}/"
    CAL_TOMCAT_RESTART_TRIGER=1
}	# ----------  end of function cal_restoreModules  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  cal_restoreConfig
#   DESCRIPTION:  restore from backup files
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
cal_restoreConfig ()
{
    echo -e "\n#restoring the local ${MODULE} configs."
    $ECHO rsync -a "$RESTORE_BAKCUP_CONFIG_LOCATION" "$RESTORE_TOMCAT_CONFIG_LOCATION"
    TOMCAT_RESTART_TRIGER=1
}	# ----------  end of function cal_restoreConfig  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  cal_restartTomcat
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
cal_restartTomcat ()
{
    if [ "$CAL_TOMCAT_RESTART_TRIGER" ] ; then
        echo -e "\n#restarting the local tomcat."
        $ECHO /home/appSys/smsRebuild/sbin/${CAL_TOMCAT_SCRIPT_NAME} restart
    fi
}	# ----------  end of function cal_restartTomcat  ----------


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
        CAL_MODULE="calendarTimer";
        HOST_ARRAY=(172.16.210.52 172.16.210.53 172.16.210.54) ;
        TOMCAT_NAME="tomcat_7.0.20_B";
        CAL_TOMCAT_NAME="tomcat_7.0.20";
        TOMCAT_SCRIPT_NAME="tomcat_disk_bmail_calendar.sh";
        CAL_TOMCAT_SCRIPT_NAME="tomcat_calendarTimer.sh"
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


if [ ! -d "/home/appBackup/" ] ; then
    if [ ! -d "/home/appSys/" ] ; then
        showerror
    fi
fi

# actions
if [ "$RESTORE_TRIGER" ] ; then
    if [ -d "$RESTORE_BAKCUP_MODULE_LOCATION" ]  ; then
        restoreModules
    else
        echo -e "\n#${MODULE} backup_modules not found."
    fi
    if [ -d "$RESTORE_BAKCUP_CONFIG_LOCATION" ] ; then
        restoreConfig
    else
        echo -e "\n#${MODULE} backup_configs not found."
    fi
    restartTomcat
else
    if [ -d "$LOCAL_TOMCAT_MODULE_LOCATION" ]  ; then
        backupModule 
        if [ "$WEBINFO_TRIGER" ] ; then
            if [ -d "${LOCAL_TOMCAT_MODULE_LOCATION}/WEB-INF" ] ; then
                updateWebInf
            fi
        fi
        updateModule
    else
        echo -e "\n#${MODULE} modules not found."
    fi

    if [ -d "$LOCAL_TOMCAT_CONFIG_LOCATION" ] ; then
        backupConfig && updateConfig
    else
        echo -e "\n#${MODULE} configs not found."
    fi
    restartTomcat
fi

# if modulesname is calendar
if [ "$CAL_TRIGER" ]  ; then
    if [ "$MODULE" == "calendar" ] ; then
        cal_setVariables ;
        if [ "$RESTORE_TRIGER" ] ; then
            if [ -d "$RESTORE_BAKCUP_MODULE_LOCATION" ]  ; then
                cal_restoreModules
            else
                echo -e "\n#${MODULE} cal_backup_modules not found."
            fi
            if [ -d "$RESTORE_BAKCUP_CONFIG_LOCATION" ] ; then
                cal_restoreConfig
            else
                echo -e "\n#${MODULE} cal_backup_configs not found."
            fi
            cal_restartTomcat
        else
            if [ -d "$LOCAL_TOMCAT_MODULE_LOCATION" ]  ; then
                cal_backupModule 
                if [ "$WEBINFO_TRIGER" ] ; then
                    if [ -d "${LOCAL_TOMCAT_MODULE_LOCATION}/WEB-INF" ] ; then
                        cal_updateWebInf
                    fi
                fi
                cal_updateModule
            else
                echo -e "\n#${MODULE} cal_modules not found."
            fi
            if [ -d "$LOCAL_TOMCAT_CONFIG_LOCATION" ] ; then
                cal_backupConfig && cal_updateConfig
            else
                echo -e "\n#${MODULE} cal_configs not found."
            fi
            cal_restartTomcat
        fi
    fi
fi
