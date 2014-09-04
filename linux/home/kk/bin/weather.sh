#!/bin/bash - 
#===============================================================================
#
#          FILE: weather.sh
# 
#         USAGE: ./weather.sh 
# 
#   DESCRIPTION: get weather info
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 01/14/2014 08:30:11 AM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
[ -r /etc/default/locale ] && . /etc/default/locale
[ -n "$LANG" ] && export LANG

if [ -x /usr/bin/curl ] ; then
   curl -s "http://www.weather.com.cn/data/sk/101280101.html"|awk -F '[,:]' '{printf ("%s,%s:%s,温度:%s°C,%s:%s,湿度:%s\n"),$3,$17,$18,$7,$9,$11,$13}'|sed 's/"//g' 
fi
