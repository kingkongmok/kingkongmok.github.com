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


BACKUP_LOCATION=${BACKUP_LOCATION:-"/home/appBackup/`date +%F`"}
MODULES_ARRAY=( sms mms disk calendar bmail card file setting weather together mnote uec )

#-------------------------------------------------------------------------------
#  don't edit below
#-------------------------------------------------------------------------------

MODULE=

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
  -h|help       Display this message
  -v|version    Display script version
  -m|module     sms|mms|disk|calendar|bmail|card|file|
                setting|weather|together|mnote|uec

	EOT
}    # ----------  end of function usage  ----------

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------

while getopts ":hvm:" opt
do
  case $opt in

    h|help     )  usage; exit 0   ;;
    v|version  )  echo "$0 -- Version $ScriptVersion"; exit 0   ;;
    m|module       )   MODULE="$OPTARG" ;;   
    \? )  echo -e "\n  Option does not exist : $OPTARG\n"
          usage; exit 1   ;;

  esac    # --- end of case ---
done
shift $(($OPTIND-1))

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  setVariables
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
setVariables ()
{
    TOMCAT_HOST=
    MODULE_LOCATION="/home/appSys/smsRebuild/sbin/update/local_${MODULE}"
    CONFIG_LOCATION="/home/appSys/smsRebuild/sbin/update/local_${MODULE}"
    MODULE_DEST_LOCATION="${TOMCAT_HOST}":"${TOMCATLOCATION}"
    CONFIG_DEST_LOCATION="${TOMCAT_HOST}":"${TOMCATLOCATION}"
}	# ----------  end of function setVariables  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  updateModule
#   DESCRIPTION:  updateModule tomcat modules and config
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
updateModule ()
{
    for host in ${HOST_ARRAY[@]}; do
        ssh "$host" "rm -rf $TOMCAT_MODULE_LOCATION/WEB_INF"
        rsync -az "$TOMCAT_MODULE_LOCATION" "${host}":"$BACKUP_LOCATION"
        rsync -az "$TOMCAT_CONFIG_LOCATION" "${host}":"$BACKUP_LOCATION"
    done
}	# ----------  end of function updateModule  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  backupModule
#   DESCRIPTION:  backupModule tomcat modules and config
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
backupModule ()
{
    
    for host in ${HOST_ARRAY[@]}; do
        rsync -az "$TOMCAT_MODULE_LOCATION" "${host}":"$BACKUP_LOCATION"
        rsync -az "$TOMCAT_CONFIG_LOCATION" "${host}":"$BACKUP_LOCATION"
    done
}	# ----------  end of function backupModule  ----------

#backupModule && updateModule

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

containsElement "$MODULE" "${MODULES_ARRAY[@]}" ||   echo -e "\n  Modules does not exist \n"
containsElement "$MODULE" "${MODULES_ARRAY[@]}" || exit 34 



case $MODULE in
    sms)
        echo sms ;
        break ;
        ;;
    *)
        echo all;
        ;;
esac    # --- end of case ---
