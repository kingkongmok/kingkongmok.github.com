#!/bin/bash - 
#===============================================================================
#
#          FILE: convertMobi.sh
# 
#         USAGE: ./convertMobi.sh [ -a AUTHORS ] FILENAME 
# 
#   DESCRIPTION: convert txt file to mobi file for kindle. 
#   for more info about ebook-convert, read
#   http://manual.calibre-ebook.com/cli//usr/bin/ebook-convert.html
# 
#       OPTIONS: ---
#  REQUIREMENTS:  X server, use xvfb. 
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok@gmail.com
#  ORGANIZATION: 
#       CREATED: 06/18/2012 11:16:41 AM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
set -x


AUTHORS=

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
  -a            Authors
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

    #a     )  AUTHORS="$OPTARG" ;  ;;
    a     )  AUTHORS=" --authors $OPTARG" ;  ;;
    h|help     )  usage; exit 0   ;;

    v|version  )  echo "$0 -- Version $ScriptVersion"; exit 0   ;;

    \? )  echo -e "\n  Option does not exist : $OPTARG\n"
          usage; exit 1   ;;

  esac    # --- end of case ---
done
shift $(($OPTIND-1))


[ -r /etc/default/locale ] && . /etc/default/locale
[ -n "$LANG" ] && export LANG

if [ "$#" -lt 1 ] ; then
    echo "please insert the filename." && exit 23 ;
fi

PATHNAME=$*

FILENAME=${PATHNAME%.*}
LASTEXTENSION=${PATHNAME##*.}

#/usr/bin/ebook-convert "$PATHNAME" "${FILENAME}.mobi" --output-profile kindle --language zh --pretty-print --title "$FILENAME" --authors "${AUTHORS}" 
/usr/bin/ebook-convert "$PATHNAME" "${FILENAME}.mobi" --output-profile kindle --language zh --pretty-print --title "$FILENAME" "${AUTHORS}" 

