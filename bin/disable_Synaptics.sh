#!/bin/bash - 
#===============================================================================
#
#          FILE: disable_Synaptics.sh
# 
#         USAGE: ./disable_Synaptics.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
#  ORGANIZATION: datlet.com
#       CREATED: 10/26/2018 23:12
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

# check input device if pluged
if [[ "$(/usr/bin/xinput -list | grep Mouse)" ]]  ; then

    if [[ "$(/usr/bin/xinput -list | grep TouchPad)" ]]  ; then
        # if plug device, disable synaptics
        SynapticsNumber=`/usr/bin/xinput list | grep 'TouchPad' | perl -naE 'say $1 if $F[5]=~/id=(\d+)/'`
        /usr/bin/xinput set-prop $SynapticsNumber "Device Enabled" 0
    fi
    if [[ "$(/usr/bin/xinput -list | grep 'Generic ')" ]]  ; then
        # if plug device, disable synaptics
        SynapticsNumber=`/usr/bin/xinput list | grep 'Generic ' | perl -naE 'say $1 if $F[5]=~/id=(\d+)/'`
        /usr/bin/xinput set-prop $SynapticsNumber "Device Enabled" 0
    fi
fi
