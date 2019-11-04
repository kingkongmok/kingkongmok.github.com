#!/bin/bash - 
#===============================================================================
#
#          FILE: checkAlertLog.sh
# 
#         USAGE: ./checkAlertLog.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
#  ORGANIZATION: datlet.com
#       CREATED: 01/30/2018 17:03
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error


#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
function usage ()
{
    cat <<- EOT

    DESCRIPTION: update gentoo

    Usage :  ${0##/*/} [-f]

    Options: 
    -i            Server IP
    -h|help       Display this message

EOT
}    # ----------  end of function usage  ----------

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------

while getopts "i:h" opt
do
    case $opt in

        i     )  IP="$OPTARG"  ;;
        h|help     )  usage; exit 0   ;;

        \? )  echo -e "\n  Option does not exist : $OPTARG\n"
            usage; exit 1   ;;

        esac    # --- end of case ---
    done
shift $(($OPTIND-1))

# loglocacation /mnt/172.16.70.31/alert.log

LOG=/mnt/"${IP}"/alert.log
LOGTAIL=/usr/local/bin/logtail
LOGTAIL_TMP=/tmp/alertlog_"${IP}".tmp

$LOGTAIL -o $LOGTAIL_TMP $LOG | grep -P "^ORA-" | grep -vP "ORA-00604|ORA-01031|ORA-01555|ORA-03113|ORA-03135"
