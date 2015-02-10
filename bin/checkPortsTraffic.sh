#!/bin/bash - 
#===============================================================================
#
#          FILE: checkPortsTraffic.sh
# 
#         USAGE: ./checkPortsTraffic.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 02/10/2015 02:25:25 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

PORT_LIST=(7711 7722 7733 7744)
TIMEOUTTIME=5
NETINTERFACE=lo
TCPDUMP="/usr/sbin/tcpdump"
TFILE="/tmp/$(basename $0).$$.tmp"
IP_ADDR=`/sbin/ip a | grep -oP "(?<=inet )\S+(?=\/.*bond)"`
MAILUSER="moqingqiang@richinfo.cn"



#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  errorMail
#   DESCRIPTION:  mail the $MAILUSER with $TFILE
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
errorMail ()
{
    echo -e "Subject: ${IP_ADDR}_`basename $0`\n\ntcp port ${port} no tracffic." | /usr/local/bin/msmtp $MAILUSER 
}   # ----------  end of function errorMail  ----------


#timeout "$TIMEOUTTIME" sudo $TCPDUMP -n -c 10 -i $NETINTERFACE tcp $port -w $TFILE 2>/dev/null 
sudo $TCPDUMP -c 10000 -n -i $NETINTERFACE tcp > $TFILE 2>/dev/null 

for port in ${PORT_LIST[@]} ; do
    COUNTNUMB=`grep "${port}:" -c $TFILE`
    if [ $COUNTNUMB -lt 50 ] ; then
        errorMail
    fi
done

rm $TFILE
