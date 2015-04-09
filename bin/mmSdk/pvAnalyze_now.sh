#!/bin/sh

SUBJ=${*:-"testing mmSdk pv analyze today"}

/opt/mmSdk/bin/tomcat200_now.pl
/opt/mmSdk/bin/tomcat400_now.pl
/opt/mmSdk/bin/tomcat500_now.pl
/opt/mmSdk/bin/tomcatRespTime_now.pl
/opt/mmSdk/bin/tomcatMethod_now.pl

find  /home/logs/*_mmlogs/crontabLog/ -name \*log -mtime -1 | xargs tar Pczf /tmp/pvAnalyze_today.tar.gz 

for i in /tmp/tomcat200_now.png /tmp/tomcat400_now.png /tmp/tomcat500_now.png /tmp/tomcat-resp_now.png /tmp/tomcatMethod_now.png ; do echo -en "<img src=\"data:image/png;base64," `base64 $i` "\"\>\n" ; done > /tmp/pv_mail_now.txt

/opt/mmSdk/local/mutt-1.5.23/bin/mutt -e "set content_type=text/html" -s "$SUBJ" -a /tmp/pvAnalyze_today.tar.gz -- moqingqiang@richinfo.cn  <  /tmp/pv_mail_now.txt
