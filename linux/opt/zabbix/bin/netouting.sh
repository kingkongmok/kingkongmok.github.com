#!/bin/bash
#out
rxa=$(cat /proc/net/dev |sed -e'1,2d'|egrep -v 'lo:|bond'|awk '{sum+=$10}END{printf "%.0f\n",sum}')

sleep 1

rxb=$(cat /proc/net/dev |sed -e'1,2d'|egrep -v 'lo:|bond'|awk '{sum+=$10}END{printf "%.0f\n",sum}') 
echo $(($rxb - $rxa))

