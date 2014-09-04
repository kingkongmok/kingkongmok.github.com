#!/bin/bash - 
#===============================================================================
#
#          FILE:  xdialog.sh
# 
#         USAGE:  xdialog.sh "string"
# 
#   DESCRIPTION:  xdialog message box. from \
#       http://linuxgazette.net/101/sunil.html
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
echo $ALARM 
ISTRING=`ps -ef | grep awesome | head -n 1 | awk '{ print $2 }'`

if [ -e /proc/"${ISTRING}" ] ; then
	DISPLAYNUMB=`strings   /proc/"${ISTRING}"/environ |grep DISPLAY`
	if [ -n "$DISPLAYNUMB" ]; then
		export "$DISPLAYNUMB"
		/usr/bin/Xdialog  --title "time up" --clear   --msgbox "$ALARM" 10 40
	fi
fi
