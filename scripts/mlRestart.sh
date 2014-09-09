#!/bin/bash - 
#===============================================================================
#
#          FILE: mlnetRestart.sh
# 
#         USAGE: ./mlnetRestart.sh 
# 
#   DESCRIPTION: to restart mlnet.
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 12/16/2013 10:01:31 AM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
[ -r /etc/default/locale ] && . /etc/default/locale
[ -n "$LANG" ] && export LANG

if [ ! "$(ps -ef | grep [m]lnet)" ] ; then
    if [ -w /home/kk/.mldonkey/donkey.ini.tmp ] ; then
        if  diff /home/kk/.mldonkey/donkey.ini.tmp \
            /home/kk/.mldonkey/donkey.ini > /dev/null 2>&1 ; then
            rm /home/kk/.mldonkey/donkey.ini.tmp 
        fi
    fi

    if [ -w /home/kk/.mldonkey/searches.ini.tmp ] ; then
        if  diff /home/kk/.mldonkey/searches.ini.tmp \
            /home/kk/.mldonkey/searches.ini.tmp > /dev/null 2>&1 ; then
            rm /home/kk/.mldonkey/searches.ini.tmp 
        fi
    fi

    mlnet > /dev/null 2>&1 &
fi
