#!/bin/sh
[ "`cat /home/logs/*/crontabLog/http_error.log`" ] && echo -e "Subject: mmSdk_http_error_logs\n\n`sort -u /home/logs/*/crontabLog/http_error.log`"  | /usr/local/bin/msmtp moqingqiang@richinfo.cn
