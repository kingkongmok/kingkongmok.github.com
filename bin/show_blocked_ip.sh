#!/bin/sh

############################################################
#
# show_blocked_ip
#
# Shows explicitly blocked IP addresses
#
############################################################

IP=`iptables -L -n | awk '$4~/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/ && $4!~/0\.0\.0\.0/ && $1~/DROP/ {print $4}'`

if [ "$IP" == "" ]; then
    echo "No blocked IP addresses found."
else
    echo "Blocked IP addresses:"
    for n in $IP; do
        echo $n
    done
fi

exit 0

# EOF
