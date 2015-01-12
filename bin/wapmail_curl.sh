#!/bin/bash - 
#===============================================================================
#
#          FILE: wapmail_curl.sh
# 
#         USAGE: ./wapmail_curl.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 10/28/2014 03:16:47 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
[ -r /etc/default/locale ] && . /etc/default/locale
[ -n "$LANG" ] && export LANG

KK_VAR=/home/kk/.kk_var
[ -f $KK_VAR ] && . $KK_VAR
COOKIE=/tmp/`basename $0`_$$_cookie


SMS_TRIGER=
MMS_TRIGER=
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
  -s|sms        sms test
  -m|mms        mms test
  -h|help       Display this message
  -v|version    Display script version

	EOT
}    # ----------  end of function usage  ----------

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------

while getopts ":hvms" opt
do
  case $opt in

    h|help     )  usage; exit 0   ;;
    m|mms     )  MMS_TRIGER=1   ;;
    s|sms     )  SMS_TRIGER=1   ;;
    v|version  )  echo "$0 -- Version $ScriptVersion"; exit 0   ;;

    \? )  echo -e "\n  Option does not exist : $OPTARG\n"
          usage; exit 1   ;;

  esac    # --- end of case ---
done
shift $(($OPTIND-1))


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  login_wap
#   DESCRIPTION:  登录
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
login_wap ()
{
    SID=`curl -s "https://wapmail.10086.cn/index.htm" -H "Origin: http://wapmail.10086.cn" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2" -H "User-Agent: Mozilla/5.0 (Linux; Android 4.4.4; MI 3 Build/KTU84P) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/33.0.0.0 Mobile Safari/537.36" -H "Content-Type: application/x-www-form-urlencoded" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Cache-Control: max-age=0" -H "Referer: http://wapmail.10086.cn/" -H "Connection: keep-alive" --data "ur=kingkongmok&pw=${COMMON_PASSWORD}&apc=0&_swv=4&switch_ver=3"%"2C4&adapt_ver=3&client_type=3&_fv=3&clt=3" -w %{redirect_url} --compressed -c $COOKIE | grep -oP '(?<=sid=).*?(?=&)'`
echo "sid = $SID"
}	# ----------  end of function login_wap  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  mailfolder
#   DESCRIPTION:  返回邮件列表
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
mailfolder ()
{
    if [ "`curl -s "http://m.mail.10086.cn/wp12/w3/mailfolder" -H "Pragma: no-cache" -H "Origin: http://m.mail.10086.cn" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2" -H "User-Agent: Mozilla/5.0 (Linux; Android 4.4.4; MI 3 Build/KTU84P) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/33.0.0.0 Mobile Safari/537.36" -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" -H "Accept: */*" -H "Cache-Control: no-cache" -H "Referer: http://m.mail.10086.cn/bv12/folder.html?&sid=MTQxNDU2MjkyNDAwMDkwNjYwNzcxMgAA000004&vn=306&vid=&into=1&cmd=40" -H "Connection: keep-alive" --data "&&sid=${SID}&vn=306&into=1&cmd=40&r=0.07340442086569965&__randomNumber=1414562928280" --compressed -b $COOKIE | uriDecode.pl | grep 13725269365`" ] ; then
        echo mailfolder succeed.
    fi
}	# ----------  end of function mailfolder  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  sendmail
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
sendmail ()
{
    if [ "`curl -s "http://m.mail.10086.cn/wp12/w3/sendmail?rnd=0.42626322829164565" -H "Pragma: no-cache" -H "Origin: http://m.mail.10086.cn" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2" -H "User-Agent: Mozilla/5.0 (Linux; Android 4.4.4; MI 3 Build/KTU84P) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/33.0.0.0 Mobile Safari/537.36" -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" -H "Accept: */*" -H "Cache-Control: no-cache" -H "Referer: http://m.mail.10086.cn/bv12/sendmail.html?&sid=${SID}&vn=306" -H "Connection: keep-alive" --data "&&sid=${SID}&vn=306&cmd=2&subject=testMailFromWapmail&content=testmailFromWapMail&reciever=ayanami_0@163.com,&cc=&bcc=&year=&month=&date=&hour=&minute=&showOneRcpt=0&priority=0&requestReadReceipt=0&isHtml=0&timing=false&__randomNumber=1414566302076" --compressed -b $COOKIE  | uriDecode.pl | grep 'eroerCode":0,'`" ] ; then
    echo sendmail modules succeed.
    fi
}	# ----------  end of function sendmail  ----------



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  sendCard
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
sendCard ()
{
    if [ "`curl -s "http://m.mail.10086.cn/ws12/w3/w3cardsend" -H "Pragma: no-cache" -H "Origin: http://m.mail.10086.cn" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2" -H "User-Agent: Mozilla/5.0 (Linux; Android 4.4.4; MI 3 Build/KTU84P) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/33.0.0.0 Mobile Safari/537.36" -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" -H "Accept: */*" -H "Cache-Control: no-cache" -H "Referer: http://m.mail.10086.cn/bv12/cardsend.html?cmd=0&csid=10590&gid=1&sid=${SID}&vn=306&t=" -H "Connection: keep-alive" --data "&&sid=${SID}&vn=306&cmd=1&csid=10590&title=PVZ_card_testing&content=content_for_PVZ_card_testing&dest=ayanami_0@163.com&__randomNumber=1414574072275" --compressed -b $COOKIE | uriDecode.pl | grep 'eroerCode":0,' `" ] ; then
    echo w3cardsend sendcard succeed.
    fi
}	# ----------  end of function sendCard  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  sendSMS
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
sendSMS ()
{
    if [ "`curl -s "http://m.mail.10086.cn/ws12/w3/w3smsend" -H "Pragma: no-cache" -H "Origin: http://m.mail.10086.cn" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2" -H "User-Agent: Mozilla/5.0 (Linux; Android 4.4.4; MI 3 Build/KTU84P) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/33.0.0.0 Mobile Safari/537.36" -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" -H "Accept: */*" -H "Cache-Control: no-cache" -H "Referer: http://m.mail.10086.cn/bv12/sendsms.html?&sid=${SID}&vn=306&vid=&cmd=40" -H "Connection: keep-alive" --data "&&sid=${SID}&vn=306&cmd=2&content=testSMSFromWapmail&reciever=13725269365&__randomNumber=1414574885099" --compressed -b $COOKIE | uriDecode.pl | grep 'eroerCode":0,'`" ] ; then
        echo w3smsend smssend succeed.
    fi
}	# ----------  end of function sendSMS  ----------

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  sendMMS
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
sendMMS ()
{
    if [ "`curl -s "http://m.mail.10086.cn/ws12/w3/w3mmssend" -H "Pragma: no-cache" -H "Origin: http://m.mail.10086.cn" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2" -H "User-Agent: Mozilla/5.0 (Linux; Android 4.4.4; MI 3 Build/KTU84P) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/33.0.0.0 Mobile Safari/537.36" -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" -H "Accept: */*" -H "Cache-Control: no-cache" -H "Referer: http://m.mail.10086.cn/bv12/mmssend.html?&sid=${SID}&vn=306&cmd=3&hasswitchtab=undefined" -H "Connection: keep-alive" --data "&&sid=${SID}&vn=306&cmd=1&content=Content_mmsTestFromWapmail&destnumber=13725269365&title=mmsTestFromWapmail&__randomNumber=1414574358407" --compressed -b $COOKIE | uriDecode.pl | grep 'eroerCode":0,' `" ] ; then
        echo w3mmssend succeed.
    fi
}	# ----------  end of function sendMMS  ----------

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  logoutWap
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
logoutWap ()
{
    if [ "`curl -s "http://m.mail.10086.cn/wp12/w3/logout" -H "Pragma: no-cache" -H "Origin: http://m.mail.10086.cn" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2" -H "User-Agent: Mozilla/5.0 (Linux; Android 4.4.4; MI 3 Build/KTU84P) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/33.0.0.0 Mobile Safari/537.36" -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" -H "Accept: */*" -H "Cache-Control: no-cache" -H "Referer: http://m.mail.10086.cn/bv12/home.html?&sid=${SID}&vn=306" -H "Connection: keep-alive" --data "&sid=${SID}&vn=306&vid=&__randomNumber=1414566524022" --compressed -b $COOKIE | grep 'eroerCode":1000,' `" ] ; then
    echo logout succeed.
    fi
}	# ----------  end of function logoutWap  ----------

login_wap 
if [ "$SID" ] ; then
    if [ "$SMS_TRIGER" ] ; then
        sendSMS
    fi
    if [ "$MMS_TRIGER" ]  ; then
        sendMMS
    fi
    sendmail
    sendCard
    mailfolder
    logoutWap

    if [ -w "$COOKIE" ]  ; then
        rm "$COOKIE"
    fi
fi
