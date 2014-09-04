#!/bin/bash - 
#===============================================================================
#
#          FILE:  localbrowser.sh
# 
#         USAGE:  ./localbrowser.sh
# 
#   DESCRIPTION:  access WWW with "incognito"
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: kk (kingkongmok@gmail.com), 
#       COMPANY: 
#       CREATED: 07/28/2011 04:35:56 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

PORTNUMB=7071


#-------------------------------------------------------------------------------
#  check if the chromium-browser is on
#-------------------------------------------------------------------------------
if [[ -n `pgrep "chromium-browse"` ]]; then
echo -e "\nchromium-browser is already on.\n"
exit 73
fi

/usr/bin/chromium-browser --incognito 2>/dev/null
exit $?
