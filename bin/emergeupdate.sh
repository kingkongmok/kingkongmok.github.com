#!/bin/sh


# reset this list
# emaint --fix cleanresume

# get the resume list 
# python -c 'import portage; print portage.mtimedb.get("resume", {}).get("mergelist")' 

#https://forums.gentoo.org/viewtopic-p-6823472.html

#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
function usage ()
{
    cat <<- EOT

    DESCRIPTION: update gentoo

    Usage :  ${0##/*/} [-f]

    Options: 
    -f            don't RESUME
    -h|help       Display this message

EOT
}    # ----------  end of function usage  ----------

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------
ForceUpdate=0

while getopts "fh" opt
do
    case $opt in

        f     )  ForceUpdate=1 ;  ;;
        h|help     )  usage; exit 0   ;;

        \? )  echo -e "\n  Option does not exist : $OPTARG\n"
            usage; exit 1   ;;

        esac    # --- end of case ---
    done
shift $(($OPTIND-1))


if [ "$ForceUpdate" != 1 ] ; then
    sudo emerge --resume 
else
    sudo emaint --fix cleanresume
fi

# sudo emerge-webrsync && \
sudo emerge --sync 
sudo emerge --keep-going --update --deep --with-bdeps=y --newuse @world && \
sudo emerge --depclean && \
sudo evdep-rebuild.sh


# https://forums.gentoo.org/viewtopic-t-564143-start-0.html
if [ -d "/usr/portage/packages" ] ; then
    sudo eclean -C -q packages 
fi
sudo eclean -C -q -d -t1w distfiles
