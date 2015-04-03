#!/bin/bash - 
set -o nounset                              # Treat unset variables as an error
[ -r /etc/default/locale ] && . /etc/default/locale
[ -n "$LANG" ] && export LANG



#-------------------------------------------------------------------------------
#  apache的配置文件，
#-------------------------------------------------------------------------------
APACH_CONFIG=~/testfile

#-------------------------------------------------------------------------------
#  apache access log 的位置
#-------------------------------------------------------------------------------
ACCESS_LOG=~/1


#-------------------------------------------------------------------------------
#  截取个数
#-------------------------------------------------------------------------------
THRESHOLD=4

#-------------------------------------------------------------------------------
#  don't edit below
#-------------------------------------------------------------------------------

TIMESTAMP=`date +"%F_%T"`

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  writeContent
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
writeContent ()
{
     cp "$APACH_CONFIG" "${APACH_CONFIG}.${TIMESTAMP}" && nice perl -nae 'BEGIN{print "RewriteCond \%\{QUERY_STRING\}\n"};$h{$&}++ if /(?<=new-fcgi-bin\/gfdownsvr.fcg\?)\S+(?=\s)/}{while(($k,$v)=each%h){push @a,$k if $v>'$THRESHOLD' }; print join"\n[NC,OR]\n",@a; print "\n[NC]\nRewriteRule (.*) - [R=406,L]\n"' "$ACCESS_LOG" > "$APACH_CONFIG"
}	# ----------  end of function writeContent  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  restartApache
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
restartApache ()
{
    echo restart apache here    
}	# ----------  end of function restartApache  ----------


if [ -w `dirname $(readlink -f "$APACH_CONFIG")` ] ; then
    writeContent
fi
restartApache && rm ${APACH_CONFIG}.$TIMESTAMP || cp "${APACH_CONFIG}.${TIMESTAMP}" "$APACH_CONFIG" 
