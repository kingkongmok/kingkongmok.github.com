#!/bin/bash - 
#===============================================================================
#
#          FILE: irc.sh
# 
#         USAGE: ./irc.sh 
# 
#   DESCRIPTION: script for chatting in irc;
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 02/25/2014 11:20:54 AM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
[ -r /etc/default/locale ] && . /etc/default/locale
[ -n "$LANG" ] && export LANG


if [ ! -x /usr/bin/screen ] ; then
    echo "screen is not installed." && exit 23 ;
fi

if [ ! -x /usr/bin/irssi ] ; then
    echo "irssi is not installed." && exit 23 ;
fi

if [ ! -r ~/.irssi/config ] ; then
    echo "irssi is not configured." && exit 23 ;
fi

SCREEN=/usr/bin/screen ;
IRSSI=/usr/bin/irssi ;
#$SCREEN  $IRSSI -c chat.freenode.net
$SCREEN  $IRSSI 
