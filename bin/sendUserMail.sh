#!/bin/bash - 
#===============================================================================
#
#          FILE: sendUserMail.sh
# 
#         USAGE: ./sendUserMail.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 02/02/2015 02:41:31 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
MAILLIST=""

MUTT="/usr/local/bin/mutt"
LOGLOCATION="/home/operator/moqingqiang/bin/logAnalyzeTemp"
DATETIME="today"
MODULENAME=""

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
  -l            set logAnalyzeTemp [L]ocation
  -d            wich [D]ate's file to send, yesterday as default
  -m            log Module. setting/calendar e.g.
  -h|help       Display this message
  -v|version    Display script version

	EOT
}    # ----------  end of function usage  ----------

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------

while getopts "m:l:d:u:hv" opt
do
  case $opt in

    h|help     )  usage; exit 0   ;;
    l     )  LOGLOCATION="$OPTARG";   ;;
    d     )  DATETIME="$OPTARG";   ;;
    m     )  MODULENAME="$OPTARG";   ;;
    v|version  )  echo "$0 -- Version $ScriptVersion"; exit 0   ;;

    \? )  echo -e "\n  Option does not exist : $OPTARG\n"
          usage; exit 1   ;;

  esac    # --- end of case ---
done
shift $(($OPTIND-1))

if [ "$DATETIME" ] ; then
    NEWDATE=`date -d "$DATETIME" +%F`
    OLDDATE=`date -d "$DATETIME -7day" +%F`
else
    NEWDATE=`date -d "-1day" +%F`
    OLDDATE=`date -d "-8day" +%F`
fi

if [ -d "$LOGLOCATION" ]  ; then
    HTMLFILE=${LOGLOCATION}"/"${MODULENAME}"_logAnalyze_data_"${NEWDATE}".html"
    NEWTXTFILE=${LOGLOCATION}"/"${MODULENAME}"_logAnalyze_data_"${NEWDATE}".txt"
    OLDTXTFILE=${LOGLOCATION}"/"${MODULENAME}"_logAnalyze_data_"${OLDDATE}".txt"
    if [ -r "$HTMLFILE" ] ; then
        if [ -r "$OLDTXTFILE" ] ; then
            cat "$HTMLFILE" | "$MUTT" -s "${MODULENAME} logAnalyze" "$MAILLIST" -a "$NEWTXTFILE" "$OLDTXTFILE"
        else
            cat "$HTMLFILE" | "$MUTT" -s "${MODULENAME} logAnalyze" "$MAILLIST" -a "$NEWTXTFILE"
        fi
    fi
else
    echo Can NOT access log dir.
fi
