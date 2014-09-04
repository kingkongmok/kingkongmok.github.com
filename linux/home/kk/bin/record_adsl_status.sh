#!/bin/bash - 
#===============================================================================
#
#          FILE: record_adsl_status.sh
# 
#         USAGE: ./record_adsl_status.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 08/12/2013 09:52:19 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

[ -r /etc/default/locale ] && . /etc/default/locale
[ -n "$LANG" ] && export LANG

TIMESTAMP=$(date +"%Y%m%d-%H%M%S") ;

LOCATION=/home/kk/Documents/adsl


if cd $LOCATION ; then
    echo "the ipaddr" > $TIMESTAMP
    /usr/bin/curl www.icanhazip.com >> $TIMESTAMP 2>/dev/null
    echo -e "the traceroute info" >> $TIMESTAMP
    /usr/bin/traceroute -n 163.com >> $TIMESTAMP  2>/dev/null
fi

