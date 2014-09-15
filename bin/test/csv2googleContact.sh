#!/bin/bash - 
#===============================================================================
#
#          FILE: csv2googleContact.sh
# 
#         USAGE: ./csv2googleContact.sh 
# 
#   DESCRIPTION: for Camilla
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 09/15/2014 11:33:23 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
[ -r /etc/default/locale ] && . /etc/default/locale
[ -n "$LANG" ] && export LANG



perl -F, -lane 'print "$F[0]手机,$F[1]\n$F[0]家庭,$F[2]\n$F[0]父,$F[3]\n$F[0]母,$F[4]"' contact.csv
perl -i -ne 'print if /\d/' contact.csv
perl -i.1 -pe 's/,/,,,,,,,,,,,,,,,,,,,,,,,2014ST,,,,,,,Mobile,/' cont.csv
perl -i.2 -pe 's/Mobile/Home/ unless /\d{10}/' cont.csv
sed -i.3 's/$/,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,/' cont.csv
perl -pe 's/([^,]*)(?=,)/$1,,,$1/'
