#!/bin/bash - 
#===============================================================================
#
#          FILE: rdesktop.sh
# 
#         USAGE: ./rdesktop.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 05/13/2013 05:12:28 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

KK_VAR=/home/kk/.kk_var
[ -r $KK_VAR ] && . $KK_VAR

RDESKTOP=/usr/bin/rdesktop
USERNAME=$COMMON_USERNAME
PASSWORD=$COMMON_PASSWORD

$RDESKTOP xp.kk.igb -g 1024x768 -u $USERNAME -p $PASSWORD
