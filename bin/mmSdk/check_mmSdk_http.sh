#!/bin/sh

MOUNTPORT=`df | perl -nae 'print "$F[-1]\n" if $F[-1] =~ /\/mmsdk/i'`
exec 1>> ${MOUNTPORT}/crontabLog/http_error.log 2>&1
for k in 1 2 3 5 ; do for i in 77{11,22,33,44} 8090; do [ "`curl 192.168.42.${k}:${i}/udata/checkhealth.jsp -is | grep -iP http.*200`" ] || echo `date +"%F %T"` 192.168.42.${k}:${i} error ; done; done
