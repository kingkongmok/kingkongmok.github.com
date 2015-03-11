#!/bin/bash - 
#===============================================================================
#
#          FILE: tomcatLinesCount.sh
# 
#         USAGE: ./tomcatLinesCount.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 03/11/2015 10:51:07 AM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
#[ -r /etc/default/locale ] && . /etc/default/locale
#[ -n "$LANG" ] && export LANG

PORTS=( 7711 7722 7733 7744 )
LASTHOUR_DATETIME=`date +%F.%H -d -1hour`
LOCATION="/mmsdk"

OUTPUTFILE="${LOCATION}/crontabLog/tomcat_accesslog_line.log"

for port in ${PORTS[@]}; do
    LOGFILE=${LOCATION}/tomcat_${port}/access.${LASTHOUR_DATETIME}.log ;
    nice -n 19 wc -l "$LOGFILE" >> "$OUTPUTFILE"
done
