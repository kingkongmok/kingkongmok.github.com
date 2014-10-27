#!/bin/bash
[ -r ~/.kk_var ] && . ~/.kk_var
curl -u "${COMMON_USERNAME}:${COMMON_PASSWORD}" 'http://192.168.1.1/userRpm/StatusRpm.htm'  -H 'Accept-Encoding: gzip,deflate,sdch' -H 'Accept-Language: en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2' -H 'User-Agent: Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Referer: http://192.168.1.1/userRpm/MenuRpm.htm' -H 'Proxy-Connection: keep-alive' --compressed -s | perl -nlae 'print $F[2] =~ s/\"(.*)\",/$1/r if $.==40'


