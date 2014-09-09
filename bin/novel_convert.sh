#!/bin/bash - 
#===============================================================================
#
#          FILE:  novel_convert.sh
# 
#         USAGE:  ./novel_convert.sh 
# 
#   DESCRIPTION:  
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok@gmail.com
#       COMPANY: 
#       CREATED: 02/25/2012 09:40:17 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error


TIMESTAMP=$(date +"%Y%m%d-%H%M%S")          # generate timestamp : YYYYMMDD-hhmmss


if [ -f /etc/default/locale ] ; then
    . /etc/default/locale
fi

FILENAME=$*
TEMPFILENAME=tempfile_$TIMESTAMP



if [ -r "$FILENAME" ] ; then
    #-------------------------------------------------------------------------------
    #  convert the encoding.
    #-------------------------------------------------------------------------------
    iconv -c -f gbk -t utf8 "$FILENAME" > "$TEMPFILENAME"
    FILENAMESIZE=`ls --time-style=long-iso -l "$FILENAME" | awk '{print $5}'`
    TEMPFILENAMESIZE=`ls --time-style=long-iso -l "$TEMPFILENAME" | awk '{print $5}'`
    FILEINFO=`file "$TEMPFILENAME"`
    if [ "$FILENAMESIZE" -lt "$TEMPFILENAMESIZE" ] ; then
        if [[ "$FILEINFO" =~ "UTF-8 Unicode text" ]] ; then
            echo utf8 convert.
        fi
    fi

    #-------------------------------------------------------------------------------
    # remove \r 
    #-------------------------------------------------------------------------------
    sed 's/\r//g' -i "$TEMPFILENAME" 

    #-------------------------------------------------------------------------------
    #  remove useless sapce.
    #-------------------------------------------------------------------------------
    sed '/^[ \t]*$/d' -i "$TEMPFILENAME" 

    #-------------------------------------------------------------------------------
    #  double space for calibre convert to kindle4.
    #-------------------------------------------------------------------------------
    sed G -i "$TEMPFILENAME" 


    #-------------------------------------------------------------------------------
    # replace file 
    #-------------------------------------------------------------------------------
    mv "$TEMPFILENAME" "$FILENAME"
fi
