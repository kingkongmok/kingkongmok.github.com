#!/bin/sh



#-------------------------------------------------------------------------------
#  sending mail as /tmp/pv_mail_now.txt and PNGs append on it.
#-------------------------------------------------------------------------------

SUBJ=${*:-"testing nginx status"}


echo -e "\n\n<H1>================== logs today below==================</H1>\n\n" >> /tmp/nginx_status_now.txt
for i in /tmp/nginxPVHourly.png  /tmp/nginxPVToday.png ; do echo -en "<img src=\"data:image/png;base64," `base64 $i` "\"\>\n" ; done >> /tmp/nginx_status_now.txt

mutt -e "set content_type=text/html" -s "$SUBJ" -- moqingqiang@richinfo.cn  <  /tmp/nginx_status_now.txt
rm /tmp/nginx_status_now.txt
