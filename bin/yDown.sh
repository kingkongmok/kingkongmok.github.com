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

downUrl()
{
        timestamp=`date +%s`
        if [[ `grep -x "$1" /home/kk/Downloads/videos/history.list.txt` ]] ; then 
            echo "$1" is download before.
        else
            echo "$1" >> /tmp/youtube-dl.${timestamp}.log
            echo "$1" >> /home/kk/Downloads/videos/history.list.txt
            youtube-dl -F "$1" | perl -nE 'say $& if /(?<=Finished downloading playlist: ).*/' >> /home/kk/Downloads/videos/history.list.txt
            nohup /home/kk/workspace/youtube-dl/youtube-dl -f "[height < 720]" "$1" \
                -o '/home/kk/Downloads/videos/%(title)s-%(autonumber)s.%(ext)s' \
                >> /tmp/youtube-dl.${timestamp}.log 2>&1 
        fi
}	# ----------  end of function downUrl  ----------

echo "please input URL to download, or 'q' to quit:"
while read line           
do           
    if [ "$line" == "q" ] ; then
        break
    else
        downUrl $line &
        echo "please input URL to download, or 'q' to quit:"
    fi
done


