#!/bin/bash - 
#===============================================================================
#
#          FILE: iptables_flush.sh
# 
#         USAGE: ./iptables_flush.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok@gmail.com
#  ORGANIZATION: 
#       CREATED: 06/06/2012 08:47:15 AM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

sudo /sbin/iptables -P INPUT ACCEPT && \
sudo /sbin/iptables -P OUTPUT ACCEPT && \
sudo /sbin/iptables -P FORWARD ACCEPT && \
sudo /sbin/iptables -F || \
echo error

