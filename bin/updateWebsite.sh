#!/bin/bash - 
#===============================================================================
#
#          FILE: updateWebsite.sh
# 
#         USAGE: ./updateWebsite.sh 
# 
#   DESCRIPTION: 文件上线使用
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 08/28/2014 05:07:42 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
[ -r /etc/default/locale ] && . /etc/default/locale
[ -n "$LANG" ] && export LANG

set -x

WEBSITE_BASE_PATH=($HOME/tomcat*/sysapps)
UPDATE_PLUGIN_PATH="$HOME/backup_files/"$(date "+%Y%m%d")


for base in  ${WEBSITE_BASE_PATH[@]}; do
    echo $base ;
done
