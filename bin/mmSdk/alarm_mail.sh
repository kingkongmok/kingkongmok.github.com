#!/bin/sh

#-------------------------------------------------------------------------------
# 默认邮件的subject为error，通过$*修改
#-------------------------------------------------------------------------------
SUBJ=${*:-"error"}


#-------------------------------------------------------------------------------
# 默认的邮件内容为some errors may occured，
# 通过修改MAIL_CONTENT_LOCATION的文件来获得，邮件发送后删除。
#-------------------------------------------------------------------------------
MAIL_CONTENT_LOCATION="/tmp/alarm_mail.txt"

if [ -w $MAIL_CONTENT_LOCATION ] ; then
    /opt/mmSdk/local/mutt-1.5.23/bin/mutt -e "set content_type=text/html" -s \
    "$SUBJ" -- "13725269365@139.com"  <  $MAIL_CONTENT_LOCATION 
    rm $MAIL_CONTENT_LOCATION
    exit 0
fi

echo "some errors may occured" | /opt/mmSdk/local/mutt-1.5.23/bin/mutt -e "set \
content_type=text/html" -s "$SUBJ" -- "13725269365@139.com" 
