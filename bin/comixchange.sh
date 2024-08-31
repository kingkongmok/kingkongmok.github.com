#!/bin/bash - 
#===============================================================================
#
#          FILE:  test.sh
# 
#         USAGE:  ./comixchange.sh foo.rar; for i in *.zip; do comixchange "$i"; done
# 
#   DESCRIPTION:  change zip, rar, tar into tar file, 
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: kk (kingkongmok@gmail.com), 
#       COMPANY: 
#       CREATED: 02/20/2021 09:08:13 AM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

# 设置高像素
#TARGETHI=1450
TARGETHI=1600

# 设置图片的平均大小
#TARGETAVGSIZE=360
TARGETAVGSIZE=350



if [ "$#" -eq 0 ] ; then
cat << EOF
usage:  comixchange ZIPFILE to convert
options:
-h : show this help;
-w : set the sleep time;
-p : set password;
-n : do not resize;
-r : auto rename all the images;
EOF
exit 3
fi

PASSWORD=
WAITTIME=0
RENAME_TRIGGER=0
NOTDOFLAG=

while getopts w:p:nrh OPTIONS ; do
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
		r)
			RENAME_TRIGGER=1;
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
            # if [ -z "$PASSWORD" ] ; then
            #     unzip -nLqa "$FILE" -d "${WORKPATH}/${FILENAME}"
            # else
            #     unzip -nLqa -P "$PASSWORD" "$FILE" -d "${WORKPATH}/${FILENAME}"
            # fi

            7z x "$FILE" -o"${WORKPATH}/${FILENAME}"
            ;;

        cbz | CBZ)
            # if [ -z "$PASSWORD" ] ; then
            #     unzip -nLqa "$FILE" -d "${WORKPATH}/${FILENAME}"
            # else
            #     unzip -nLqa -P "$PASSWORD" "$FILE" -d "${WORKPATH}/${FILENAME}"
            # fi
            7z x "$FILE" -o"${WORKPATH}/${FILENAME}"
            ;;

        rar | RAR)
            # mkdir "${WORKPATH}/${FILENAME}" -p
            # if [ -z "$PASSWORD" ] ; then
            #     unrar x "$FILE" "${WORKPATH}/${FILENAME}"
            # else
            #     unrar x -p"$PASSWORD" "$FILE" "${WORKPATH}/${FILENAME}"
            # fi
            7z x "$FILE" -o"${WORKPATH}/${FILENAME}"
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

    cd "${WORKPATH}/${FILENAME}" || exit 23


    # delete NOT IMAGE files
    find . -type f ! -iregex ".*\.\(apng\|avif\|gif\|jfif\|pjpeg\|pjp\|svg\|webp\|bmp\|ico\|cur\|jpg\|jpeg\|tiff\|tif\|png\)$" -exec rm -f "{}" \;


    # convert \(bmp\|tiff\|tif\|png\) type to jpg
    find . -type f -iregex ".*\.\(apng\|avif\|svg\|webp\|bmp\|ico\|cur\|tiff\|tif\|png\)$" -exec sh -c 'mogrify -format jpg "$1" && rm -f "$1" ' sh {} \;


    # list all jpg files
    OIFS="$IFS"
    IFS=$(echo -en "\n\b")
    for i in `find . -type f -size +300k -iregex ".*\.\(jpg\|jpeg\|jfif\|pjpeg\|pjp\)$"` ; do


        # change size if too hi
        THISH=$(identify -format "%h" "$i")
        if [ $THISH -gt $TARGETHI ] ; then
            convert -resize "x$TARGETHI" "$i" "$i"
        fi


        # change quality
        WIDTH=$(identify -format '%w' "$i")
        HEIGHT=$(identify -format '%h' "$i")
        FILESIZE=$(stat --printf="%s" "$i")

        # single page
        if  [ $HEIGHT -gt $WIDTH ] ; then
            QUALITY_RATE=$(echo 0.92*${TARGETAVGSIZE}*1024*100/${FILESIZE}|bc )
        # double page
        elif [ $HEIGHT -lt $WIDTH ] ; then
            QUALITY_RATE=$(echo 0.92*${TARGETAVGSIZE}*2*1024*100/${FILESIZE}|bc )
        fi


        if [ $QUALITY_RATE -ge 120 ] ; then
            continue
        elif [ $QUALITY_RATE -lt 120 ] && [ $QUALITY_RATE -ge 80 ] ; then
            convert -quality "80%" "$i" "$i"
        elif [ $QUALITY_RATE -lt 80 ] && [ $QUALITY_RATE -gt 0 ] ; then
            convert -quality "${QUALITY_RATE}%" "$i" "$i"
        fi
        

    done
    IFS="$OIFS"


}	# ----------  end of function do_resize  ----------

tar_it ()
{


    cd "${WORKPATH}/${FILENAME}"
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

if [ $RENAME_TRIGGER -eq 1 ]  ; then
    cd "${WORKPATH}/${FILENAME}" || exit 23
    shopt  -s dotglob
    find -type f -exec perl-rename 's/\///g' {} -i \;
    perl-rename 's/.*\./sprintf"%04d.",++$i/e' * -i
    shopt  -u dotglob
fi


tar_it
