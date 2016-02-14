#!/bin/bash - 
#===============================================================================
#
#          FILE: vpsTestSpeed.sh
# 
#         USAGE: ./vpsTestSpeed.sh 
# 
#   DESCRIPTION: test vps speed
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
#  ORGANIZATION: datlet.com
#       CREATED: 02/14/2016 16:57
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

logFile="/home/kk/Dropbox/network/vps_test_result.log"
serverListFile="/home/kk/Dropbox/network/vps_test.list"

if [ -r "$serverListFile" ] ; then
    if [ -w "$logFile" ] ; then
        if [ -x /usr/sbin/fping ] ; then
            date >> "$logFile" 
            #-------------------------------------------------------------------------------
            # fping all the server and get result
            # -b   Number of bytes of ping data to send.
            # -q   Quiet.
            # -c   Number  of  request  packets to send to each target.
            #-------------------------------------------------------------------------------
            sudo /usr/sbin/fping -b1472 -q -c100 `cat $serverListFile | xargs` 2>> "$logFile"
            echo "" >> "$logFile"
        fi
    fi
fi
