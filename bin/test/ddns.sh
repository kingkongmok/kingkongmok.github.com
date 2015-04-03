#!/bin/bash - 
#===============================================================================
#
#          FILE: ddns.sh
# 
#         USAGE: ./ddns.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 05/13/2013 02:45:53 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
set -x
[ -r /etc/default/locale ] && . /etc/default/locale
[ -n "$LANG" ] && export LANG

KK_VAR=/home/kk/.kk_var
[ -f $KK_VAR ] && . $KK_VAR

w3m -no-cookie "http://${COMMON_WEBUSERNAME}:${COMMON_PASSWORD}@members.3322.org/dyndns/update?system=dyndns&hostname=${COMMON_WEBUSERNAME}.3322.org&mx=${COMMON_WEBUSERNAME}.3322.org" > /dev/null 2>&1
