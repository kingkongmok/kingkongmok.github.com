#!/bin/bash - 
#===============================================================================
#
#          FILE: spaceCheck_mmSdk.sh
# 
#         USAGE: ./spaceCheck_mmSdk.sh 
# 
#   DESCRIPTION: record space hourly
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 10/21/2014 09:56:09 AM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

PERCENT=`df | perl -lnae 'print $F[-2] if /\/mmsd/'`
TIMESTAMP=`date +%F_%T`

echo $PERCENT $TIMESTAMP

