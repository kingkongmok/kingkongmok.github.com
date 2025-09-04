#!/bin/bash - 
#===============================================================================
#
#          FILE: check_brute_force.sh
# 
#         USAGE: ./check_brute_force.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: https://wiki.dd-wrt.com/wiki/index.php/Preventing_Brute_Force_Attacks
#  ORGANIZATION: datlet.com
#       CREATED: 02/12/2019 08:58
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

############################################################
#
# check_brute_force
# Checks for failed logins and blocks IP addresses
#
############################################################

# IP=`perl -nE '$H{$1}++ if /(\S+):\d+ TLS Auth Error: Auth Username\/Password verification failed for peer/ }{ for(keys %H){say "$_" if $H{$_} > 30}' /var/log/openvpn.log`


# logtail

#LOG=/var/log/openvpn.log
LOG=/tmp/all.log
LOGTAIL=/usr/local/bin/logtail
LOGTAIL_TMP=/tmp/openvpn_logtail.tmp

$LOGTAIL -o $LOGTAIL_TMP $LOG |

# show IP which failed login 30times since last check
IP=`$LOGTAIL -o $LOGTAIL_TMP $LOG | perl -nE '$H{$1}++ if /(\S+):\d+ TLS Auth Error: Auth Username\/Password verification failed for peer/ }{ for(keys %H){say "$_" if $H{$_} > 30}'`
rc=$?

if [ "$IP" == "" ]; then
    echo "No blocked IP addresses found."
else
    echo "Blocked IP addresses:"
    for TARGET in $IP; do
	# Do nothing if there is an existing rule for this IP address
	if `iptables -L -n | grep $TARGET > /dev/null 2>&1`; then
	    exit 0
	fi

	case $TARGET in
	    "") # Do nothing with empty IP
	    ;;
	    192.168*) # Exclude local LAN
	    ;;
	    172.16*) # Exclude local LAN
	    ;;
	    192.168.) # Exclude local LAN
	    ;;
	    *) # Add rule against intruding IP
	    echo iptables -I INPUT -s $IP -j DROP
	    RC=$?
	    ;;
	esac
    done
fi



exit $RC

# EOF
