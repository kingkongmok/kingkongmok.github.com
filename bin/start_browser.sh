#!/bin/bash - 
#===============================================================================
#
#          FILE: start_chrome.sh
# 
#         USAGE: ./start_chrome.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
#  ORGANIZATION: datlet.com
#       CREATED: 15/07/21 08:37
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error


# sh -c '[ "`pgrep -lf chrome`" ] && sh -x "/usr/bin/google-chrome-stable"'
pgrep -a chrome || /usr/bin/google-chrome-stable

