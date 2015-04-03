#!/bin/bash - 
#===============================================================================
#
#          FILE: showProcessSwap.sh
# 
#         USAGE: ./showProcessSwap.sh 
# 
#   DESCRIPTION: show each process swap usage.
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 09/09/2014 05:43:52 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
[ -r /etc/default/locale ] && . /etc/default/locale
[ -n "$LANG" ] && export LANG


SUM=0   
OVERALL=0   
for DIR in `find /proc/ -maxdepth 1 -type d | egrep "^/proc/[0-9]"` ; do   
PID=`echo $DIR | cut -d / -f 3`   
PROGNAME=`ps -p $PID -o comm --no-headers`   
for SWAP in `grep Swap $DIR/smaps 2>/dev/null| awk '{ print $2 }'`   
do   
let SUM=$SUM+$SWAP   
done   
echo "PID=$PID - Swap used: $SUM - ($PROGNAME )"   
let OVERALL=$OVERALL+$SUM   
SUM=0  
done   
echo "Overall swap used: $OVERALL"
