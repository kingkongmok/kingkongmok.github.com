#!/bin/bash - 
#===============================================================================
#
#          FILE: test.sh
# 
#         USAGE: ./test.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
#  ORGANIZATION: datlet.com
#       CREATED: 01/25/2016 15:37
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

CropID='xxxxxx'
Secret='xxxxxx'
GURL="https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=$CropID&corpsecret=$Secret"
Gtoken=$(/usr/bin/curl -s -G $GURL | awk -F" '{print $4}')

PURL="https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=$Gtoken"

function body() {
local int AppID=3 企业号中的应用id
local UserID=$1 部门成员id，zabbix中定义的微信接收者
local PartyID=1 部门id，定义了范围，组内成员都可接收到消息
local Msg=$(echo "$@" | cut -d" " -f3-) 过滤出zabbix中传递的第三个参数
printf '{n'
printf 't"touser": "'"$User""",n"
printf 't"toparty": "'"$PartyID""",n"
printf 't"msgtype": "text",n'
printf 't"agentid": "'" $AppID """,n"
printf 't"text": {n'
printf 'tt"content": "'"$Msg"""n"
printf 't},n'
printf 't"safe":"0"n'
printf '}n'
}
/usr/bin/curl --data-ascii "$(body $1 $2 $3)" $PURL

