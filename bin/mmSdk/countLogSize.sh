#!/bin/bash - 
#===============================================================================
#
#          FILE: countLogSize.sh
# 
#         USAGE: ./countLogSize.sh -i LOGFILE -o LOGFILE.size
# 
#   DESCRIPTION: 用于记录日志各个时段的自增行数。并比较旧文件 （记录文件.1, 
#                记录文件.2 ... ）的平均数量,
# 
#       OPTIONS: ---
#  REQUIREMENTS: 需配合logrotate对记录文件进行压缩，轮换删除
#          BUGS: ---
#         NOTES: http://www.datlet.com/linux/2014/11/06/monitor-logs-increase-and-warning/
#        AUTHOR: kk (Kingkong Mok), kingkongmok AT gmail DOT com
#  ORGANIZATION: 
#       CREATED: 10/30/2014 03:58:19 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error


#-------------------------------------------------------------------------------
#  OUTPUT_SUFFIX 所产生记录文件的扩展名，默认应该为size，这里需配合crontab标明
#       输出
#  例如accesslog文件的记录文件为accesslog.size
#  而配合logrotate，历史记录文件为accesslog.size.*
#-------------------------------------------------------------------------------
OUTPUT_SUFFIX=size


mail_user="moqingqiang@richinfo.cn"


#-------------------------------------------------------------------------------
#  don't edit below
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#  默认值，可以通过 “-n”设置，日志自增值小于过往平均自增值的阀值 (自增值/平均自增值)
#-------------------------------------------------------------------------------
MIN_RATE_THRESHOLD="0.5"

#-------------------------------------------------------------------------------
#  默认值，可以通过 “-m”设置，日志自增值大`于过往平均自增值的阀值 (自增值/平均自增值)
#-------------------------------------------------------------------------------
MAX_RATE_THRESHOLD="2"


INPUT_FILE=
OUTPUT_FILE=
ERRORMAIL_TRIGGER=
WARN_TRIGGER=

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
  -n|min        miNinum thishoure.
  -m|max        Maximum thishoure.
  -o|output     Output result file.
  -i|input      Input Logfile.
  -w|warnning   witch Warnning.

  -h|help       Display this message
  -v|version    Display script version

	EOT
}    # ----------  end of function usage  ----------

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------

while getopts "n:m:i:o:whv" opt
do
  case $opt in

    o|output   ) OUTPUT_FILE="$OPTARG"   ;;
    i|input   )  INPUT_FILE="$OPTARG"   ;;
    w|warn   )   WARN_TRIGGER=1   ;;
    n|min    )   MIN_RATE_THRESHOLD="$OPTARG" ;;
    m|max    )   MAX_RATE_THRESHOLD="$OPTARG" ;;

    h|help     )  usage; exit 0   ;;

    v|version  )  echo "$0 -- Version $ScriptVersion"; exit 0   ;;

    \? )  echo -e "\n  Option does not exist : $OPTARG\n"
          usage; exit 1   ;;

  esac    # --- end of case ---
done
shift $(($OPTIND-1))

if [ ! -r "$INPUT_FILE" ] ; then
    echo file not found can not read && exit 67 ;
fi

if [ -z "$OUTPUT_FILE" -o "$OUTPUT_FILE" = " " ]; then
    OUTPUT_FILE=${INPUT_FILE}.${OUTPUT_SUFFIX}
fi

