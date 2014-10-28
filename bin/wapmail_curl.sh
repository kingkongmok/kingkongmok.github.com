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

echo $COOKIE

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  login_wap
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
login_wap ()
{
    SID=`curl -s "https://wapmail.10086.cn/index.htm" -H "Origin: http://wapmail.10086.cn" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.36 Safari/537.36" -H "Content-Type: application/x-www-form-urlencoded" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Cache-Control: max-age=0" -H "Referer: http://wapmail.10086.cn/" -H "Connection: keep-alive" --data "ur=kingkongmok&pw=${COMMON_PASSWORD}&apc=0&_swv=4&switch_ver=3"%"2C4&adapt_ver=3&client_type=3&_fv=3&clt=3" -w %{redirect_url} --compressed -c $COOKIE | grep -oP '(?<=sid=).*?(?=&)'`
echo "sid = $SID"
}	# ----------  end of function login_wap  ----------

login_wap
if [ -w "$COOKIE" ]  ; then
    rm "$COOKIE"
fi
