#!/bin/bash - 
#===============================================================================
#
#          FILE:  test.sh
# 
#         USAGE:  ./comixchange.sh foo.rar; for i in *.zip; do comixchange "$i"; done
# 
#   DESCRIPTION:  change zip, rar, tar into tar file, and convert the pics into 1450;
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: kk (kingkongmok@gmail.com), 
#       COMPANY: 
#       CREATED: 05/19/2011 09:08:13 AM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

# 设置高像素
#TARGETHI=1450
TARGETHI=1600

# 设置图片的平均大小
#TARGETAVGSIZE=360
TARGETAVGSIZE=500

function usage () {
cat << EOF
usage:  `basename $0` ZIPFILE to convert
options:
-h : show this help;
-w : set the sleep time;
-p : set password;
-n : do not resize;
EOF
exit 3
}


if [ "$#" -eq 0 ] ; then
    usage;
fi

PASSWORD=
WAITTIME=0
NOTDOFLAG=

while getopts w:p:nh OPTIONS ; do
	case $OPTIONS in

		h)
            usage;
			;;
		w)
			WAITTIME="$OPTARG";
			;;
		p)
			PASSWORD="$OPTARG"
			;;
		n)
			NOTDOFLAG=1;
			;;

	esac    # --- end of case ---

done
shift $(( $OPTIND -1 ))



FILE="$*"
PATHNAME="${FILE%/*:-.}"
if [ ! -d "$PATHNAME" ] ; then
	PATHNAME=`pwd`
fi
SUFFIX="${FILE##*.}"
FILENAMESUFFIX="${FILE#"${PATHNAME}/"}"
FILENAME="${FILENAMESUFFIX%."${SUFFIX}"}"
WORKPATH="${PATHNAME}/convertdone"


if [ ! -f "$FILE" ]; then
	exit 87;
fi


if [ ! -d "$WORKPATH"  ] ; then
	if [ -d "$PATHNAME" ]; then
		mkdir -p "$WORKPATH"
	else
		echo "path not exits."
		exit 88;
	fi
fi

check_exist ()
{
	if [ -f "${WORKPATH}/${FILENAME}.tar" ] ; then
		echo file exist.
		exit 68
	fi
}	# ----------  end of function check_exist  ----------


extract_it ()
{
        case $SUFFIX in
                zip | ZIP)
			if [ -z "$PASSWORD" ] ; then
				unzip -nLqa "$FILE" -d "${WORKPATH}/${FILENAME}"
			else
				unzip -nLqa -P "$PASSWORD" "$FILE" -d "${WORKPATH}/${FILENAME}"
			fi
                        ;;
 
                rar | RAR)
			mkdir "${WORKPATH}/${FILENAME}" -p
			if [ -z "$PASSWORD" ] ; then
				unrar x "$FILE" "${WORKPATH}/${FILENAME}"
			else
				unrar x -p"$PASSWORD" "$FILE" "${WORKPATH}/${FILENAME}"
			fi
                        ;;

                tar | TAR)
			mkdir "${WORKPATH}/${FILENAME}" -p
			cd "${WORKPATH}/${FILENAME}" 
			tar xf "${PATHNAME}/${FILE}" 
			cd "$PATHNAME"
                        ;;
                *)
                        echo "can't unpack the file."
			exit 88;
                        ;;

        esac    # --- end of case ---
}       # ----------  end 


resize ()
{
	cd "${WORKPATH}/${FILENAME}"
	#find "${WORKPATH}/${FILENAME}" -type f ! -iregex ".*\.\(bmp\|jpg\|jpeg\|tiff\|tif\|png\)" -exec rm -f "{}" \;
        #remove cover page
        find -iname 001-00.jpg -type f -size 228683c -exec rm -f "{}" \;
        find -iname 002.jpg -type f -size 281122c -exec rm -f "{}" \;
        find -iname 003.jpg -type f -size 553644c -exec rm -f "{}" \;

    # convert \(bmp\|tiff\|tif\|png\) type to jpg
	OLDIFS=$IFS
	IFS=$'\n'
	FI_2_JPG=(`find . -type f -iregex ".*\.\(bmp\|tiff\|tif\|png\)"`)
	IFS=$OLDIFS
    if [ "${#FI_2_JPG[@]}" -gt 0 ] ; then
        for (( CNTR=0; CNTR<${#FI_2_JPG[@]}; CNTR+=1 )); do
            nice -n 19 mogrify -format jpg "${FI_2_JPG[${CNTR}]}" && \
            nice -n 19 rm -f "${FI_2_JPG[${CNTR}]}"
        done
        
    fi


	RESIZEPARA=
	QUALITYPARA=
	FILEHIGHT=
	OLDIFS=$IFS
	IFS=$'\n'
	files=(`find . -type f -iregex ".*\.\(bmp\|jpg\|jpeg\|tiff\|tif\|png\)"`)
	IFS=$OLDIFS

	FILENUMB=${#files[@]}
	TESTFILE0="${files[(("$FILENUMB"/2))]}"
	TESTFILE1="${files[(("$FILENUMB"/3))]}"
	TESTFILE2="${files[(("$FILENUMB"/4))]}"

	if [ `convert "$TESTFILE0" -print "%h" /dev/null` -gt ${TARGETHI} -o `convert "$TESTFILE1" -print "%h" /dev/null` -gt ${TARGETHI} -o `convert "$TESTFILE2" -print "%h" /dev/null` -gt ${TARGETHI} ] ; then
		RESIZEPARA="${TARGETHI}"
	fi

	if [ -n "$RESIZEPARA" ] ; then
		for (( CNTR=0; CNTR<${#files[@]}; CNTR+=1 )); do
			nice -n 19 convert -resize x${RESIZEPARA}\> "${files[${CNTR}]}" "${files[${CNTR}]}";
			sleep "$WAITTIME";
		done
	fi

	TOTALLYSIZE=$(du -s . | awk '{print $1}')
	AVGSIZE=$(($TOTALLYSIZE/$FILENUMB))
	QUALITY=$((${TARGETAVGSIZE}*100/${AVGSIZE}))
	if [ "$AVGSIZE" -gt ${TARGETAVGSIZE} ] ; then
		QUALITYPARA=" -quality ${QUALITY}%"
	fi

	if [ -n "$QUALITYPARA" ] ; then
			for (( CNTR=0; CNTR<${#files[@]}; CNTR+=1 )); do
				nice -n 19 convert $QUALITYPARA "${files[${CNTR}]}" "${files[${CNTR}]}"
			done
	fi
}	# ----------  end of function do_resize  ----------

tar_it ()
{
	cd "${WORKPATH}/${FILENAME}"
    find -iname Thumbs.db -type f -exec rm -f "{}" \;
	tar cf "${WORKPATH}/${FILENAME}.tar" *
	
	if [ -d "${WORKPATH}/${FILENAME}" ] ; then
		rm -rf "${WORKPATH}/${FILENAME}"
	fi
	
}	# ----------  end of function tar_it  ----------

check_exist
extract_it
if [ -z "$NOTDOFLAG" ]; then
	resize
fi
tar_it
