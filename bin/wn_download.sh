#!/bin/bash - 
#===============================================================================
#
#          FILE: wn_download.sh
# 
#         USAGE: ./wn_download.sh
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 18/02/2021 20:56
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error


TFILE="/tmp/$(basename $0).$$.tmp"
comicDownloadList=~/Dropbox/var/log/wn_download/comic.list
comicDownloadFinish=~/Dropbox/var/log/wn_download/comic.done
comicDownloadFailure=~/Dropbox/var/log/wn_download/comic.fail
CURL_HEADER="User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.89 Safari/537.36"
PROXYCHAINS=proxychains
DOWNLOAD_DIR=~/Downloads/comic
CURL=curl
FailureMode=0
ERRORMAKR=0

getURL()
{

    #substring, change photo to download
    DOWNLOADLINE=${1/photos/download}

    #DOWNLOADLINE=${1}
    # get methods and hostname
    #METHODHOSTNAME=`echo $DOWNLOADLINE | perl -ne 'print $1 if /^(.*?\/\/.*)\//'`
    METHODHOSTNAME=`echo $DOWNLOADLINE | perl -ne 'print $1 if /^(.*?)\/\//'`
    # get URL from $1
    MESSAGE=`$PROXYCHAINS -q $CURL -H "$CURL_HEADER" -s $DOWNLOADLINE`
    MESSAGESIZE=`echo "$MESSAGE" | wc -c`

    if [ $MESSAGESIZE -gt 1000 ] ; then
        URLINFO=`echo "$MESSAGE" | perl -ne 'print $1 . ".zip" if /href="(.*?download.*?)"><span>&nbsp;本地下載一/' | python3 -c 'import html,sys; print(html.unescape(sys.stdin.read()), end="")'`
        URL=`echo ${METHODHOSTNAME}${URLINFO/zip?n=/zip } | perl -naE 'say $F[0]'`
        FILENAME=`echo ${METHODHOSTNAME}${URLINFO/zip?n=/zip } | perl -nE 'print $1 if / (.*$)/'`

        # 获得的文件名不为空
        if [ "$FILENAME" != ".zip" ]  ; then


            # 非failure模式
            if [ "$FailureMode" == "0" ] ; then 


                #是否在failurelist中
                if [ ! "$( cat $comicDownloadFailure 2> /dev/null | grep $line )" ]  ; then

                    # 不在list和done名单
                    if [ ! "$(cat $comicDownloadList $comicDownloadFinish 2>/dev/null | grep $URL)" ] ; then
                        echo ${METHODHOSTNAME}${URLINFO/zip?n=/zip } >> $comicDownloadList
                    else
                        echo "$DOWNLOADLINE is marked before" 
                    fi
                    perl -i -nE 'print unless m#'"$1"'#' $comicDownloadFailure
                fi
                
                return 0


            # 如果failure模式，检查一下是否在faillist中，如果在failist则忽略
            elif [ "$FailureMode" == "1" ] ; then

                # 不在list和done名单
                if [ ! "$(cat $comicDownloadList $comicDownloadFinish 2>/dev/null | grep $URL)" ] ; then
                    echo ${METHODHOSTNAME}${URLINFO/zip?n=/zip } >> $comicDownloadList
                else
                    echo "$DOWNLOADLINE is marked before" 
                fi
                perl -i -nE 'print unless m#'"$1"'#' $comicDownloadFailure
                return 0
            fi

        # 获得的文件名为空
        elif [ "$FILENAME" == ".zip" ]  ; then
            echo "no filename, please check"
            echo "$1" >> $comicDownloadFailure
            return 1

        else
            echo "unknown error"
            echo "$1" >> $comicDownloadFailure
            return 1

        fi

    fi
}


tryFailureJobs()
{
    if [ -f "$comicDownloadFailure" ] ; then
        cp -f $comicDownloadFailure $TFILE
    fi

    if [ -f "$TFILE" ]; then
        while read line
        do
            if [ ! -z "$line" ]; then
            getURL $line
            sleep 3
            fi
        done < $TFILE
    fi 

    rm -f $TFILE
}


downUrl()
{


    while read line
    do

        if [ ! -z "$line" ]; then

            DownloadURL=`echo $line | perl -naE 'say $F[0]'`
            #FILENAME=`echo $line | perl -naE 'say join" ", @F[1..$#F]'`
            FILENAME=`echo $line | perl -nE 'print $1 if / (.*$)/'`
            SIZE=`$PROXYCHAINS -q $CURL -k -H "$CURL_HEADER" -s -I $DownloadURL | grep content-length: | perl -naE 'say $F[-1]'`
            SIZE=${SIZE:-0}

            # the filesize in http is more than 0
            if [ $SIZE -gt 1000 ] ; then

                # get the localfile status 
                localfile=${DOWNLOAD_DIR}/${FILENAME}
                localfile_size=0
                if [ -f "$localfile" ]; then
                    localfile_size=`stat --printf="%s" "$localfile"`
                fi

                # check the localfile size 1/2 first time, 
                if  [ "$SIZE" -eq "$localfile_size" ]; then 
                    echo $line >> $comicDownloadFinish
                    perl -i -nE 'print unless m#'"$DownloadURL"'#' $comicDownloadList
                    continue
                fi

                
                # download the file
                $PROXYCHAINS -q $CURL -k -s -H "$CURL_HEADER" -C - $DownloadURL -o "$localfile" 
                sleep 3


                # check the localfile size 2/2 second time, 
                if [ -f "$localfile" ]; then
                    localfile_size=`stat --printf="%s" "$localfile"`
                fi

                # if the file is downloaded compeleted
                if  [ "$SIZE" -eq "$localfile_size" ]; then 
                    echo $line >> $comicDownloadFinish
                    perl -i -nE 'print unless m#'"$DownloadURL"'#' $comicDownloadList
                    continue
                fi

            # the filesize in http is less than 0
            elif [ $SIZE -lt 1000 ] ; then

                sleep 10

            fi

        fi

    done < $comicDownloadList

}	# ----------  end of function downUrl  ----------


#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
function usage ()
{
    cat <<- EOT

    DESCRIPTION: download comic

    Usage :  ${0##/*/} [-f:-d]

    Options: 
    -f            failure mode, re try the failure list
    -d            download from the list
    -h|help       Display this message

EOT
}    # ----------  end of function usage  ----------

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------
SourcePath=
DestinationPath=
DESCRIPTION=
DownloadMode=

while getopts "fdh" opt
do
    case $opt in

        f     )  FailureMode=1 ;  ;;
        d     )  DownloadMode=1 ;  ;;
        h|help     )  usage; exit 0   ;;

        \? )  echo -e "\n  Option does not exist : $OPTARG\n"
            usage; exit 1   ;;

        esac    # --- end of case ---
    done
shift $(($OPTIND-1))


#-------------------------------------------------------------------------------
# main()
#-------------------------------------------------------------------------------

# download from the list
if [ "$DownloadMode" ] ; then
    downUrl;
    exit 0;
fi

# failure mode
if [ "$FailureMode" == 1 ] ; then
    tryFailureJobs;
    exit 0;
fi


# record to the list
echo "please input URL to download, or 'q' to quit:"
while read line           
do           
    if [ "$line" == "q" ] ; then
        break
    else
        if [ -z "$line" ] ; then
            continue
        else
            getURL $line &
        fi
        echo "please input URL to download, or 'q' to quit:"
    fi
done

