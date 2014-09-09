#!/bin/bash - 
#===============================================================================
#
#          FILE: errorMail.sh
# 
#         USAGE: ./errorMail.sh
# 
#   DESCRIPTION:  mail the $MAILUSER with $TFILE.
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 08/25/2014 04:56:43 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
[ -r /etc/default/locale ] && . /etc/default/locale
[ -n "$LANG" ] && export LANG
 set -x

 #-------------------------------------------------------------------------------
 #  the ip locate in /bin/ip in Gentoo, NOT LIKE Centos,
 #-------------------------------------------------------------------------------
IP="/bin/ip"
MAILUSER="13725269365@139.com"
#TFILE="/home/kk/test.sh"


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  errorMail
#   DESCRIPTION:  mail the $MAILUSER with $TFILE.
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
errorMail ()
{
    IP=${IP:-"/sbin/ip"}
    SENDMAIL=${SENDMAIL:-"/usr/sbin/sendmail"}
    CURL=${CURL:-"/usr/bin/curl"}
    PRIV_IP="${IP_ADDR:-`$IP -f inet addr | grep -oP "(?<=inet )\S+(?=\/.*global)"`}"
    [ -x $CURL ] && PUB_IP=`$CURL --silent ip.datlet.com`
    SUBJECT="`hostname`_`basename $0`_${PRIV_IP}_${PUB_IP}"
    FROM="sys.alert@139.com"
    MAIL_CONTENT=`cat "$TFILE"`;
    MAIL="subject:$SUBJECT\nfrom:$FROM\n${MAIL_CONTENT:-"error"}"
    echo -e $MAIL | $SENDMAIL "$MAILUSER"
}	# ----------  end of function errorMail  ----------

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  sendmail
#   DESCRIPTION:  以固定名称，发送$TFILE的内容到$MAILUSER邮箱
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
sendmail ()
{
    #echo "Subject: `hostname`_"$IP_ADDR"_error" | cat - "$TFILE" | /usr/sbin/sendmail -f sys.alert@139.com -t "$MAILUSER" -s smtp.163.com -xu kk_richinfo -xp 1q2w3e4r 
    #echo "Subject: `hostname`_"$IP_ADDR"_error" | cat - "$TFILE" | /usr/sbin/sendmail  -t "$MAILUSER" -f "kk_richinfo@163.com" -s smtp.163.com -xu kk_richinfo -xp 1q2w3e4r
    echo "Subject: `hostname`_"$IP_ADDR"" | cat - $TFILE | /usr/sbin/sendmail -f kk_richinfo@163.com -t $MAILUSER -s smtp.163.com -u nicemail -xu kk_richinfo -xp 1q2w3e4r -m happy
}   # ----------  end of function sendmail  ----------

#errorMail
