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

logPath=
fromUser='alarm@cks.com.hk'
recipients="moqq@cks.com.hk"
#recipients="jay@cks.com.hk gary.liu@cks.com.hk moqq@cks.com.hk"


#-------------------------------------------------------------------------------
# don't edit below
#-------------------------------------------------------------------------------

local_ip=`ip ro | grep 'proto kernel' | awk '{print $9}' | tail -1`
timestamp=`date +"%F_%T"`
scriptName=`basename "$0"`
logfile="${logPath:-/tmp}"/${scriptName}_${local_ip}_${timestamp}.log
errlogfile="${logPath:-/tmp}"/${scriptName}_${local_ip}_${timestamp}.err


#===  FUNCTION  ================================================================
#         NAME:  sendEmail
#  DESCRIPTION:  send email to recipients which the errlogfile
#===============================================================================
sendEmail(){
        Subject="$DESCRIPTION $scriptName $local_ip error"
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

if [ "$#" -lt 6 ] ; then
      usage; exit 1 
fi

while getopts "s:d:e:h" opt
do
  case $opt in

    s     )  SourcePath="$OPTARG" ;  ;;
    d     )  DestinationPath="$OPTARG" ;  ;;
    e     )  DESCRIPTION="$OPTARG" ;  ;;
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

if [[ -z $DestinationPath && -z $SourcePath && -z $DESCRIPTION ]] ; then
          usage; exit 1   
fi

/usr/bin/rsync -aLvih $SourcePath $DestinationPath > $logfile 2> $errlogfile

IfModify=`find $DestinationPath -type f -mtime -1 -print -quit`
if [ -z "$IfModify" ] ; then
    echo "没有能找到在昨天更新的文件，请登陆 $local_ip 检查 $logfile" >> $errlogfile
fi

if [ -s $errlogfile ] ; then
    sendEmail $errlogfile 
else
    rm $errlogfile
fi

if [ -w $errlogfile ]; then
    /bin/gzip $errlogfile
fi
if [ -w $logfile ]; then
    /bin/gzip $logfile
fi