TIMESTAMP=`date +"%F %T"`
IP_ADDR=`/sbin/ip addr | grep --only-matching --perl-regexp "(?<=inet )\S+(?=\/.*bond)"`


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  countNewSize
#   DESCRIPTION:  统计新增行数，并进行输出
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
countNewSize ()
{
    #-------------------------------------------------------------------------------
    #  修改一下提取方式，之前查找行数，现在查询文件大小
    #-------------------------------------------------------------------------------
    #NEW_LINE_SIZE=`nice wc -l $INPUT_FILE | awk '{print $1}'`
    NEW_LINE_SIZE=`ls -l "$INPUT_FILE" | perl -lane 'print $F[4]'`
    if [ "`wc -l $OUTPUT_FILE`" ] ; then
        OLD_LINE_SIZE=`tail -n1 $OUTPUT_FILE | awk '{print $(NF-1)}'`
        if [ "$NEW_LINE_SIZE" -ge "$OLD_LINE_SIZE" ] ; then
            INCREASE_LINE_SIZE=$(($NEW_LINE_SIZE - $OLD_LINE_SIZE))
        else
            INCREASE_LINE_SIZE=$NEW_LINE_SIZE
        fi
    else
        INCREASE_LINE_SIZE=0
    fi
    echo -e "$TIMESTAMP\t$NEW_LINE_SIZE\t$INCREASE_LINE_SIZE" >> $OUTPUT_FILE
}	# ----------  end of function countNewSize  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  compareSizeWithOldfiles
#   DESCRIPTION:  比较旧文件（ 记录文件.1, 记录文件.2 ... ）的平均数量,
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
compareSizeWithOldfiles ()
{
    THISHOURE=`date +%H`
    GREPRESULT=`grep " ${THISHOURE}:" ${OUTPUT_FILE}\.*`
    if [ "$GREPRESULT" ] ; then
        AVERRAGE_INCRE_SIZE=`grep " ${THISHOURE}:" ${OUTPUT_FILE}\.* | perl -ane '$s+=$F[-1]; $c++ if $F[-1]}{printf "%.2f\n",$s/$c if $c'`
        if [ "$AVERRAGE_INCRE_SIZE" ]  ; then
            INCRE_RATE=`perl -e 'printf "%.2f\n",$ARGV[0]/$ARGV[1]' $INCREASE_LINE_SIZE $AVERRAGE_INCRE_SIZE`
            echo "$INPUT_FILE increase rate $INCRE_RATE , this time `echo $INCREASE_LINE_SIZE|perl -ne 'foreach$f(qw/B KB MB GB/){if($_<1024){printf"%.2f%s\n",$_,$f; last} $_=$_/1024}'` , average is `echo $AVERRAGE_INCRE_SIZE|perl -ne 'foreach$f(qw/B KB MB GB/){if($_<1024){printf"%.2f%s\n",$_,$f; last} $_=$_/1024}'` . at $TIMESTAMP"
            ERRORMAIL_TRIGGER=`perl -le 'print 1 if $ARGV[0]/$ARGV[1] < $ARGV[2] || $ARGV[0]/$ARGV[1] > $ARGV[3]' $INCREASE_LINE_SIZE $AVERRAGE_INCRE_SIZE $MIN_RATE_THRESHOLD $MAX_RATE_THRESHOLD` 
        fi
    fi
}	# ----------  end of function compareSizeWithOldfiles  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  errorMail
#   DESCRIPTION:  报警
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
errorMail ()
{
    errMsg="$IP_ADDR $INPUT_FILE increase percent is $INCRE_RATE , now is `echo $INCREASE_LINE_SIZE|perl -ne 'foreach$f(qw/B KB MB GB/){if($_<1024){printf"%.2f%s\n",$_,$f; last} $_=$_/1024}'` , average is `echo $AVERRAGE_INCRE_SIZE|perl -ne 'foreach$f(qw/B KB MB GB/){if($_<1024){printf"%.2f%s\n",$_,$f; last} $_=$_/1024}'`"
    echo errMsg | ~/bin/mutt -s log_increase_rate $mail_user ;
}	# ----------  end of function errorMail  ----------


#-------------------------------------------------------------------------------
#  actioins
#-------------------------------------------------------------------------------

countNewSize
if [ -f ${OUTPUT_FILE}.1 ]  ; then
    compareSizeWithOldfiles
fi
if [ "$ERRORMAIL_TRIGGER" ] ; then
    if [ "$WARN_TRIGGER" ]  ; then
        errorMail
    fi
fi
