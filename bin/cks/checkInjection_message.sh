#!/bin/bash -
#===============================================================================
#
#          FILE: checkInjection_message.sh
#
#         USAGE: ./checkInjection_message.sh
#                 checkInjection.sh -l /mnt/172.26.45.3 -m ckst -w apache
#                 checkInjection.sh -l /mnt/172.26.45.22/LogFiles/W3SVC1 -w iis -m ptmsgz_22
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
#  ORGANIZATION: datlet.com
#       CREATED: 2019-12
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error



# 不检查的字符

WhiteList_STR="(shoppingcart/delete|/cwjbooking/images/delete.png|voyage/order/create|jq-select-utils.js|select-utils-extends.js)"


### don't edit below

#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
function usage ()
{
    cat <<- EOT

    DESCRIPTION: update gentoo

    Usage :  ${0##/*/} [-f]

    Options:
    -l            log location dir prefix WITHOUT / as last ( /tomcat/log ; /iis/log )
    -m            module ( api, webside, b2b )
    -w            web container ( tomcat|iis|nginx|apache )
    -h|help       Display this message

EOT
}    # ----------  end of function usage  ----------

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------

while getopts "l:m:w:h" opt
do
    case $opt in

        l     )  LogLocationDirPrefix="$OPTARG"  ;;
        m     )  Module="$OPTARG"  ;;
        w     )  WebContainer="$OPTARG"  ;;
        h|help     )  usage; exit 0   ;;

        \? )  echo -e "\n  Option does not exist : $OPTARG\n"
            usage; exit 1   ;;

        esac    # --- end of case ---
    done
shift $(($OPTIND-1))

# loglocation /mnt/172.26.45.3/access_20191206.log


local_ip=`/sbin/ip ro | grep 'proto kernel' | awk '{print $9}' | tail -1`
fromUser='alarm@cks.com.hk'
#recipients="panpa@cks.com.hk chenxp@cks.com.hk chenyh@cks.com.hk moqq@cks.com.hk yanggy@cks.com.hk liuw@qualitrip.cn"
recipients="moqq@cks.com.hk"

sendErrorMail(){
	Subject="`basename \"$0\"`: some SQL_injection may occurred in $Module"
	Content="$ErrorMsg $@"
	echo -e "From: $fromUser\nTo: $recipients\nSubject: $Subject \nContent-Type: text/plain; charset=\"utf-8\" \n\n$Content"  | /usr/local/bin/msmtp $recipients
}




if [ $WebContainer = "tomcat" ] ; then
    loglocation="${LogLocationDirPrefix}/localhost_access_log.`date +%F`.txt"
fi

if [ $WebContainer = "iis" ] ; then
    loglocation="${LogLocationDirPrefix}/u_ex`date +%y%m%d`.log"
fi

if [ $WebContainer = "apache" ] ; then
    loglocation="${LogLocationDirPrefix}/access_`date +%Y%m%d`.log"
fi


LOGTAIL=/usr/local/bin/logtail
LOGTAIL_TMP=/tmp/httpaccess_injectionCheck_"$Module".tail


#$LOGTAIL -o $LOGTAIL_TMP $loglocation | grep -iP '\bUNION\b|\bSELECT\b|\bCHAR\b'
ErrorMsg=`$LOGTAIL -o $LOGTAIL_TMP $loglocation | grep -iaP '\b(AND|CREATE|DATABASE|DELETE|UNION|SELECT|CHAR|UPDATE|INSERT|DROP|SHOW)\b' | grep -vP "$WhiteList_STR"`
[[ -n $ErrorMsg ]] && sendErrorMail

