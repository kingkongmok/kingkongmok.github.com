#!/bin/bash - 
#===============================================================================
#
#          FILE: keepssh.sh
# 
#         USAGE: ./keepssh.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 12/18/2013 02:46:22 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
[ -r /etc/default/locale ] && . /etc/default/locale
[ -n "$LANG" ] && export LANG
[ -r /home/kk/.kk_var ] && . /home/kk/.kk_var

if [ ! "$(ps -ef | grep -e [s]sh.*10000.*${HOMEDOMAIN} )" ] ; then
    ssh -f -N -R 10000:localhost:22 $HOMEDOMAIN 2>/dev/null
fi

