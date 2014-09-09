#!/bin/bash - 
#===============================================================================
#
#          FILE: uploadfile_mlocatedb.sh
# 
#         USAGE: ./uploadfile_mlocatedb.sh 
# 
#   DESCRIPTION: use gpg encrypt the mlocate.db and put it into dropbox.
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 12/18/2013 08:57:10 AM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
[ -r /etc/default/locale ] && . /etc/default/locale
[ -n "$LANG" ] && export LANG

MLOCATEFILE=/var/lib/mlocate/mlocate.db
LOCALFILE=/home/kk/Documents/personal/mlocate.db
TRANSFER=/home/kk/bin/transfterDropboxGPG.pl



if [ "$(ps -ef | grep [u]pdatedb)" ] ; then
    echo "mlodatedb uplodateing please wait." ;    
    exit 74;
fi

set -x
    sudo updatedb &&\
    cp -a $MLOCATEFILE $LOCALFILE &&\
    $TRANSFER $LOCALFILE


