#!/bin/bash

#-------------------------------------------------------------------------------
#  http://www.cyberciti.biz/faq/linux-detect-port-scan-attacks/
#   to enable psad logging, please install psad and sysklogd.
#   after testing, please save by iptables-save and enable by iptable-restore
#-------------------------------------------------------------------------------

# which NIC 
PUB_ETH="eth0"

# enable the following port ONLY.
TCP_PORT=( 1:1024 4000 2049)

# enable the following port ONLY.
UDP_PORT=( 1:1024 )

# if file exist, block the IPs.
BLOCK_IP_LIST=/etc/iptables/blocked_ip.fw

# if file exist, continue that commands.
IPV6_IPTABLES_COMMAND=/etc/iptables/start6.fw


#-------------------------------------------------------------------------------
#  please don't edit below
#-------------------------------------------------------------------------------

IPT="/usr/bin/sudo /sbin/iptables"
 
$IPT -F
$IPT -X
$IPT -t nat -F
$IPT -t nat -X
$IPT -t mangle -F
$IPT -t mangle -X
modprobe ip_conntrack
 

if [ -r "$BLOCK_IP_LIST" ] ; then
    BADIPS=$(egrep -v -E "^#|^$" "$BLOCK_IP_LIST" )
fi
 
#unlimited
$IPT -A INPUT -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT
 
# DROP all incomming traffic
$IPT -P INPUT DROP
$IPT -P OUTPUT DROP
$IPT -P FORWARD DROP
 
# block all bad ips
if [ -r "$BLOCK_IP_LIST" ] ; then
    for ip in $BADIPS
    do
        $IPT -A INPUT -i $PUB_ETH  -s $ip -j DROP
        $IPT -A OUTPUT -d $ip -j DROP
    done
fi
 
# sync
$IPT -A INPUT -i $PUB_ETH  -p tcp ! --syn -m state --state NEW  -m limit --limit 5/m --limit-burst 7 -j LOG --log-level 4 --log-prefix "Drop Syn"
 
$IPT -A INPUT -i $PUB_ETH  -p tcp ! --syn -m state --state NEW -j DROP
 
# Fragments
$IPT -A INPUT -i $PUB_ETH  -f  -m limit --limit 5/m --limit-burst 7 -j LOG --log-level 4 --log-prefix "Fragments Packets"
$IPT -A INPUT -i $PUB_ETH  -f -j DROP
 
# block bad stuff
$IPT  -A INPUT -i $PUB_ETH  -p tcp --tcp-flags ALL FIN,URG,PSH -j DROP
$IPT  -A INPUT -i $PUB_ETH  -p tcp --tcp-flags ALL ALL -j DROP
 
$IPT  -A INPUT -i $PUB_ETH  -p tcp --tcp-flags ALL NONE -m limit --limit 5/m --limit-burst 7 -j LOG --log-level 4 --log-prefix "NULL Packets"
$IPT  -A INPUT -i $PUB_ETH  -p tcp --tcp-flags ALL NONE -j DROP # NULL packets
 
$IPT  -A INPUT -i $PUB_ETH  -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
 
$IPT  -A INPUT -i $PUB_ETH  -p tcp --tcp-flags SYN,FIN SYN,FIN -m limit --limit 5/m --limit-burst 7 -j LOG --log-level 4 --log-prefix "XMAS Packets"
$IPT  -A INPUT -i $PUB_ETH  -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP #XMAS
 
$IPT  -A INPUT -i $PUB_ETH  -p tcp --tcp-flags FIN,ACK FIN -m limit --limit 5/m --limit-burst 7 -j LOG --log-level 4 --log-prefix "Fin Packets Scan"
$IPT  -A INPUT -i $PUB_ETH  -p tcp --tcp-flags FIN,ACK FIN -j DROP # FIN packet scans
 
$IPT  -A INPUT -i $PUB_ETH  -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP
 
# Allow full outgoing connection but no incomming stuff
$IPT -A INPUT -i $PUB_ETH -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A OUTPUT -o eth0 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
 
## allow the following tcp port
for (( CNTR=0; CNTR<${#TCP_PORT[@]}; CNTR+=1 )); do
	$IPT -A INPUT -i $PUB_ETH  -p tcp --destination-port ${TCP_PORT[$CNTR]} -j ACCEPT
	$IPT -A OUTPUT -p tcp --sport ${TCP_PORT[$CNTR]} -j ACCEPT
done

for (( CNTR=0; CNTR<${#UDP_PORT[@]}; CNTR+=1 )); do
	$IPT -A INPUT -i $PUB_ETH  -p udp --destination-port ${UDP_PORT[$CNTR]} -j ACCEPT
	$IPT -A OUTPUT -p udp --sport ${UDP_PORT[$CNTR]} -j ACCEPT
done
 
# allow incoming ICMP ping pong stuff
$IPT -A INPUT -i $PUB_ETH  -p icmp --icmp-type 8 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
$IPT -A OUTPUT -p icmp --icmp-type 0 -m state --state ESTABLISHED,RELATED -j ACCEPT
 
# No smb/windows sharing packets - too much logging
$IPT -A INPUT -i $PUB_ETH  -p tcp --dport 137:139 -j REJECT
$IPT -A INPUT -i $PUB_ETH  -p udp --dport 137:139 -j REJECT
 
# Log everything else
# *** Required for psad ****
$IPT -A INPUT -i $PUB_ETH -j LOG
$IPT -A FORWARD -i $PUB_ETH -j LOG
$IPT -A INPUT -i $PUB_ETH  -j DROP
 
# Start ipv6 firewall
# echo "Starting IPv6 Wall..."
if [ -x "$IPV6_IPTABLES_COMMAND" ] ; then
    sh "$IPV6_IPTABLES_COMMAND"
fi
 
exit 0
