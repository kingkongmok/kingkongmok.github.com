#!/bin/sh

/home/moqingqiang/bin/tomcat200_now.pl
/home/moqingqiang/bin/tomcat400_now.pl
/home/moqingqiang/bin/tomcat500_now.pl
/home/moqingqiang/bin/tomcatRespTime_now.pl
/home/moqingqiang/bin/tomcatMethod_now.pl

find  /home/logs/*_mmlogs/crontabLog/ -name \*log -mtime -1 | xargs tar czf /tmp/pvAnalyze_today.tar.gz 

for i in /tmp/tomcat200_now.png /tmp/tomcat400_now.png /tmp/tomcat500_now.png /tmp/tomcat-resp_now.png /tmp/tomcatMethod_now.png ; do echo -en "<img src=\"data:image/png;base64," `base64 $i` "\"\>\n" ; done > /tmp/pv_mail_now.txt

/home/moqingqiang/local/mutt-1.5.23/bin/mutt -e "set content_type=text/html" -s "testing mmSdk pv analyze today" -a /tmp/pvAnalyze_today.tar.gz -- moqingqiang@richinfo.cn  <  /tmp/pv_mail_now.txt
