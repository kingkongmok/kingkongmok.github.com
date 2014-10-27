#!/bin/bash - 
#===============================================================================
#
#          FILE: 139_curl.sh
# 
#         USAGE: ./139_curl.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 10/27/2014 10:06:28 AM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
[ -r /etc/default/locale ] && . /etc/default/locale
[ -n "$LANG" ] && export LANG
set -x

KK_VAR=/home/kk/.kk_var
[ -f $KK_VAR ] && . $KK_VAR
TIMESTAMP=`date -d +1day +"%F %T"`

curl -s "https://mail.10086.cn/Login/Login.ashx?_fv=4&cguid=1432293382119&_=0b0d02c33d2a0c5678b2a943a6e46f3fdc379a9f" --data "UserName=13725269365&Password=${COMMON_PASSWORD}" -c /tmp/139_$$_cookie

SID=`grep -oP '(?<=Os_SSo_Sid\s)\w+' /tmp/139_$$_cookie`


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  mailTest
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
mailTest ()
{
echo "mailing 163..."
echo '<object>
  <object name="attrs">
    <string name="id">0.2619911884889007</string>
    <string name="mid" />
    <string name="messageId" />
    <string name="account">&quot;莫庆强&quot;&lt;kingkongmok@139.com&gt;</string>
    <string name="to">&quot;kk_richinfo&quot;&lt;kk_richinfo@163.com&gt;</string>
    <string name="cc" />
    <string name="bcc" />
    <int name="showOneRcpt">0</int>
    <int name="isHtml">1</int>
    <string name="subject">testmail</string>
    <string name="content">&lt;div style=&quot;font-family: 宋体; font-size: 13px; color: rgb(0, 0, 0); line-height: 1.5;&quot;&gt;&lt;/div&gt;hello world!</string>
    <int name="priority">3</int>
    <int name="signatureId">0</int>
    <int name="stationeryId">0</int>
    <int name="saveSentCopy">1</int>
    <int name="requestReadReceipt">0</int>
    <int name="inlineResources">1</int>
    <int name="scheduleDate">0</int>
    <int name="normalizeRfc822">0</int>
    <array name="attachments">
    </array>
  </object>
  <string name="action">deliver</string>
  <int name="replyNotify">0</int>
  <int name="returnInfo">1</int>
</object>' | curl -s "http://appmail.mail.10086.cn/RmWeb/mail?func=mbox:compose&categroyId=103000000&sid=${SID}&&comefrom=54&guid=05a451b98&cguid=1529366541514" -H "Origin: http://appmail.mail.10086.cn" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.36 Safari/537.36" -H "Content-Type: application/xml" -H "Accept: */*" -H "Referer: http://appmail.mail.10086.cn/m2012/html/compose.html?sid=${SID}" -H "Connection: keep-alive" --compressed --data-binary @- -b /tmp/139_$$_cookie > /dev/null
}	# ----------  end of function mailTest  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  cardTo139
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#------------------------------------------------------------------------------
cardTest ()
{
echo '<object>
  <object name="attrs">
    <string name="to">kk_richinfo@163.com</string>
    <string name="cc" />
    <string name="bcc" />
    <int name="showOneRcpt">1</int>
    <int name="isHtml">1</int>
    <string name="subject">莫庆强为您制作的贺卡《至真情谊》</string>
    <string name="content">&lt;table id=&quot;cardinfo&quot; width=&quot;660&quot; align=&quot;center&quot; style=&quot;background:#FDFBE2; font-size:12px; margin-top:18px&quot;&gt;&lt;tr&gt;&lt;td style=&quot;background-repeat:no-repeat; background-position:center 10px; padding:0 60px 0 55px; vertical-align:top; text-align:center;&quot; background=&quot;http://images.139cm.com/rm/richmail/images/heka_mail_bg.jpg&quot;&gt;&lt;div style=&quot;text-align:right; height:60px; line-height:60px;padding-right:48px&quot;&gt;&lt;a style=&quot;color:#000; font-family:&quot;宋体&quot;&quot; id=&quot;139command_greetingcard3&quot; href=&quot;http://appmail.mail.10086.cn/m2012/html/card/card_writebehavior.html&quot; target=&quot;_blank&quot;&gt;登录139邮箱发送更多贺卡&gt;&gt;&lt;/a&gt;&lt;/div&gt;&lt;h2 style=&quot;font-size:14px; margin:12px 0&quot;&gt;莫庆强为您制作的贺卡《至真情谊》&lt;/h2&gt;&lt;table style=&quot;width:440px; height:330px;margin:0 auto;&quot; cellpadding=&quot;0&quot; cellspacing=&quot;0&quot; border=&quot;0&quot;&gt;&lt;tr&gt;&lt;td style=&quot;background-repeat:no-repeat;background-position:155px 59px;text-align:center&quot; background=&quot;http://images.139cm.com/cximages/card/FlashCard/rh4tobbu.gif&quot; id=&quot;139command_flash&quot; rel=&quot;http://images.139cm.com/cximages/card/FlashCard/hyehbfu4.swf&quot;&gt;&lt;/td&gt;&lt;/tr&gt;&lt;/table&gt;&lt;div style=&quot;margin:24px 0; font-size:14px&quot;&gt;如果您无法查看贺卡，&lt;a style=&quot;color:#369&quot; href=&quot;http://appmail.mail.10086.cn/m2012/html/card/card_readcard.html?resPath=http://images.139cm.com/rm/richmail&amp;link=http://images.139cm.com/cximages/card/FlashCard/hyehbfu4.swf&amp;from="%"E8"%"8E"%"AB"%"E5"%"BA"%"86"%"E5"%"BC"%"BA"%"E4"%"B8"%"BA"%"E6"%"82"%"A8"%"E5"%"88"%"B6"%"E4"%"BD"%"9C"%"E7"%"9A"%"84"%"E8"%"B4"%"BA"%"E5"%"8D"%"A1"%"E3"%"80"%"8A"%"E8"%"87"%"B3"%"E7"%"9C"%"9F"%"E6"%"83"%"85"%"E8"%"B0"%"8A"%"E3"%"80"%"8B&quot; target=&quot;_blank&quot;&gt;点击此处查看&lt;/a&gt;&lt;/div&gt;&lt;div&gt;&lt;a id=&quot;139command_greetingcard1&quot; style=&quot;color:#369&quot; href=&quot;http://appmail.mail.10086.cn/m2012/html/card/card_writebehavior.html&quot; target=&quot;_blank&quot; style=&quot;margin-right:60px&quot;&gt;&lt;img style=&quot;border:none&quot; src=&quot;http://images.139cm.com/rm/richmail/images/heka_mail_bt01.gif&quot; alt=&quot;&quot; /&gt;&lt;/a&gt;&lt;a id=&quot;139command_greetingcard2&quot; style=&quot;color:#369&quot; href=&quot;http://appmail.mail.10086.cn/m2012/html/card/card_writebehavior.html&quot; target=&quot;_blank&quot;&gt;&lt;img style=&quot;border:none&quot; src=&quot;http://images.139cm.com/rm/richmail/images/heka_mail_bt02.gif&quot; alt=&quot;&quot; /&gt;&lt;/a&gt;&lt;/div&gt;&lt;div style=&quot;line-height:1.8; text-align:left; font-size:14px; padding:12px 48px&quot;&gt;&lt;div&gt;有种友情事过境迁依然纯朴&lt;br&gt;有种信任事隔多年依然怀念&lt;br&gt;有种问候清清淡淡却最真诚&lt;br&gt;有种友谊&lt;br&gt;无须挂齿&lt;br&gt;却心领神会&lt;/div&gt;&lt;/div&gt;&lt;/td&gt;&lt;/tr&gt;&lt;/table&gt;&lt;table&gt;&lt;tr&gt;&lt;td background=&quot;http://appmail.mail.10086.cn/m2012/html/card/card_writebehavior.html&quot;&gt;&lt;/td&gt;&lt;/tr&gt;&lt;/table&gt;</string>
    <int name="priority">3</int>
    <int name="requestReadReceipt">0</int>
    <int name="saveSentCopy">1</int>
    <int name="inlineResources">0</int>
    <int name="scheduleDate">0</int>
    <int name="normalizeRfc822">0</int>
    <string name="account">&quot;莫庆强&quot;&lt;kingkongmok@139.com&gt;</string>
  </object>
  <string name="action">deliver</string>
  <int name="returnInfo">1</int>
</object>' | curl -s "http://appmail.mail.10086.cn/RmWeb/mail?func=mbox:compose&comefrom=5&categroyId=102000000&sid=${SID}&&comefrom=54&cguid=1037220992747" -H "Pragma: no-cache" -H "Origin: http://appmail.mail.10086.cn" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.36 Safari/537.36" -H "Content-Type: application/xml" -H "Accept: */*" -H "Cache-Control: no-cache" -H "Referer: http://appmail.mail.10086.cn/m2012/html/index.html?sid=${SID}&rnd=989&tab=mailbox_1&comefrom=54&cguid=1014154934399&mtime=51" -H "Connection: keep-alive" --data-binary @- --compressed -b /tmp/139_$$_cookie > /dev/null
}	# ----------  end of function cardTo139  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  calenderTest
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
calenderTest ()
{
echo '<object>
  <int name="labelId">10</int>
  <int name="seqNo">0</int>
  <int name="recMySms">0</int>
  <int name="recMyEmail">1</int>
  <int name="calendarType">10</int>
  <int name="beforeTime">15</int>
  <int name="beforeType">0</int>
  <int name="sendInterval">0</int>
  <string name="week" />
  <string name="title">hello world</string>
  <string name="site" />
  <string name="content" />
  <string name="dtStart">'`date +"%F %T"`'</string>
  <string name="dtEnd">'`date -d +1hour +"%F %T"`' 00:00:00</string>
  <int name="allDay">0</int>
  <string name="recMobile">13725269365</string>
  <string name="recEmail">kingkongmok@139.com</string>
  <int name="enable">0</int>
  <string name="validImg" />
  <int name="isNotify">0</int>
  <null name="inviteInfo" />
  <int name="comeFrom">0</int>
</object>' | curl -s "http://smsrebuild1.mail.10086.cn/calendar/s?func=calendar:addCalendar&sid=${SID}&&comefrom=54&cguid=1056517650283" -H "Pragma: no-cache" -H "Origin: http://smsrebuild1.mail.10086.cn" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.36 Safari/537.36" -H "Content-Type: application/xml" -H "Accept: */*" -H "Cache-Control: no-cache" -H "Referer: http://smsrebuild1.mail.10086.cn//proxy.htm" -H "Connection: keep-alive" --data-binary @- -b /tmp/139_$$_cookie




}	# ----------  end of function calenderTest  ----------


mailTest
cardTest
calenderTest

[ -w /tmp/139_$$_cookie ] && rm /tmp/139_$$_cookie 



