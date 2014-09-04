#!/bin/bash - 
#===============================================================================
#
#          FILE:  avimake.sh
# 
#         USAGE:  ./avimake.sh 
# 
#   DESCRIPTION:  
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok@gmail.com
#       COMPANY: 
#       CREATED: 05/07/2011 12:05:19 AM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
FILE=$@

	mv "${FILE}" "backup_${FILE}"; 

	if [ -f "frameno.avi" ] ; then
		rm frameno.avi;
	fi

	if [ -f "divx2pass.log" ] ; then
		rm divx2pass.log;
	fi


	nice -n 19 mencoder "backup_${FILE}" -oac lavc -lavcopts acodec=ac3:abitrate=192 -ovc lavc \
		#-lavcopts vcodec=mpeg4:vpass=1:vbitrate=1200 -o "${FILE%.*}.avi";
		-lavcopts vcodec=mpeg4:vpass=1:vbitrate=1200 -o /dev/null ;
	nice -n 19 mencoder "backup_${FILE}" -oac lavc -lavcopts acodec=ac3:abitrate=192 -ovc lavc \
		-lavcopts vcodec=mpeg4:vpass=2:vbitrate=1200 -o "${FILE%.*}.avi";


	if [ -f "frameno.avi" ] ; then
		rm frameno.avi;
	fi

	if [ -f "divx2pass.log" ] ; then
		rm divx2pass.log;
	fi
