#!/bin/bash - 
#===============================================================================
#
#          FILE: check_logfile_status.sh
# 
#         USAGE: ./check_logfile_status.sh 
# 
#   DESCRIPTION: 检查日志路径是否有更新，没有更新就进行报警
# 
#       OPTIONS: log PATH
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
#  ORGANIZATION: datlet.com
#       CREATED: 08/27/2019 09:50
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error


logPath="/tmp/"
letter="${logPath}/letter.txt"
fromUser='alarm@cks.com.hk'
#recipients="jay@cks.com.hk marvin@cks.com.hk gary.liu@cks.com.hk moqq@cks.com.hk"
recipients="moqq@cks.com.hk"


#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
function usage ()
{
        cat <<- EOT

  DESCRIPTION: to copy files from SourcePath to DestinationPath

  Usage :  ${0##/*/} -l log_location

  Options: 
  -l            logs directory location
  -m            module name
  -t            lag time(minutes)
  -h|help       Display this message

EOT
}    # ----------  end of function usage  ----------

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------
logLocation=
moduleName=
lagTime=

if [ "$#" -lt 2 ] ; then
      usage; exit 1 
fi

while getopts "l:h" opt
do
  case $opt in

    l     )  logLocation="$OPTARG" ;  ;;
    m     )  moduleName="$OPTARG" ;  ;;
    t     )  lagTime="$OPTARG" ;  ;;
    h|help     )  usage; exit 0   ;;

    \? )  echo -e "\n  Option does not exist : $OPTARG\n"
          usage; exit 1   ;;

  esac    # --- end of case ---
done
shift $(($OPTIND-1))


#-------------------------------------------------------------------------------
# main()
#-------------------------------------------------------------------------------

[ -r /etc/default/locale ] && . /etc/default/locale
[ -n "$LANG" ] && export LANG
logfile="${logPath:-/tmp}"/${DESCRIPTION}_${timestamp}.log
errlogfile="${logPath:-/tmp}"/${DESCRIPTION}_${timestamp}.err

sendErrorMail(){
	Subject="`basename \"$0\"`: ${moduleName}模块日志在${lagTime}分钟内未更新，请检查程序"
	Content="$ErrorMsg $@"
	echo -e "From: $fromUser\nTo: $recipients\nSubject: $Subject \nContent-Type: text/plain; charset=\"utf-8\" \n\n$Content"  | /usr/local/bin/msmtp $recipients
}


ErrorMsg=`find $log_location -type f -mmin -${lagTime} -print -quit`
[[ -n $ErrorMsg ]] && sendErrorMail
