#!/bin/bash - 
#===============================================================================
#
#          FILE: office_proxylogin.sh
# 
#         USAGE: ./office_proxylogin.sh
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 01/07/2015 08:58:21 AM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
[ -r /etc/default/locale ] && . /etc/default/locale
[ -n "$LANG" ] && export LANG

while true ; do
    ping -q -c 1 10.0.0.8 &>/dev/null && curl -s "http://10.0.0.8/login/" -H "Pragma: no-cache" -H "Accept-Encoding: gzip, deflate, sdch" -H "Accept-Language: en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2" -H "Authorization: Basic bW9xaW5ncWlhbmc6bHRhWWZNTDJOM1J2Mg==" -H "User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Cache-Control: no-cache" -H "Referer: http://10.0.0.8/redirect/?www.google.com/" -H "Proxy-Connection: keep-alive" --compressed &>/dev/null && break 
    sleep 2 
    [ "`curl -s www.163.com`" ] && break
done
