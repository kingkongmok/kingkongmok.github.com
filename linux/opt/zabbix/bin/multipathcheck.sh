

#!/bin/bash
sudo /sbin/multipath -ll >/dev/null 2>&1
if [ $? -eq 0 ]; then
     mulp=`sudo /sbin/multipath -ll|grep -c -E "fault|fail|inactive" |wc -l`
else
    mulp=0
fi
echo $mulp
