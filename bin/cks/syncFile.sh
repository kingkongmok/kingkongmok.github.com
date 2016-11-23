#!/bin/bash - 
#===============================================================================
#
#          FILE: syncFile.sh
# 
#         USAGE: ./syncFile.sh 
# 
#   DESCRIPTION: to sync files from SourcePath to DestinationPath
# 
#       OPTIONS: -s SourcePath 
#                -d DestinationPath
#                -e DESCRIPTION
#  REQUIREMENTS: /usr/bin/rsync
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
#  ORGANIZATION: datlet.com
#       CREATED: 10/20/2016 09:36
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

logPath="/mnt/172.16.45.200/logs"
letter="${logPath}/letter.txt"
fromUser='alarm@cks.com.hk'
recipients="jay@cks.com.hk marvin@cks.com.hk gary.liu@cks.com.hk moqq@cks.com.hk"


#-------------------------------------------------------------------------------
# don't edit below
#-------------------------------------------------------------------------------

local_ip=`/sbin/ip ro | grep 'proto kernel' | awk '{print $9}' | tail -1`
timestamp=`date +"%Y%m%d%H%M%S"`
scriptName=`basename "$0"`


#===  FUNCTION  ================================================================
#         NAME:  sendEmail
#  DESCRIPTION:  send email to recipients which the errlogfile
#===============================================================================
sendEmail(){
        Subject="$DESCRIPTION $scriptName $local_ip backup finished"
        Content="`cat $@`"
        echo -e "From: $fromUser\nTo: $recipients\nSubject: $Subject \nContent-Type: text/plain; charset=\"utf-8\" \n\n$Content"  | /usr/local/bin/msmtp $recipients
}


#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
function usage ()
{
        cat <<- EOT

  DESCRIPTION: to copy files from SourcePath to DestinationPath

  Usage :  ${0##/*/} -s SourcePath -d DestinationPath -e DESCRIPTION

  Options: 
  -s            set Source path
  -d            set Destination path
  -r            remove old tigger
  -x            exclude path
  -e            DESCRIPTION
  -h|help       Display this message

EOT
}    # ----------  end of function usage  ----------

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------
SourcePath=
DestinationPath=
DESCRIPTION=
DELETE=
EXCLUDE=

if [ "$#" -lt 6 ] ; then
      usage; exit 1 
fi

while getopts "s:d:e:rx:h" opt
do
  case $opt in

    s     )  SourcePath="$OPTARG" ;  ;;
    d     )  DestinationPath="$OPTARG" ;  ;;
    e     )  DESCRIPTION="$OPTARG" ;  ;;
    r     )  DELETE="--delete" ;  ;;
    x     )  EXCLUDE="--exclude $OPTARG" ;  ;;
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

if [[ -z $DestinationPath && -z $SourcePath && -z $DESCRIPTION ]] ; then
          usage; exit 1   
fi

mount -a || exit 26

/usr/bin/rsync -avihP $DELETE $EXCLUDE "$SourcePath" "$DestinationPath" > $logfile 2> $errlogfile


IfModify=`find $DestinationPath -type f -mtime -1 -print -quit`
if [ -z "$IfModify" ] ; then
    echo "没有能找到在昨天更新的文件，请登陆 $local_ip 检查 $logfile" > $letter
fi

if [ -s $letter ] ; then
    sendEmail $letter && rm $letter
fi

if [ -w $errlogfile ]; then
    /bin/gzip $errlogfile
fi
if [ -w $logfile ]; then
    /bin/gzip $logfile
fi
