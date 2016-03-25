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

FirstChoise=h3
SecondChoise=best

echo "please input URL to download, or 'q' to quit:"
while read line           
do           
    if [ "$line" == "q" ] ; then
        break
    else
        timestamp=`date +%s`
            /home/kk/workspace/youtube-dl/youtube-dl -F "$line" > /tmp/youtube-dl.${timestamp}.log
            Flag=`grep -P "^h\d.*MiB" /tmp/youtube-dl.${timestamp}.log | perl -naE '$H{$F[0]}++; $K{$F[0]}++ if /best/ }{ if(grep/h3/,keys%H){say "h3"}else{say keys%K}'`
            nohup /home/kk/workspace/youtube-dl/youtube-dl -f h3 "$line" \
            -o '/home/kk/Downloads/videos/%(title)s-%(autonumber)s.%(ext)s' \
            >> /tmp/youtube-dl.${timestamp}.log 2>&1 &
        echo "$line is downloading...\n"
        echo "please input URL to download, or 'q' to quit:"
    fi
done
