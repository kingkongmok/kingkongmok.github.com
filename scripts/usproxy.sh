#!/bin/bash - 
#===============================================================================
#
#          FILE:  busupdate.sh
# 
#         USAGE:  ./busupdate.sh 
# 
#   DESCRIPTION:  enter the clifford subnet through the BUS proxy, with the ssh
#                 ssh -L function.
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: kk (kingkongmok@gmail.com), 
#       COMPANY: 
#       CREATED: 07/28/2011 04:35:56 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
set -x

KK_VAR=/home/kk/.kk_var
[ -r $KK_VAR ] && . $KK_VAR

#-------------------------------------------------------------------------------
#  check if the chromium is on
#-------------------------------------------------------------------------------
if [[ -n `pgrep "chromium"` ]]; then
echo -e "\nchromium is already on.\n"
exit 73
fi

SHPID=
KILLSSHTRIGER=

SSHLOCALRES=$( sudo netstat -antp4 | grep "127.0.0.1:${PROXYPORTNUMB}")
if  [[ $SSHLOCALRES ]] ; then
	SSHPID=`sudo netstat -antp4 | grep LISTEN | grep 127.0.0.1:${PROXYPORTNUMB} | awk '{print $7}' | cut -d/ -f1`
else
	ssh -CqTfnN -D ${PROXYPORTNUMB}  ${COMMON_WEBUSERNAME}@${US_SERVER_ADDRESS}
	SSHPID=`sudo netstat -anpt4 | grep LISTEN | grep 127.0.0.1:${PROXYPORTNUMB} | awk '{print $7}' | cut -d/ -f1`
	KILLSSHTRIGER=1
fi
    proxychains chromium 2>/dev/null 
	BROWSERRESULT=$?

    if [ "$KILLSSHTRIGER" = 1 ] ; then
        sudo kill -9 "$SSHPID"
    fi

exit $BROWSERRESULT
