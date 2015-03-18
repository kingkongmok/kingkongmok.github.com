#!/bin/sh

/home/moqingqiang/bin/tomcatPVAnalyze.pl
/home/moqingqiang/bin/tomcatHistoryAnalyze.pl
/home/moqingqiang/bin/tomcatSizeAnalyze.pl
/home/moqingqiang/bin/tomcat200.pl
/home/moqingqiang/bin/tomcat400.pl
/home/moqingqiang/bin/tomcat500.pl

for i in /tmp/tomcatHistory.png /tmp/tomcatPV.png /tmp/tomcatLogSize.png /tmp/tomcat200.png /tmp/tomcat400.png /tmp/tomcat500.png ; do echo -en "<img src=\"data:image/png;base64," `base64 $i` "\"\>\n" ; done > /tmp/pv_mail.txt

/home/moqingqiang/local/mutt-1.5.23/bin/mutt -e "set content_type=text/html" -s "mmSdk pv analyze"  moqingqiang@richinfo.cn <  /tmp/pv_mail.txt
