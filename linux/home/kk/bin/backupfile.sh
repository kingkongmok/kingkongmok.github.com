#!/bin/bash - 
#===============================================================================
#
#          FILE: backupfile.sh
# 
# 
#   DESCRIPTION: to backup a file or a directory.
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: cp -a SOUR to DEST
#        AUTHOR: kk (Kingkong Mok), kingkongmok@gmail.com
#  ORGANIZATION: 
#       CREATED: 06/14/2012 09:02:59 AM CST
#      REVISION:  1
#===============================================================================

set -o nounset                              # Treat unset variables as an error


[ -r /etc/default/locale ] && . /etc/default/locale
[ -n "$LANG" ] && export LANG

TIMESTAMP=$(date +"%Y%m%d-%H%M%S")          # generate timestamp : YYYYMMDD-hhmmss

if [ $# -gt 0 ] ; then
    PATHNAME="$*"
else
    echo "Usage: `basename $0` FILENAME" && exit 24
fi

FILENAME="${PATHNAME%/}"

if [ ! -r "$FILENAME" ] ; then
    echo "$FILENAME" is not exist && exit 23 ;
fi


sudo cp -a "$FILENAME"{,."$TIMESTAMP"}
