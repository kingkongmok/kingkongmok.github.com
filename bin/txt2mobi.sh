#!/bin/bash - 
#===============================================================================
#
#          FILE: txt2mobi.sh
# 
#         USAGE: ./txt2mobi.sh [-a AUTHOR] FILENAME.txt
# 
#   DESCRIPTION: convert txt to mobi using grutatxt and kindlegen
# 
#       OPTIONS: -a|author
#  REQUIREMENTS: grutatxt, kindlegen, enca, perl in Linux
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 04/14/2015 14:17
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

AUTHOR=""

ScriptVersion="1.0"

#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
function usage ()
{
	cat <<- EOT

  Usage :  ${0##/*/} [-a AUTHOR] FILENAME

  Options: 
  -a|author     set author
  -h|help       Display this message
  -v|version    Display script version

	EOT
}    # ----------  end of function usage  ----------

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------

while getopts "a:hv" opt
do
  case $opt in

    a|author     )  AUTHOR="$OPTARG"   ;;

    h|help     )  usage; exit 0   ;;

    v|version  )  echo "$0 -- Version $ScriptVersion"; exit 0   ;;

    \? )  echo -e "\n  Option does not exist : $OPTARG\n"
          usage; exit 1   ;;

  esac    # --- end of case ---
done
shift $(($OPTIND-1))


PATHNAME=`basename $1`
FILENAME=${PATHNAME%%.*}
TMPFILE="kindlegen_$$"

if [ -r $1 ] ; then
    #enca -x utf8 -L zh < $1 > $TMPFILE
    if [ ! "`file $1 | grep UTF-8`" ]  ; then
        iconv -f gbk -c $1 > $TMPFILE
    else
        cp $1 > $TMPFILE
    fi
    
    perl -i -ne 'if(/\S/){s/\r//;print "$_\n"}' $TMPFILE
    grutatxt --encoding  utf8 < $TMPFILE > ${TMPFILE}.html 
    perl -i -pe "s#(?<=^\<title\>).*(?=\<\/title\>)#$FILENAME#" ${TMPFILE}.html
    if [ "$AUTHOR" ] ; then
        perl -i -pe "print \"<meta name='author' content='$AUTHOR'>\n\" if $. == 5" ${TMPFILE}.html
    fi
    perl -i -nae 'print unless /^<\/?pre>$/' ${TMPFILE}.html
    kindlegen ${TMPFILE}.html -o ${FILENAME}.mobi
    if [ -w ${TMPFILE} ] ; then
        rm ${TMPFILE}
    fi
    if [ -w ${TMPFILE}.html ] ; then
        rm ${TMPFILE}.html
    fi
fi
