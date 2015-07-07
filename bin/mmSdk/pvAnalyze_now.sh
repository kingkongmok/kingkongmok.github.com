#!/bin/sh



#-------------------------------------------------------------------------------
#  sending mail as /tmp/pv_mail_now.txt and PNGs append on it.
#-------------------------------------------------------------------------------

SUBJ=${*:-"testing mmSdk pv analyze today"}

/opt/mmSdk/bin/tomcat200_now.pl
/opt/mmSdk/bin/tomcat400_now.pl
/opt/mmSdk/bin/tomcat500_now.pl
/opt/mmSdk/bin/tomcatRespTime_now.pl
/opt/mmSdk/bin/tomcatMethod_now.pl
/opt/mmSdk/bin/tomcatMethodSmall_now.pl
/opt/mmSdk/bin/nginxPvCheck.pl -p

find  /home/logs/*_mmlogs/crontabLog/ -name \*log -mtime -1 | xargs tar Pczf /tmp/pvAnalyze_today.tar.gz 

echo -e "\n\n<H1>================== logs today below==================</H1>\n\n" >> /tmp/pv_mail_now.txt
for i in /tmp/nginxPVHourly.png  /tmp/nginxPVToday.png /tmp/nginxPVPerServerHourly.png /tmp/nginxPVPerServerToday.png /tmp/tomcat200_now.png /tmp/tomcat400_now.png /tmp/tomcat500_now.png /tmp/tomcat-resp_now.png /tmp/tomcatMethod_now.png /tmp/tomcatMethodSmall_now.png ; do echo -en "<img src=\"data:image/png;base64," `base64 $i` "\"\>\n" ; done >> /tmp/pv_mail_now.txt

/opt/mmSdk/local/mutt-1.5.23/bin/mutt -e "set content_type=text/html" -s "$SUBJ" -a /tmp/pvAnalyze_today.tar.gz -- moqingqiang@richinfo.cn  <  /tmp/pv_mail_now.txt
rm /tmp/pv_mail_now.txt
