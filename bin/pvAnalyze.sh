#!/bin/sh

/home/moqingqiang/bin/tomcatPVAnalyze.pl
/home/moqingqiang/bin/tomcatHistoryAnalyze.pl
/home/moqingqiang/bin/tomcatSizeAnalyze.pl
/home/moqingqiang/bin/tomcat200.pl
/home/moqingqiang/bin/tomcat400.pl
/home/moqingqiang/bin/tomcat500.pl
/home/moqingqiang/bin/tomcatRespTime.pl

for i in /tmp/tomcatHistory.png /tmp/tomcatPV.png /tmp/tomcatLogSize.png /tmp/tomcat200.png /tmp/tomcat400.png /tmp/tomcat500.png /tmp/tomcat-resp.png; do echo -en "<img src=\"data:image/png;base64," `base64 $i` "\"\>\n" ; done > /tmp/pv_mail.txt

cp -a /home/logs/1_mmlogs/crontabLog/http_status_code.log.1.gz /home/moqingqiang/tmp/`date +%F -d -1day`-42.1.log.gz
cp -a /home/logs/4_mmlogs/crontabLog/http_status_code.log.1.gz /home/moqingqiang/tmp/`date +%F -d -1day`-42.2.log.gz
cp -a /home/logs/3_mmlogs/crontabLog/http_status_code.log.1.gz /home/moqingqiang/tmp/`date +%F -d -1day`-42.3.log.gz
cp -a /home/logs/5_mmlogs/crontabLog/http_status_code.log.1.gz /home/moqingqiang/tmp/`date +%F -d -1day`-42.5.log.gz

/home/moqingqiang/local/mutt-1.5.23/bin/mutt -e "set content_type=text/html" -s "mmSdk pv analyze" -a /home/moqingqiang/tmp/`date +%F -d -1day`-42.*.log.gz -- dengjs@richinfo.cn suzhiwen@richinfo.cn luoxiangyue@richinfo.cn moqingqiang@richinfo.cn <  /tmp/pv_mail.txt
