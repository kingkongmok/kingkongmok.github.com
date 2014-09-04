#!/bin/bash - 
#===============================================================================
#
#          FILE:  dcconvert.sh
# 
#         USAGE:  ./dcconvert.sh
# 
#   DESCRIPTION:  
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  update the oac copy.
#        AUTHOR: kk (Kingkong Mok), kingkongmok@gmail.com
#       COMPANY: 
#       CREATED: 02/26/2011 09:35:22 PM CST
#      REVISION:  1.1
#===============================================================================

set -o nounset                              # Treat unset variables as an error


[ -r /etc/default/locale ] && . /etc/default/locale
[ -n "$LANG" ] && export LANG

##-------------------------------------------------------------------------------
##  if the EXTSTRING is not null, the filename is changed to date_extname_filename.
##-------------------------------------------------------------------------------
#EXTSTRING=${1:-}
#if [ -n "$EXTSTRING" ] ; then
#	EXTSTRING=${EXTSTRING}_
#fi


DONEDIR=convertdone


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  convert_do
#   DESCRIPTION:   convert files into convertdone folder.
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
convert_do ()
{
    for file in *.{jpg,JPG}; do
        
        if [ -r "$file" ] ; then
            TIMESTAMP=$(ls --time-style=long-iso -l $file --time-style=long-iso | awk '{print $6}')
        if [ ! -d "${DONEDIR}" ] ; then
            mkdir ${DONEDIR}
        fi
            nice -n 19 convert -resize 1600x1600\> -quality 80% "${file}" "${DONEDIR}"/"${TIMESTAMP}"_"${EXTSTRING}${file%.*}".jpg
        # $(echo ${file##*.} | tr [A-Z] [a-z]) for extends before.
        fi
    done
    for file in *.{avi,AVI}; do
        if [ -r "$file" ] ; then
            TIMESTAMP=$(ls --time-style=long-iso -l $file --time-style=long-iso | awk '{print $6}')
            cp "${file}" "tmp_${file}"; 
            if [ -f "divx2pass.log" ] ; then
                rm divx2pass.log;
            fi
            if [ ! -d "${DONEDIR}" ] ; then
                mkdir "${DONEDIR}"
            fi
            #nice -n 19 mencoder "tmp_${file}" -oac copy -ovc lavc -lavcopts vcodec=mpeg4:vpass=1:vbitrate=1200 -o "${DONEDIR}"/"${TIMESTAMP}"_"${EXTSTRING}${file%.*}".avi
            nice -n 19 mencoder "tmp_${file}" -oac copy -ovc lavc -lavcopts vcodec=mpeg4:vpass=1:vbitrate=1200 -o /dev/null
            nice -n 19 mencoder "tmp_${file}" -oac copy -ovc lavc -lavcopts vcodec=mpeg4:vpass=2:vbitrate=1200 -o "${DONEDIR}"/"${TIMESTAMP}"_"${EXTSTRING}${file%.*}".avi
                rm "tmp_${file}";
            if [ -f "divx2pass.log" ] ; then
                rm divx2pass.log;
            fi
        fi
    done
}	# ----------  end of function convert_do  ----------

#-------------------------------------------------------------------------------
#  copy all converted files into /home/kk/Pictures/family
#-------------------------------------------------------------------------------
copy_items ()
{
DIRNAME=
if cd "$DONEDIR" ; then
    for JPGS in *.jpg ; do
        DIRNAME=`ls --time-style=long-iso -l "$JPGS" | awk '{print $8}' | cut -d- -f1-2`
        if [ ! -d "/home/kk/Pictures/family/$DIRNAME" ] ; then
            mkdir -p "/home/kk/Pictures/family/$DIRNAME"
        fi
        if [ -f "$JPGS" ] ; then
            cp -au "$JPGS" "/home/kk/Pictures/family/$DIRNAME"
        fi
    done
    for AVIS in *.avi ; do
        DIRNAME=`ls --time-style=long-iso -l "$AVIS" | awk '{print $8}' | cut -d- -f1-2`
        if [ ! -d "/home/kk/Videos/family/$DIRNAME" ] ; then
            mkdir -p "/home/kk/Videos/family/$DIRNAME"
        fi
        if [ -f "$AVIS" ] ; then
            cp -au "$AVIS" "/home/kk/Videos/family/$DIRNAME"
        fi
    done
fi
}	# ----------  end of function copy_items  ----------

#-------------------------------------------------------------------------------
#  specify folder's item should be renamed with there folders.
#-------------------------------------------------------------------------------

WORKINGLOCATE=`pwd`

    OLDIFS=$IFS
    IFS=$'\n'
    #FOLDERSARRAY=(`find . -type d`)
    FOLDERSARRAY=( `ls -d */ | xargs -l` )
    IFS=$OLDIFS


for (( CNTR=0; CNTR<"${#FOLDERSARRAY[@]}"; CNTR+=1 )); do
    NEXTFOLDER="${FOLDERSARRAY[$CNTR]%/}"
    if [ "$NEXTFOLDER" != "$DONEDIR" ] ; then
        EXTSTRING="${NEXTFOLDER}"_
        cd "$NEXTFOLDER"
            convert_do
            copy_items
        cd "$WORKINGLOCATE"
    fi
done


EXTSTRING=${1:-}
if [ -n "$EXTSTRING" ] ; then
	EXTSTRING=${EXTSTRING}_
fi
convert_do
copy_items

