#!/bin/bash
if [ $# == 2 ]; then
sudo iptables -I OUTPUT -s 45.124.66.243 -p tcp --sport $1 -m comment --comment $2 && exit 0 
fi
echo please insert PortNumber as \$1 and Comment as \$2
