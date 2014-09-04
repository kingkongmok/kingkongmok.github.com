#!/bin/bash - 
#===============================================================================
#
#          FILE: rdesktoplocalhost.sh
# 
#         USAGE: ./rdesktoplocalhost.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 03/21/2012 10:41:47 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

[ -r /home/kk/.kk_var ] && . /home/kk/.kk_var
[ -r /etc/default/locale ] && . /etc/default/locale
[ -n "$LANG" ] && export LANG

VIRTUAL_XP_RDESKTOP_USERNAME=$COMMON_USERNAME
VIRTUAL_XP_RDESKTOP_PASSWORD=$COMMON_PASSWORD

rdesktop ${VIRTUAL_XP_HOST}:$VIRTUAL_XP_RDESKTOP_PORT -u $VIRTUAL_XP_RDESKTOP_USERNAME -p $VIRTUAL_XP_RDESKTOP_PASSWORD -f
