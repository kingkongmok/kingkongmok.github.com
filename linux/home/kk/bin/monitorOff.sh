#!/bin/bash - 
#===============================================================================
#
#          FILE: monitorOff.sh
# 
#         USAGE: ./monitorOff.sh 
# 
#   DESCRIPTION: to shutdown the monitor for saving money.
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 08/07/2013 09:41:50 AM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
while true; do xset dpms force off; sleep 10; done

