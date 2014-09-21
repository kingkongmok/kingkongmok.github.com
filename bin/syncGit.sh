#!/bin/bash - 
#===============================================================================
#
#          FILE: syncGit.sh
# 
#         USAGE: ./syncGit.sh 
# 
#   DESCRIPTION: After pulling git. It could ln all files from git's \
#   config_location as git://~/linux/home/kk
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 09/09/2014 10:15:33 AM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
[ -r /etc/default/locale ] && . /etc/default/locale
[ -n "$LANG" ] && export LANG


if cd  /home/kk/workspace/kingkongmok.github.com/linux/home/kk/ ; then
    for i in `find -type d -printf "%P\n"`; do  mkdir -vp ~/"$i"; done
    for i in `find -type f -printf "%P\n"`; do  ln -f "$i" ~/"$i" ; done
fi
