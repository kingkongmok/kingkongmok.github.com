#!/bin/bash - 
#===============================================================================
#
#          FILE: shutdownWithoutProcess.sh
# 
#         USAGE: ./shutdownWithoutProcess.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 12/10/2013 12:27:36 AM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
[ -r /etc/default/locale ] && . /etc/default/locale
[ -n "$LANG" ] && export LANG


while true; do if ! pgrep rsync &>/dev/null ; then echo break && break ; fi; sleep 10; done
