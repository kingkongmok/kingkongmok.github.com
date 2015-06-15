#!/bin/sh



#-------------------------------------------------------------------------------
#  sending mail as /tmp/pv_mail_now.txt and PNGs append on it.
#-------------------------------------------------------------------------------

SUBJ=${*:-"testing nginx status"}


find  /home/logs/*_mmlogs/crontabLog/ -name \*log -mtime -1 | xargs tar Pczf /tmp/pvAnalyze_today.tar.gz 

echo -e "\n\n<H1>================== logs today below==================</H1>\n\n" >> /tmp/nginx_status_now.txt
for i in /tmp/nginx*.png ; do echo -en "<img src=\"data:image/png;base64," `base64 $i` "\"\>\n" ; done >> /tmp/nginx_status_now.txt

/opt/mmSdk/local/mutt-1.5.23/bin/mutt -e "set content_type=text/html" -s "$SUBJ" -a /tmp/pvAnalyze_today.tar.gz -- moqingqiang@richinfo.cn  <  /tmp/nginx_status_now.txt
rm /tmp/nginx_status_now.txt
