#!/bin/bash
#in
rx1=$(cat /proc/net/dev |sed -e'1,2d'|egrep -v 'lo:|bond'|awk '{sum+=$2}END{printf "%.0f\n",sum}')

sleep 1

rx2=$(cat /proc/net/dev |sed -e'1,2d'|egrep -v 'lo:|bond'|awk '{sum+=$2}END{printf "%.0f\n",sum}')

echo $(($rx2 - $rx1))

