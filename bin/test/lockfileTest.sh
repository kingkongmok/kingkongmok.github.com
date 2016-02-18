#!/bin/bash - 
#===============================================================================
#
#          FILE: lockfileTest.sh
# 
#         USAGE: ./lockfileTest.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
#  ORGANIZATION: datlet.com
#       CREATED: 02/18/2016 09:39
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

scriptName=`basename "$0"`

lockfile -r 0 /tmp/${scriptName}.lock || exit 1

# Do stuff here
sleep 50

rm -f /tmp/${scriptName}.lock

