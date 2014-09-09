#!/bin/bash - 
#===============================================================================
#
#          FILE:  getvminfo.sh
# 
#         USAGE:  ./getvminfo.sh 
# 
#   DESCRIPTION:  
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok@gmail.com
#       COMPANY: 
#       CREATED: 03/07/2012 12:04:10 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

for i in `VBoxManage list vms | awk '{print $1}' | sed -n '/^"/p' | sed 's/\"//g'` ; do echo -en "${i}\t"; VBoxManage showvminfo $i | sed -n '/State/p' | sed 's/State:[ \t]\+//' | sed 's/(.*//g' ; done
