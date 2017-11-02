#!/bin/bash - 
#===============================================================================
#
#          FILE: showDownload.sh
# 
#         USAGE: ./showDownload.sh 
# 
#   DESCRIPTION: show mldonkey donwload status;
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 02/06/2014 11:21:23 AM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
[ -r /etc/default/locale ] && . /etc/default/locale
[ -n "$LANG" ] && export LANG


if [ "`pgrep mlnet`" ] ; then
    (echo vd ;echo q) | nc 127.0.0.1 4040 | perl -nae '$s=$_ if $.==8 ; push @a,$_ if /\[(?:B|D)\s+(\d+)/ }{ print $s, map {$_->[0]} sort{$a->[1] <=> $b->[1] } map{[$_, +(split)[1]]}@a ' | perl -lane '$result=$_ if $.== 1; if(/\[(B|D)/){printf "%5s%%%6s\t",@F[$#F-7,$#F-1]; print join" ",@F[6..$#F-8]}}{ print"\n$result"'
fi
