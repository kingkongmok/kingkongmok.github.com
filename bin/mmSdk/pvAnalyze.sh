#!/bin/sh

/opt/mmSdk/bin/tomcatPVAnalyze.pl
/opt/mmSdk/bin/tomcatHistoryAnalyze.pl
/opt/mmSdk/bin/tomcatSizeAnalyze.pl
/opt/mmSdk/bin/tomcat200.pl
/opt/mmSdk/bin/tomcat400.pl
/opt/mmSdk/bin/tomcat500.pl
/opt/mmSdk/bin/tomcatRespTime.pl
/opt/mmSdk/bin/tomcatMethod.pl
/opt/mmSdk/bin/tomcatMethodSmall.pl

for i in /tmp/tomcatHistory.png /tmp/tomcatPV.png /tmp/tomcatLogSize.png /tmp/tomcat200.png /tmp/tomcat400.png /tmp/tomcat500.png /tmp/tomcat-resp.png /tmp/tomcatMethod.png /tmp/tomcatMethodSmall.png /tmp/nginxPVToday_full.png; do echo -en "<img src=\"data:image/png;base64," `base64 $i` "\"\>\n" ; done > /tmp/pv_mail.txt
echo -e "\n\n<H1>================== nginx requests below==================</H1>\n\n" >> /tmp/pv_mail.txt
cat /tmp/nginx_status_today.txt >> /tmp/pv_mail.txt


cp -a /home/logs/1_mmlogs/crontabLog/http_status_code.log.1.gz /opt/mmSdk/tmp/`date +%F -d -1day`-42.1.log.gz
cp -a /home/logs/4_mmlogs/crontabLog/http_status_code.log.1.gz /opt/mmSdk/tmp/`date +%F -d -1day`-42.2.log.gz
cp -a /home/logs/3_mmlogs/crontabLog/http_status_code.log.1.gz /opt/mmSdk/tmp/`date +%F -d -1day`-42.3.log.gz
cp -a /home/logs/5_mmlogs/crontabLog/http_status_code.log.1.gz /opt/mmSdk/tmp/`date +%F -d -1day`-42.5.log.gz

/opt/mmSdk/local/mutt-1.5.23/bin/mutt -e "set content_type=text/html" -s "mmSdk pv analyze" -a /opt/mmSdk/tmp/`date +%F -d -1day`-42.*.log.gz -- dengjs@richinfo.cn suzhiwen@richinfo.cn luoxiangyue@richinfo.cn moqingqiang@richinfo.cn <  /tmp/pv_mail.txt
