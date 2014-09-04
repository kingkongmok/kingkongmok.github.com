#!/bin/bash - 
#===============================================================================
#
#          FILE:  dyOn.sh
# 
#         USAGE:  ./dyOn.sh 
# 
#   DESCRIPTION:  power on the dynamips
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok@gmail.com
#       COMPANY: 
#       CREATED: 12/07/2011 08:35:50 AM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
set -x

set -x
if [[ `netstat -ntl4 | grep 7200` ]]; then
    echo dynamips already on;
else
    if cd /home/kk/.dynamips/workplace ; then
        nice -n 19 dynamips -H 7200 &
        nice -n 19 dynagen ../test.net
    fi
fi

