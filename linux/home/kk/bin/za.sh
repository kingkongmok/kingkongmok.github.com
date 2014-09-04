#!/bin/bash - 
#===============================================================================
#
#          FILE:  zenityalarm.sh 
# 
#         USAGE:  with crontab for ubuntu za
# 
#   DESCRIPTION:  zenity warning.
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: kk (kingkongmok@gmail.com), 
#       COMPANY: 
#       CREATED: 08/24/2011 03:51:43 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

ALARM=${*:-time!}
ISTRING=`ps -ef | grep screensa | head -n 1 | awk '{ print $2 }'`

if [ -e /proc/"${ISTRING}" ] ; then
	DISPLAYNUMB=`strings   /proc/"${ISTRING}"/environ |grep DISPLAY`
	if [ -n "$DISPLAYNUMB" ]; then
		export "$DISPLAYNUMB"
		zenity --warning --text="$ALARM"
	fi
fi
