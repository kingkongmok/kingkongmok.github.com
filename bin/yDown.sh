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
DownloadLog="/home/kk/Dropbox/var/log/yDown.log"

downUrl()
{
        timestamp=`date +%s`
        if [[ `grep -x "$1" "$DownloadLog"` ]] ; then 
            echo "$1" is download before.
        else
            echo "$1" >> /tmp/youtube-dl.${timestamp}.log
            echo "$1" >> "$DownloadLog"
            /home/kk/workspace/youtube-dl/youtube-dl -F "$1" | perl -nE 'say $& if /(?<=Finished downloading playlist: ).*/' >> "$DownloadLog"
            nohup /home/kk/workspace/youtube-dl/youtube-dl -f "[height < 720]" "$1" \
                -o '/home/kk/Downloads/videos/%(title)s-%(autonumber)s.%(ext)s' \
            #nohup /home/kk/workspace/youtube-dl/youtube-dl "$1" \
                # -o '/home/kk/Downloads/videos/%(title)s-%(autonumber)s.%(ext)s' \
                >> /tmp/youtube-dl.${timestamp}.log 2>&1 
        fi
}	# ----------  end of function downUrl  ----------


forceDownUrl()
{
    timestamp=`date +%s`
    echo "$1" >> /tmp/youtube-dl.${timestamp}.log
    echo "$1" >> "$DownloadLog"
    /home/kk/workspace/youtube-dl/youtube-dl -F "$1" | perl -nE 'say $& if /(?<=Finished downloading playlist: ).*/' >> "$DownloadLog"
    nohup /home/kk/workspace/youtube-dl/youtube-dl -f "[height < 720]" "$1" \
        -o '/home/kk/Downloads/videos/%(title)s-%(autonumber)s.%(ext)s' \
    #nohup /home/kk/workspace/youtube-dl/youtube-dl "$1" \
        #-o '/home/kk/Downloads/videos/%(title)s-%(autonumber)s.%(ext)s' \
        >> /tmp/youtube-dl.${timestamp}.log 2>&1 
}	# ----------  end of function downUrl  ----------


#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
function usage ()
{
    cat <<- EOT

    DESCRIPTION: download video from youtube-dl

    Usage :  ${0##/*/} [-f]

    Options: 
    -f            Force Download, ignore history.
    -h|help       Display this message

EOT
}    # ----------  end of function usage  ----------

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------
SourcePath=
DestinationPath=
DESCRIPTION=
ForceDownload=

while getopts "fh" opt
do
    case $opt in

        f     )  ForceDownload=1 ;  ;;
        h|help     )  usage; exit 0   ;;

        \? )  echo -e "\n  Option does not exist : $OPTARG\n"
            usage; exit 1   ;;

        esac    # --- end of case ---
    done
shift $(($OPTIND-1))


#-------------------------------------------------------------------------------
# main()
#-------------------------------------------------------------------------------
echo "please input URL to download, or 'q' to quit:"
while read line           
do           
    if [ "$line" == "q" ] ; then
        break
    else
        if [ "$ForceDownload" ] ; then
            forceDownUrl $line &
        else
            downUrl $line &
        fi
        echo "please input URL to download, or 'q' to quit:"
    fi
done

