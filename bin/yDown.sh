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
        echo "$1" >> /tmp/youtube-dl.${timestamp}.log
        # /home/kk/workspace/youtube-dl/youtube-dl -F "$1" > /tmp/youtube-dl.${timestamp}.log
        # Flag=`grep -P "^h\d.*MiB" /tmp/youtube-dl.${timestamp}.log | perl -naE '$H{$F[0]}++; $K{$F[0]}++ if /best/ }{ if(grep/h3/,keys%H){say +(grep /h3/, keys%H)[0]}else{say keys%K}'`
        #nohup /home/kk/workspace/youtube-dl/youtube-dl -f h3 "$1" \
        echo "$1" >> /home/kk/Downloads/videos/history.list.txt
        youtube-dl -F "$1" | perl -nE 'say $& if /(?<=Finished downloading playlist: ).*/' >> /home/kk/Downloads/videos/history.list.txt
        nohup /home/kk/workspace/youtube-dl/youtube-dl -f "[height < 720]" "$1" \
            -o '/home/kk/Downloads/videos/%(title)s-%(autonumber)s.%(ext)s' \
            >> /tmp/youtube-dl.${timestamp}.log 2>&1 
        echo "$1 is downloading...\n"
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


