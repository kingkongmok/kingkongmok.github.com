#!/bin/bash - 
#===============================================================================
#
#          FILE:  vob_convert_mp4.sh
# 
#         USAGE:  ./vob_convert_mp4.sh 
# 
#   DESCRIPTION:  convert all VOB file into mp4 avi files.
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok@gmail.com
#       COMPANY: 
#       CREATED: 03/28/2012 07:32:42 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
set -x

if [ "$#" -lt 1 ]; then
   LOCATION=`pwd`     
elif [ "$#" -gt 0 ]; then
    LOCATION="$*"
fi
if [[ "$LOCATION" = "/home/kk" ]]; then
    echo "please set location." && exit 23
fi

cd "$LOCATION"

OLDIFS=$IFS
IFS=$'\n'

FILEARRAYS=(`find -iname \*VOB`)
IFS=$OLDIFS

[ -r /etc/default/locale ] && . /etc/default/locale
[ -n "$LANG" ] && export LANG

echo ${#FILEARRAYS[@]}
for (( ITERA=0; ITERA<${#FILEARRAYS[@]}; ITERA+=1 )); do


        if [ -f "frameno.avi" ] ; then
            rm frameno.avi;
        fi

        if [ -f "divx2pass.log" ] ; then
            rm divx2pass.log;
        fi
        
        
        if [ -f "${FILEARRAYS[$ITERA]%.*}.avi" ]; then
            TIMESTAMP=$(date +"%Y%m%d-%H%M%S")          # generate timestamp : YYYYMMDD-hhmmss
            mv "${FILEARRAYS[$ITERA]%.*}.avi" "${FILEARRAYS[$ITERA]%.*}.avi"_$TIMESTAMP
        fi

        nice -n 19 mencoder "${FILEARRAYS[$ITERA]}" -oac pcm -ovc lavc -lavcopts vcodec=mpeg4:vbitrate=2400:v4mv:mbd=2:trell:cmp=3:subcmp=3:autoaspect:vpass=1 -o /dev/null
        nice -n 19 mencoder "${FILEARRAYS[$ITERA]}" -oac lavc -lavcopts acodec=ac3:abitrate=192 -ovc lavc -lavcopts vcodec=mpeg4:vbitrate=2400:v4mv:mbd=2:trell:cmp=3:subcmp=3:autoaspect:vpass=2 -o "${FILEARRAYS[$ITERA]%.*}.avi"


        if [ -f "frameno.avi" ] ; then
            rm frameno.avi;
        fi

        if [ -f "divx2pass.log" ] ; then
            rm divx2pass.log;
        fi

done
