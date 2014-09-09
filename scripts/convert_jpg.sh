#!/bin/bash - 
#===============================================================================
#
#          FILE:  convert_jpg.sh
# 
#         USAGE:  cront convert_jpg.sh 
# 
#   DESCRIPTION:  to convert pic to a small size. 
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok@gmail.com
#       COMPANY: 
#       CREATED: 02/29/2012 10:34:55 AM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error


USERMAIL=qq.mo@info.cf
LOCATION=/home/kk/Documents/Pictures/parents
MAXRESIZELENGTH=1024
MAXRESIZEHIGHT=1024
QUALITYPERCENT=85

[ -r /etc/default/locale ] && . /etc/default/locale
[ -n "$LANG" ] && export LANG
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")          # generate timestamp : YYYYMMDD-hhmmss
LOGLOCATE=/var/log/convert_jpg/
NEWERFLAG="$LOGLOCATE"/newfileflag


if [ ! -d "$LOGLOCATE" ]; then
    mkdir -p "$LOGLOCATE"
fi
if [ ! -f "$NEWERFLAG" ]; then
    touch "$NEWERFLAG"
fi

OLDIFS=$IFS
IFS=$'\n'
FILES=( `find "$LOCATION" -type f -iname \*jpg` )
for (( ITERA=0; ITERA<${#FILES[@]}; ITERA+=1 )); do
    SIZELENGTH=`exiv2 "${FILES[$ITERA]}" | grep "Image size" | awk '{print $4}'`
    SIZEHIGHT=`exiv2 "${FILES[$ITERA]}" | grep "Image size" | awk '{print $6}'`
    if [ "$SIZELENGTH" -gt "$MAXRESIZELENGTH" -o "$SIZEHIGHT" -gt "$MAXRESIZEHIGHT" ]; then
         nice -n 19 convert -resize "$MAXRESIZELENGTH"x"$MAXRESIZEHIGHT"\> -quality "$QUALITYPERCENT"% "${FILES[$ITERA]}" "${FILES[$ITERA]}" && echo "${FILES[$ITERA]}" converted >> "$LOGLOCATE"/"$TIMESTAMP"
    fi
done
IFS=$OLDIFS

mailx $USERMAIL -s convert_jpg-$TIMESTAMP < "$LOGLOCATE"/"$TIMESTAMP"
