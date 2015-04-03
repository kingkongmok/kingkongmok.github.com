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
#set -x

SMS_TRIGER=
MMS_TRIGER=
VERBOSE=

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


KK_VAR=/home/kk/.kk_var
[ -f $KK_VAR ] && . $KK_VAR
TIMESTAMP=`date -d +1day +"%F %T"`


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  Login139
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
Login139 ()
{
    if [ "`curl -s "https://mail.10086.cn/Login/Login.ashx?_fv=4&cguid=1010337360142&_=9f2d37c2a18a0537387efb0370d352b4f710a07f" -H "Origin: http://mail.10086.cn" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.36 Safari/537.36" -H "Content-Type: application/x-www-form-urlencoded" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Cache-Control: max-age=0" -H "Referer: http://mail.10086.cn/" -H "Connection: keep-alive" --data "UserName=kingkongmok&Password=${COMMON_PASSWORD}&VerifyCode=" --compressed -c /tmp/139_$$_cookie | grep S_OK` " ]  ; then
    SID=`grep -oP '(?<=Os_SSo_Sid\s)\w+' /tmp/139_$$_cookie`
    echo ' login success sid = '$SID
    fi
    if [ -z "$SID" ] ; then
        echo login fail
        exit 68
    fi
}	# ----------  end of function Login139  ----------

#curl -s "https://mail.10086.cn/Login/Login.ashx?_fv=4&cguid=1432293382119&_=0b0d02c33d2a0c5678b2a943a6e46f3fdc379a9f" --data "UserName=13725269365&Password=${COMMON_PASSWORD}" -c /tmp/139_$$_cookie
#SID=`grep -oP '(?<=Os_SSo_Sid\s)\w+' /tmp/139_$$_cookie`
#echo 'sid = '$SID



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  composeHtml
#   DESCRIPTION:  01/26/2015 10:47:03 AM CST 不能使用，无response
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
composeHtml ()
{
    if [ `curl -s "http://appmail.mail.10086.cn/m2012/html/compose.html?sid=${SID}" -H "Pragma: no-cache" -b /tmp/139_$$_cookie -H "Accept-Encoding: gzip, deflate, sdch" -H "Accept-Language: en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2" -H "User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Cache-Control: no-cache" -H "Referer: http://appmail.mail.10086.cn/m2012/html/index.html?sid=${SID}&rnd=134&tab=mailbox_1&comefrom=54&cguid=0926122164703&mtime=137" -H "Proxy-Connection: keep-alive" --compressed ` ] ; then
    echo compose:html success
    else
        echo compose:html fail
    fi
}	# ----------  end of function composeHtml  ----------



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  mbox_compose
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
mbox_compose ()
{
    
    if [ "`echo '<object>
  <object name="attrs">
    <string name="id">0.509468958247453</string>
    <string name="mid" />
    <string name="messageId" />
    <string name="account">&quot;莫庆强&quot;&lt;kingkongmok@139.com&gt;</string>
    <string name="to">&quot;ayanami_0&quot;&lt;ayanami_0@163.com&gt;</string>
    <string name="cc" />
    <string name="bcc" />
    <int name="showOneRcpt">0</int>
    <int name="isHtml">1</int>
    <string name="subject">testmail</string>
    <string name="content">&lt;div style=&quot;font-family: 宋体; font-size: 13px; color: rgb(0, 0, 0); line-height: 1.5;&quot;&gt;&lt;br&gt;&lt;br&gt;&lt;br&gt;&lt;/div&gt;&lt;div id=&quot;signContainer&quot;&gt;&lt;table border=&quot;0&quot; style=&quot;width:auto;font-family:'宋体';font-size:12px;border:1px solid #b5cbdd;-webkit-border-radius:5px;line-height:21px;background-color:#f8fcff;flaot:left;&quot;&gt;&lt;tbody&gt;&lt;tr&gt;&lt;td style=&quot;vertical-align:top;padding:5px;&quot;&gt;&lt;img rel=&quot;signImg&quot; width=&quot;96&quot; height=&quot;96&quot; src=&quot;http://172.16.172.171:2080/Upload/Photo/137252/137252693/13725269365/111120140813153246slg6.jpg&quot; data-mark=&quot;empty&quot; id=&quot;img_0.541015864117071&quot;&gt;&lt;/td&gt;&lt;td style=&quot;padding:5px;&quot;&gt;&lt;table style=&quot;font-size:12px;line-height:19px;table-layout:auto;&quot;&gt;&lt;tbody&gt;&lt;tr&gt;&lt;td colspan=&quot;2&quot;&gt;&lt;strong id=&quot;dzmp_unm&quot; style=&quot;font-size:14px;&quot;&gt;莫庆强&lt;/strong&gt;&lt;/td&gt;&lt;/tr&gt;&lt;tr&gt;&lt;td colspan=&quot;2&quot; style=&quot;padding-bottom:5px;&quot;&gt;个性签名&lt;/td&gt;&lt;/tr&gt;&lt;tr&gt;&lt;td&gt;职务：&lt;/td&gt;&lt;td&gt;系统维护工程师&lt;/td&gt;&lt;/tr&gt;&lt;tr&gt;&lt;td&gt;公司：&lt;/td&gt;&lt;td&gt;深圳市彩讯科技有限公司&lt;/td&gt;&lt;/tr&gt;&lt;tr&gt;&lt;td&gt;邮箱：&lt;/td&gt;&lt;td&gt;13725269365@139.com&lt;/td&gt;&lt;/tr&gt;&lt;tr&gt;&lt;td&gt;手机：&lt;/td&gt;&lt;td&gt;13725269365&lt;/td&gt;&lt;/tr&gt;&lt;/tbody&gt;&lt;/table&gt;&lt;/td&gt;&lt;/tr&gt;&lt;/tbody&gt;&lt;/table&gt;&lt;/div&gt;</string>
    <int name="priority">3</int>
    <int name="signatureId">0</int>
    <int name="stationeryId">0</int>
    <int name="saveSentCopy">1</int>
    <int name="requestReadReceipt">0</int>
    <int name="inlineResources">1</int>
    <int name="scheduleDate">0</int>
    <int name="normalizeRfc822">0</int>
    <array name="remoteAttachment">
      <string>http://172.16.172.171:2080/Upload/Photo/137252/137252693/13725269365/111120140813153246slg6.jpg</string>
    </array>
    <array name="attachments">
    </array>
  </object>
  <string name="action">deliver</string>
  <int name="replyNotify">0</int>
  <int name="returnInfo">1</int>
</object>' | curl -s "http://appmail.mail.10086.cn/RmWeb/mail?func=mbox:compose&categroyId=103000000&sid=${SID}&&comefrom=54&guid=057104879&cguid=1122537396519" -H "Pragma: no-cache"  -H "Origin: http://appmail.mail.10086.cn" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2" -H "User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36" -H "Content-Type: application/xml" -H "Accept: */*" -H "Cache-Control: no-cache" -H "Referer: http://appmail.mail.10086.cn/m2012/html/compose.html?sid=${SID}" -H "Proxy-Connection: keep-alive" -b /tmp/139_$$_cookie --data-binary @- --compressed | grep S_OK`" ] ; then
    echo mbox_compose success
    else 
        echo mbox_compose fail
    fi
}	# ----------  end of function mbox_compose  ----------

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  mailTest
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
mboxCompose ()
{
    if [ " `echo '<object>
  <object name="attrs">
    <string name="id">0.2619911884889007</string>
    <string name="mid" />
    <string name="messageId" />
    <string name="account">&quot;莫庆强&quot;&lt;kingkongmok@139.com&gt;</string>
    <string name="to">&quot;ayanami_0&quot;&lt;ayanami_0@163.com&gt;</string>
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
</object>' | curl -s "http://appmail.mail.10086.cn/RmWeb/mail?func=mbox:compose&categroyId=103000000&sid=${SID}&&comefrom=54&guid=05a451b98&cguid=1529366541514" -H "Origin: http://appmail.mail.10086.cn" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.36 Safari/537.36" -H "Content-Type: application/xml" -H "Accept: */*" -H "Referer: http://appmail.mail.10086.cn/m2012/html/compose.html?sid=${SID}" -H "Connection: keep-alive" --compressed --data-binary @- -b /tmp/139_$$_cookie  | grep S_OK` " ] ; then
    echo mbox:compose success
    else
        echo mbox:compose fail
    fi
}	# ----------  end of function mailTest  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  smsTest
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
smsTest ()
{
if [ "` echo '<object><int name="doubleMsg">0</int><int name="submitType">1</int><string name="smsContent">sms testing...</string><string name="receiverNumber">8613725269365</string><string name="comeFrom">104</string><int name="sendType">0</int><int name="smsType">1</int><int name="serialId">-1</int><int name="isShareSms">0</int><string name="sendTime"></string><string name="validImg"></string><int name="groupLength">10</int><int name="isSaveRecord">1</int></object>' | curl -s "http://smsrebuild1.mail.10086.cn/sms/sms?func=sms:sendSms&sid=${SID}&rnd=0.8170706790406257&cguid=1521425490499" -H "Pragma: no-cache" -H "Origin: http://smsrebuild1.mail.10086.cn" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.36 Safari/537.36" -H "Content-Type: application/xml;charset=UTF-8" -H "Accept: */*" -H "Cache-Control: no-cache" -H "Referer: http://smsrebuild1.mail.10086.cn//proxy.htm" -H "Connection: keep-alive" --data-binary @- --compressed -b /tmp/139_$$_cookie | grep S_OK `" ] ; then
    echo smsTest success
    else
        echo smsTest fail
    fi
}	# ----------  end of function smsTest  ----------



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  mmsTest
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
mmsTest ()
{
if [ "` echo '<object>  <int name="style">0</int>  <int name="size">2</int>  <string name="content">helloThere.</string>  <string name="validate" />  <string name="title">mmsTesting</string>  <string name="receiverNumber">13725269365</string>  <int name="sendType">0</int>  <string name="sendTime" />
</object>' | curl -s "http://smsrebuild1.mail.10086.cn/mms/s?func=mms:mmsWord&sid=${SID}&cguid=1602172305686" -H "Pragma: no-cache" -H "Origin: http://smsrebuild1.mail.10086.cn" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.36 Safari/537.36" -H "Content-Type: application/xml;charset:utf-8" -H "Accept: */*" -H "Cache-Control: no-cache" -H "Referer: http://smsrebuild1.mail.10086.cn//proxy.htm" -H "Connection: keep-alive" --compressed --data-binary @- -b /tmp/139_$$_cookie | grep S_OK `" ] ; then
    echo mmsTest success
    else
        echo mmsTest fail
    fi
}	# ----------  end of function mmsTest  ----------

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  cardTo139
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#------------------------------------------------------------------------------
cardTest ()
{
if [ "` echo '<object>
  <object name="attrs">
    <string name="to">ayanami_0@163.com</string>
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
</object>' | curl -s "http://appmail.mail.10086.cn/RmWeb/mail?func=mbox:compose&comefrom=5&categroyId=102000000&sid=${SID}&&comefrom=54&cguid=1037220992747" -H "Pragma: no-cache" -H "Origin: http://appmail.mail.10086.cn" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.36 Safari/537.36" -H "Content-Type: application/xml" -H "Accept: */*" -H "Cache-Control: no-cache" -H "Referer: http://appmail.mail.10086.cn/m2012/html/index.html?sid=${SID}&rnd=989&tab=mailbox_1&comefrom=54&cguid=1014154934399&mtime=51" -H "Connection: keep-alive" --data-binary @- --compressed -b /tmp/139_$$_cookie | grep S_OK`" ]; then
    echo cardsend success
    else
        echo cardsend fail
fi
}	# ----------  end of function cardTo139  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  calenderTest
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
calenderTest ()
{
if [ "`echo '<object>
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
  <string name="dtStart">'$(date +"%F %T")'</string>
  <string name="dtEnd">'$(date -d +1hour +"%F %T")' 00:00:00</string>
  <int name="allDay">0</int>
  <string name="recMobile">13725269365</string>
  <string name="recEmail">kingkongmok@139.com</string>
  <int name="enable">0</int>
  <string name="validImg" />
  <int name="isNotify">0</int>
  <null name="inviteInfo" />
  <int name="comeFrom">0</int>
</object>' | curl -s "http://smsrebuild1.mail.10086.cn/calendar/s?func=calendar:addCalendar&sid=${SID}&&comefrom=54&cguid=1056517650283" -H "Pragma: no-cache" -H "Origin: http://smsrebuild1.mail.10086.cn" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.36 Safari/537.36" -H "Content-Type: application/xml" -H "Accept: */*" -H "Cache-Control: no-cache" -H "Referer: http://smsrebuild1.mail.10086.cn//proxy.htm" -H "Connection: keep-alive" --data-binary @- -b /tmp/139_$$_cookie | grep S_OK`" ]; then
    echo calenderTest success
    else
        echo calenderTest fail
fi
}	# ----------  end of function calenderTest  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  listMessages
#   DESCRIPTION:  maibox list message.
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
listMessages ()
{

echo "listMessages processing..."
if [ "` echo '<object>
  <int name="fid">1</int>
  <string name="order">receiveDate</string>
  <string name="desc">1</string>
  <int name="start">1</int>
  <int name="total">100</int>
  <string name="topFlag">top</string>
  <int name="sessionEnable">2</int>
</object>' | curl -s "http://appmail.mail.10086.cn/s?func=mbox:listMessages&sid=${SID}&&comefrom=54&cguid=1143113376506" -H "Pragma: no-cache" -H "Origin: http://appmail.mail.10086.cn" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.36 Safari/537.36" -H "Content-Type: application/xml" -H "Accept: */*" -H "Cache-Control: no-cache" -H "Referer: http://appmail.mail.10086.cn/m2012/html/index.html?sid=${SID}&rnd=989&tab=mailbox_1&comefrom=54&cguid=1014154934399&mtime=51" -H "Connection: keep-alive" --data-binary @- --compressed -b /tmp/139_$$_cookie | grep S_OK `" ]; then
    echo listMessages success
    else
        echo listMessages fail
fi
}	# ----------  end of function listMessages  ----------



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  together_getFetionLoginInfo
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
together_getFetionLoginInfo ()
{
if [ "` echo '<object>
</object>' | curl -s "http://smsrebuild1.mail.10086.cn/together/s?func=user:getFetionLoginInfo&sid=${SID}&&comefrom=54&cguid=1400523550372" -H "Pragma: no-cache" -H "Origin: http://smsrebuild1.mail.10086.cn" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.36 Safari/537.36" -H "Content-Type: application/xml" -H "Accept: */*" -H "Cache-Control: no-cache" -H "Referer: http://smsrebuild1.mail.10086.cn//proxy.htm" -H "Connection: keep-alive" --data-binary @- --compressed  -b /tmp/139_$$_cookie | grep S_OK`" ]; then
    echo together_getFetionLoginInfo success
    else
        echo together_getFetionLoginInfo fail
fi
}	# ----------  end of function together_getFetionLoginInfo  ----------



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  setting_getArtifact
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
setting_getArtifact ()
{
if [ "` echo '<object>
</object>' | curl -s "http://smsrebuild1.mail.10086.cn/setting/s?func=umc:getArtifact&sid=${SID}&&comefrom=54&cguid=1400410898845" -H "Pragma: no-cache" -H "Origin: http://smsrebuild1.mail.10086.cn" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.36 Safari/537.36" -H "Content-Type: application/xml" -H "Accept: */*" -H "Cache-Control: no-cache" -H "Referer: http://smsrebuild1.mail.10086.cn//proxy.htm" -H "Connection: keep-alive" --data-binary @- -b /tmp/139_$$_cookie --compressed  | grep S_OK `" ]; then
    echo setting_getArtifact success
    else
        echo setting_getArtifact fail
fi
}	# ----------  end of function setting_getArtifact  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  mnote_updateNote
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
mnote_updateNote ()
{
if [ "` echo '<object>
  <string name="title">testNode</string>
  <string name="content">hereIsATest.</string>
  <string name="attachmentDirId" />
  <string name="noteId">fe4d9c0df9656c1c0e34f479296007e2</string>
</object>' | curl -s "http://smsrebuild1.mail.10086.cn/file/mnote?func=mnote:updateNote&sid=${SID}&&comefrom=54&cguid=1609280424672" -H "Pragma: no-cache" -H "Origin: http://smsrebuild1.mail.10086.cn" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.36 Safari/537.36" -H "Content-Type: application/xml" -H "Accept: */*" -H "Cache-Control: no-cache" -H "Referer: http://smsrebuild1.mail.10086.cn//proxy.htm" -H "Connection: keep-alive" --compressed --data-binary @- -b /tmp/139_$$_cookie | grep S_OK`" ] ; then
    echo mnote_updateNote success
    else
        echo mnote_updateNote fail
fi
}	# ----------  end of function mnote_updateNote  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  bmail_searchMessages
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
bmail_searchMessages ()
{
if [ "` echo '<object>
  <int name="fid">0</int>
  <int name="recursive">0</int>
  <int name="ignoreCase">0</int>
  <int name="isSearch">1</int>
  <int name="isFullSearch">1</int>
  <int name="start">1</int>
  <int name="total">100</int>
  <int name="limit">1000</int>
  <string name="order">receiveDate</string>
  <string name="desc">1</string>
  <array name="condictions">
    <object>
      <string name="field">from</string>
      <string name="operator">contains</string>
      <string name="value">ex</string>
    </object>
  </array>
  <int name="statType">1</int>
</object>' | curl -s "http://appmail.mail.10086.cn/bmail/s?func=mbox:searchMessages&sid=${SID}&&comefrom=54&cguid=1727319858459" -H "Pragma: no-cache" -H "Origin: http://appmail.mail.10086.cn" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.36 Safari/537.36" -H "Content-Type: application/xml" -H "Accept: */*" -H "Cache-Control: no-cache" -H "Referer: http://appmail.mail.10086.cn/m2012/html/index.html?sid=${SID}&rnd=101&tab=mailbox_1&comefrom=54&cguid=1436200773470&mtime=60" -H "Connection: keep-alive" --data-binary @- --compressed -b /tmp/139_$$_cookie | grep S_OK `" ] ; then
echo bmail_searchMessages success
else
    echo bmail_searchMessages fail
fi
}	# ----------  end of function bmail_searchMessages  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  writeOK
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
writeOK ()
{
    if [ "`curl -s "http://appmail.mail.10086.cn/m2012/html/write_ok_new.html?sid=${SID}&inputData=0.6573257776908576&tid=2b04548f8a3555e-00009" -H "Pragma: no-cache" -b /tmp/139_$$_cookie -H "Accept-Encoding: gzip, deflate, sdch" -H "Accept-Language: en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2" -H "User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Cache-Control: no-cache" -H "Referer: http://appmail.mail.10086.cn/m2012/html/compose.html?sid=${SID}" -H "Proxy-Connection: keep-alive" --compressed | grep writeOk_box`" ] ; then
    echo writeOK success
    else
        echo writeOK fail
    fi
}	# ----------  end of function writeOK  ----------

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  file_getFiles
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
file_getFiles ()
{
if [ "`echo '<object>
  <int name="actionId">0</int>
  <string name="imageSize">80*90</string>
</object>' | curl -s "http://smsrebuild1.mail.10086.cn/file/disk?func=file:getFiles&sid=${SID}&&comefrom=54&cguid=1439320460586" -H "Pragma: no-cache" -H "Origin: http://smsrebuild1.mail.10086.cn" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.36 Safari/537.36" -H "Content-Type: application/xml" -H "Accept: */*" -H "Cache-Control: no-cache" -H "Referer: http://smsrebuild1.mail.10086.cn//proxy.htm" -H "Connection: keep-alive" --data-binary @- -b /tmp/139_$$_cookie --compressed | grep S_OK `" ] ; then
    echo file_getFiles success
    else
        echo file_getFiles fail
fi
}	# ----------  end of function file_getFiles  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  uec_index
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
uec_index ()
{
    if [ "` curl -s "http://uec.mail.10086.cn/uec/indexLoadNoLogin.do" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Referer: http://uec.mail.10086.cn/uec/" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.36 Safari/537.36" --compressed | grep S_OK`" ] ; then
    echo uec_index success
    fi
}	# ----------  end of function uec_index  ----------

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  logout
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
logout139 ()
{
echo "logout139 processing..."
   curl -s "http://mail.10086.cn/login/Logout.aspx?sid=${SID}&redirect=http"%"3A"%"2F"%"2Fmail.10086.cn"%"2Flogout.htm"%"3Fcode"%"3D1_22" -H "Pragma: no-cache" -H "Accept-Encoding: gzip, deflate, sdch" -H "Accept-Language: en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2" -H "User-Agent: Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.36 Safari/537.36" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Referer: http://appmail.mail.10086.cn/m2012/html/index.html?sid=${SID}&rnd=347&tab=mailbox_1&comefrom=54&cguid=1418084572390&mtime=46" -H "Connection: keep-alive" -H "Cache-Control: no-cache" --compressed -b /tmp/139_$$_cookie 
}	# ----------  end of function logout  ----------

Login139
listMessages 
if [ "$SMS_TRIGER" ] ; then
    smsTest
fi

if [ "$MMS_TRIGER" ]  ; then
    mmsTest
fi
#composeHtml
mbox_compose
#mboxCompose
writeOK
cardTest
calenderTest
together_getFetionLoginInfo
setting_getArtifact
mnote_updateNote
bmail_searchMessages
file_getFiles
uec_index
logout139


[ -w /tmp/139_$$_cookie ] && rm /tmp/139_$$_cookie 
