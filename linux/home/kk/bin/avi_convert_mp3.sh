#!/bin/bash - 
#===============================================================================
#
#          FILE: avi_convert_mp3.sh
# 
#         USAGE: ./avi_convert_mp3.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 04/13/2012 09:39:34 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
LAME=/usr/bin/lame
FILENAME=$*
if test -f "$FILENAME" ; then
    mplayer -vo null -ao pcm:file="${FILENAME%.*}" "$*" && \
    $LAME "${FILENAME%.*}" && \
    rm "${FILENAME%.*}"
else
    echo please input filename. && exit 63
fi

