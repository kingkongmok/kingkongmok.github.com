#!/bin/bash - 
#===============================================================================
#
#          FILE:  archiveHistory.sh
# 
#         USAGE:  ./archiveHistory.sh 
# 
#   DESCRIPTION:  script for archive .bash_history file. see http://mywiki.wooledge.org/BashFAQ/088
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok@gmail.com
#       COMPANY: 
#       CREATED: 01/27/2012 12:07:51 AM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

umask 077
max_lines=20000

linecount=$(wc -l < ~/.bash_history)

if (($linecount > $max_lines)); then
    prune_lines=$(($linecount - $max_lines))
    head -$prune_lines ~/.bash_history >> ~/.bash_history.archive \
        && sed -e "1,${prune_lines}d"  ~/.bash_history > ~/.bash_history.tmp$$ \
        && mv ~/.bash_history.tmp$$ ~/.bash_history
fi
