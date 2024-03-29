#!/bin/bash - 
#===============================================================================
#
#          FILE: up_bdy.sh
# 
#         USAGE: ./up_bdy.sh 
# 
#   DESCRIPTION: 将 ~/Downloads/tmp 所在的文件进行改名录入dropbox，并备份到百度盘
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
#  ORGANIZATION: datlet.com
#       CREATED: 06/17/2019 10:05
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

BAIDU_SHARE="$HOME/Baidu"
TMP_WORKSPACE="$HOME/Downloads/tmp"
RECORD_WORKSPACE="$HOME/Dropbox/pan"


[[ ! -d "$BAIDU_SHARE" ]] && echo "BAIDU_SHARE not exists" && exit 23
[[ ! -d "$TMP_WORKSPACE" ]] && echo "TMP_WORKSPACE not exists" && exit 23


if [[ ! -z "`find "$TMP_WORKSPACE" -type f`" ]] ; then
    find "$TMP_WORKSPACE" -type f ! -name \*gpg -exec gpg -e -r kingkongmok@gmail.com {} \;
fi


cd $TMP_WORKSPACE
for FILE in `find * -maxdepth 1 -type d ! -empty` ; do
    cd $FILE 
    LAST_RECORD=`tail -n1 "$RECORD_WORKSPACE"/$FILE.txt | perl -naE 'say int($1) if $F[-1] =~ /(\d+)/'`
    # 改名
    perl-rename 's/.*\./sprintf"'"$FILE"'%04d.",++$i+'"$LAST_RECORD"'/e' *gpg -n >> "$RECORD_WORKSPACE"/"$FILE".txt
    perl-rename 's/.*\./sprintf"'"$FILE"'%04d.",++$i+'"$LAST_RECORD"'/e' *gpg -i
    # 上传
    [[  ! -d "$BAIDU_SHARE"/"$FILE" ]] && mkdir "$BAIDU_SHARE"/"$FILE"
    mv *gpg "$BAIDU_SHARE"/"$FILE" 
    # 备份
    # mv * "$HOME"/.p/"$FILE"

    if [ ! -d "${HOME}/.p/${FILE}" ] ; then
        mkdir -p "${HOME}/.p/${FILE}"
    fi


    for filename in *; do
        if [  -f "${HOME}/.p/${FILE}/${filename}" ] ; then
            mv "$filename" "${HOME}/.p/${FILE}/${filename%.*}_`date +%F`_.${filename##*.}"
        else
            mv "$filename" "${HOME}/.p/${FILE}"
        fi
    done



    cd ..
done
