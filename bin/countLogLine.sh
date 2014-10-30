#!/bin/bash - 
#===============================================================================
#
#          FILE: countLogLine.sh
# 
#         USAGE: ./countLogLine.sh LOGFILE
# 
#   DESCRIPTION: 用于记录日志各个时段的自增行数。
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 10/30/2014 03:58:19 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

PATHNAME=$*
OUTPUT_FILE=${PATHNAME}.line


if [ ! -r "$PATHNAME" ] ; then
    echo file not found can not read && exit 67 ;
fi

TIMESTAMP=`date +"%F %T"`

NEW_LINE_NUMB=`wc -l $PATHNAME | awk '{print $1}'`

if [ -f "$OUTPUT_FILE" ] ; then
    OLD_LINE_NUMB=`tail -n1 $OUTPUT_FILE | awk '{print $(NF-1)}'`
    LINE_NUMB=$(($NEW_LINE_NUMB - $OLD_LINE_NUMB))
    echo -e "$TIMESTAMP\t$NEW_LINE_NUMB\t$LINE_NUMB" >> $OUTPUT_FILE
else
    OLD_LINE_NUMB=0
    echo -e "$TIMESTAMP\t$NEW_LINE_NUMB\t0" >> $OUTPUT_FILE
fi

