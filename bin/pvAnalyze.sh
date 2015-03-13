#!/bin/sh

/home/moqingqiang/bin/tomcatPVAnalyze.pl
/home/moqingqiang/bin/tomcatHistoryAnalyze.pl
/home/moqingqiang/bin/tomcatSizeAnalyze.pl

cat /home/moqingqiang/bin/analyze.html | /home/moqingqiang/local/mutt-1.5.23/bin/mutt -e "set content_type=text/html" -s "mmSdk pv analyze" -a /tmp/tomcatPV.png /tmp/tomcatHistory.png  /tmp/tomcatLogSize.png --  moqingqiang@richinfo.cn
#cat /home/moqingqiang/bin/analyze.html | /home/moqingqiang/local/mutt-1.5.23/bin/mutt -e "set content_type=text/html" -s "mmSdk pv analyze" --  moqingqiang@richinfo.cn

