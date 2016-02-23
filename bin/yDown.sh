#!/bin/bash - 
#===============================================================================
#
#          FILE: yDown.sh
# 
#         USAGE: ./yDown.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 02/03/2016 20:56
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

echo "please input URL to download, or 'q' to quit:"
while read line           
do           
    if [ "$line" == "q" ] ; then
        break
    else
        timestamp=`date +%s`
        nohup /home/kk/workspace/youtube-dl/youtube-dl "$line" \
            -o '/home/kk/Downloads/videos/%(title)s.%(ext)s' \
            > /tmp/youtube-dl.${timestamp}.log 2>&1 &
        echo "$line is downloading...\n"
        echo "please input URL to download, or 'q' to quit:"
    fi
done
