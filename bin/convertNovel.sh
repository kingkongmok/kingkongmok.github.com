#!/bin/bash - 
#===============================================================================
#
#          FILE:  convertNovel.sh
# 
#         USAGE:  ./convertNovel.sh "filename"
# 
#   DESCRIPTION:  to convert novel to UTF-8 encoding.
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok@gmail.com
#       COMPANY: 
#       CREATED: 02/19/2012 01:44:25 AM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
set -x
 
FILENAME=$*
ENCODING=

if [ -r "$FILENAME" ] ; then
    ENCODING=$(file -bi "$FILENAME" | sed -e 's/.*[ ]charset=//')
    echo $ENCODING
fi

