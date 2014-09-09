#!/bin/bash - 
#===============================================================================
#
#          FILE: ntp_update.sh
# 
#         USAGE: ./ntp_update.sh 
# 
#   DESCRIPTION: shutdown the ntpd && ntpdate && start ntpd
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 09/02/2014 06:02:06 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
[ -r /etc/default/locale ] && . /etc/default/locale
[ -n "$LANG" ] && export LANG


sudo /etc/init.d/ntpd stop && \
sudo ntpdate pool.ntp.org && \
sudo /etc/init.d/ntpd start
