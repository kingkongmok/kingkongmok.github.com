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

INPUT_FILE=
OUTPUT_FILE=

ScriptVersion="1.0"

#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
function usage ()
{
	cat <<- EOT

  Usage :  ${0##/*/} [options] [--] 

  Options: 
  -o|output     Output result file.
  -i|input      Input Logfile.

  -h|help       Display this message
  -v|version    Display script version

	EOT
}    # ----------  end of function usage  ----------

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------

while getopts "i:o:hv" opt
do
  case $opt in

    o|output   ) OUTPUT_FILE="$OPTARG"   ;;
    i|input   )  INPUT_FILE="$OPTARG"   ;;

    h|help     )  usage; exit 0   ;;

    v|version  )  echo "$0 -- Version $ScriptVersion"; exit 0   ;;

    \? )  echo -e "\n  Option does not exist : $OPTARG\n"
          usage; exit 1   ;;

  esac    # --- end of case ---
done
shift $(($OPTIND-1))

if [ ! -r "$INPUT_FILE" ] ; then
    echo file not found can not read && exit 67 ;
fi

if [ -z "$OUTPUT_FILE" -o "$OUTPUT_FILE" = " " ]; then
    OUTPUT_FILE=${INPUT_FILE}.line
fi

TIMESTAMP=`date +"%F %T"`
NEW_LINE_NUMB=`nice wc -l $INPUT_FILE | awk '{print $1}'`
if [ -f "$OUTPUT_FILE" ] ; then
    OLD_LINE_NUMB=`tail -n1 $OUTPUT_FILE | awk '{print $(NF-1)}'`
    if [ "$NEW_LINE_NUMB" -ge "$OLD_LINE_NUMB" ] ; then
        INCREASE_LINE_NUMB=$(($NEW_LINE_NUMB - $OLD_LINE_NUMB))
    else
        INCREASE_LINE_NUMB=$NEW_LINE_NUMB
    fi
else
    INCREASE_LINE_NUMB=0
fi

echo -e "$TIMESTAMP\t$NEW_LINE_NUMB\t$INCREASE_LINE_NUMB" >> $OUTPUT_FILE
