#!/bin/bash - 
#===============================================================================
#
#          FILE:  clamscanscript.sh
# 
#         USAGE:  ./clamscancront.sh 
# 
#   DESCRIPTION:  crontab task to scan /var/glc with clamscan.
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: kk (kingkongmok@gmail.com), 
#       COMPANY: 
#       CREATED: 12/08/2010 10:19:13 AM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error


SCANLOCATE=/var/glc
USERMAIL=kk@debian.kk.igb
LOCALE=en_US.UTF-8

HOSTNAME=`hostname -f`
NOWTIME=$(date +%T)
NOWDATE=$(date +%F)
export LC_ALL=$LOCALE
export LC_LANG=$LOCALE
export LC_LANGUAGE=$LOCALE



#-------------------------------------------------------------------------------
#  scan the $SCANLOCATE after updated
#-------------------------------------------------------------------------------
LOG=/var/log/clamav/clamscanResult-${NOWDATE}-${NOWTIME}.log
nice -n 19 find "$SCANLOCATE" -type f -iregex ".*\.\(exe\|com\|sys\|vxd\|drv\|dll\|bin\|ovl\|386\|htm\|html\|fon\|vbs\|vbe\|doc\|dot\|xls\|xlt\|ppt\|bat\|asp\|htt\|hta\|js\|jse\|css\|wsh\|sct\|ocx\|cpl\|lnk\|eml\|nws\|mht\|pif\|shs\|mai\|scr\|zip\|arj\|cab\|rar\|zoo\|arc\|lzh\|pkzip\|gzip\|pkpak\|ace\|dbx\|idx\|ind\|snm\|eml\|nws\|mht\|tar\|gz\|tgz\)" -print0 | xargs -0 clamscan | sed -n '/FOUND$/p' > $LOG


#-------------------------------------------------------------------------------
#  if there's any virus, mail user.
#-------------------------------------------------------------------------------
if [ -n "`cat $LOG`" ] ; then
	cat $LOG | mail $USERMAIL -s virusfound-"$HOSTNAME"-$NOWDATE-$NOWTIME
fi

