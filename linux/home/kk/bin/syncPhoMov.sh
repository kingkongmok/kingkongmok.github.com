#!/bin/bash - 
#===============================================================================
#
#          FILE:  syncPhoMov.sh
# 
#         USAGE:  ./syncPhoMov.sh 
# 
#   DESCRIPTION:  rsync the /home/kk/Pictures/family/ to phdd and camilla's pc.
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: kk (Kingkong Mok), kingkongmok@gmail.com
#       COMPANY: 
#       CREATED: 09/10/2011 11:45:29 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
set -x


KK_VAR=/home/kk/.kk_var
[ -f $KK_VAR ] && . $KK_VAR


DELETEACTION=
ScriptVersion="1.0"

#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
function usage ()
{
	cat <<- EOT

  Usage :  ${0##/*/} [options] [--] 

  Options: 
  -h|help       Display this message
  -d|delete     delete extraneous files from dest dirs
  -v|version    Display script version

	EOT
}    # ----------  end of function usage  ----------


while getopts ":dhv" opt
do
  case $opt in

    h|help     )  usage; exit 0   ;;

    d|delete  )  DELETEACTION="--delete" ;;
    v|version  )  echo "$0 -- Version $ScriptVersion"; exit 0   ;;


    \? )  echo -e "\n  Option does not exist : $OPTARG\n"
          usage; exit 1   ;;

  esac    # --- end of case ---
done
shift $(($OPTIND-1))


#-----------------------------------------------------------------------
#  Handle command line arguments camilla's pc
#-----------------------------------------------------------------------
IFONLINE=
HOSTIP=192.168.1.11
ping -q -c 1 $HOSTIP &>/dev/null && IFONLINE=yes
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")          # generate timestamp : YYYYMMDD-hhmmss

if [ -n "$IFONLINE" ]; then
	mkdir /tmp/baby${TIMESTAMP};
	sudo mount -t cifs -o iocharset=utf8,uid=1000,gid=1000,username=${COMMON_USERNAME},password=${COMMON_PASSWORD} //"${HOSTIP}"/d$ /tmp/baby${TIMESTAMP} 
	if [[ `mount` =~ "on /tmp/baby${TIMESTAMP} type" ]] ; then
        rsync -auzv /home/kk/Pictures/family/ /tmp/baby${TIMESTAMP}/baby/Pictures 
        rsync -auzv /home/kk/Videos/family/ /tmp/baby${TIMESTAMP}/baby/Videos
        sudo umount /tmp/baby${TIMESTAMP} 
	else 
		if [  -d "/tmp/baby${TIMESTAMP}" ] ; then
			rm -r /tmp/baby${TIMESTAMP};
		fi
	fi
else
	echo "cannot connect $HOSTIP"
fi



#-----------------------------------------------------------------------
#  Handle command line arguments mom's pc
#-----------------------------------------------------------------------
IFONLINE=
HOSTIP=192.168.1.13
ping -q -c 1 $HOSTIP &>/dev/null && IFONLINE=yes
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")          # generate timestamp : YYYYMMDD-hhmmss

if [ -n "$IFONLINE" ]; then
	mkdir /tmp/baby${TIMESTAMP};
	sudo mount -t cifs -o iocharset=utf8,uid=1000,gid=1000,username=${COMMON_USERNAME},password=${COMMON_PASSWORD} //192.168.1.13/d$ /tmp/baby${TIMESTAMP} 
	if [[ `mount` =~ "on /tmp/baby${TIMESTAMP} type" ]] ; then
        rsync -auzv /home/kk/Pictures/family/ /tmp/baby${TIMESTAMP}/baby/Pictures 
        rsync -auzv /home/kk/Videos/family/ /tmp/baby${TIMESTAMP}/baby/Videos
        sudo umount /tmp/baby${TIMESTAMP} 
	else 
		if [  -d "/tmp/baby${TIMESTAMP}" ] ; then
			rm -r /tmp/baby${TIMESTAMP};
		fi
	fi
else
	echo "cannot connect $HOSTIP"
fi


#-------------------------------------------------------------------------------
#  sync portable hdd here
#-------------------------------------------------------------------------------
if [[ `mount` =~ "on /media/phdd-home type xfs" ]] ; then
	if [ -d /media/phdd-home/kk ] ; then
			rsync $DELETEACTION -auzv /home/kk/Pictures/family/ /media/phdd-home/kk/Pictures/family
			rsync $DELETEACTION -auzv /home/kk/Videos/family/ /media/phdd-home/kk/Videos/family
	fi
else
	echo can not connect portable hdd && exit 67 ;
fi 

