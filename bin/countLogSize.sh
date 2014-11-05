#!/bin/bash - 
#===============================================================================
#
#          FILE: countLogSize.sh
# 
#         USAGE: ./countLogSize.sh -i LOGFILE -o LOGFILE.size
# 
#   DESCRIPTION: 用于记录日志各个时段的自增行数。并比较旧文件 （记录文件.gz, 
#                记录文件.1.gz ... ）的平均数量,
# 
#       OPTIONS: ---
#  REQUIREMENTS: 需配合logrotate对记录文件进行压缩，轮换删除
#          BUGS: ---
#         NOTES: ---
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
#  而配合logrotate，历史记录文件为accesslog.size.*.gz
#-------------------------------------------------------------------------------
OUTPUT_SUFFIX=size


#-------------------------------------------------------------------------------
#  日志自增值小于过往平均自增值的阀值 (自增值/平均自增值)
#-------------------------------------------------------------------------------
MIN_RATE_THRESHOLD="0.5"

#-------------------------------------------------------------------------------
#  日志自增值大于过往平均自增值的阀值 (自增值/平均自增值)
#-------------------------------------------------------------------------------
MAX_RATE_THRESHOLD="2"

mobile=13725269365
mail_user="13725269365@139.com"


#-------------------------------------------------------------------------------
#  don't edit below
#-------------------------------------------------------------------------------


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

while getopts "i:o:whv" opt
do
  case $opt in

    o|output   ) OUTPUT_FILE="$OPTARG"   ;;
    i|input   )  INPUT_FILE="$OPTARG"   ;;
    w|warn   )   WARN_TRIGGER=1   ;;

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
IP_ADDR=`/sbin/ip addr | grep --only-matching --perl-regexp "(?<=inet )\S+(?=\/.*global)"`


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
    if [ -f "$OUTPUT_FILE" ] ; then
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
#   DESCRIPTION:  比较旧文件（记录文件.gz, 记录文件.1.gz ... ）的平均数量,
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
compareSizeWithOldfiles ()
{
    THISHOURE=`date +%H`
    GREPRESULT=`zgrep " ${THISHOURE}:" ${OUTPUT_FILE}*gz`
    if [ "$GREPRESULT" ] ; then
        AVERRAGE_INCRE_SIZE=`zgrep " ${THISHOURE}:" ${OUTPUT_FILE}*gz | perl -lane '$s+=$F[-1]; $c++ if $F[-1]}{print $s/$c'`
        RATE=`perl -le 'print $ARGV[0]/$ARGV[1]' $INCREASE_LINE_SIZE $AVERRAGE_INCRE_SIZE`
        ERRORMAIL_TRIGGER=`perl -le 'print 1 if $ARGV[0]/$ARGV[1] < $ARGV[2] || $ARGV[0]/$ARGV[1] > $ARGV[3]' $INCREASE_LINE_SIZE $AVERRAGE_INCRE_SIZE $MIN_RATE_THRESHOLD $MAX_RATE_THRESHOLD` 
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
    errMsg="$IP_ADDR $INPUT_FILE increase is rate is $RATE , $INCREASE_LINE_SIZE , $AVERRAGE_INCRE_SIZE"
    sendSMS "$mobile" "$errMsg" "$mail_user" 
}	# ----------  end of function errorMail  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  sendSMS
#   DESCRIPTION:  报警
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
#报警短信函数
function sendSMS(){
    mobileCount="0"
    receive_mobile_num=" "
    usernumbers=`echo $1|sed 's/,/ /g'`
    spsId="gd10658139"
    spNumber="06139"
    Msg=`echo $2 |cut -c 1-350`
    mailAddr="$3"
    send_time=`date '+%Y-%m-%d %H:%M:%S'`        
    for usernumber in $usernumbers
        do
        mobileCount=$((${mobileCount}+1))
        receive_mobile_num="<Mobile>86$usernumber</Mobile>"${receive_mobile_num}
    done
    pa="<OperCode>SMS101</OperCode>
        <AppId>SMSMsgSendReq</AppId>
        <Req>
        <UserNumber>86$usernumber</UserNumber>
        <UserMobile>86$usernumber</UserMobile>
        <SpsId>$spsId</SpsId>
        <SpNumber>$spNumber</SpNumber>
        <SendMsg>$Msg</SendMsg>
        <ComeFrom>102</ComeFrom>
        <SendType>1</SendType>
        <Priority>0</Priority>
        <OperType>401</OperType>
        <SendFlag>0</SendFlag>
        <StartSendTime>$send_time</StartSendTime>
        <StartTime>0</StartTime>
        <EndTime>1440</EndTime>
        <FeeType>1</FeeType>
        <FeeValue>0</FeeValue>
        <GroupId></GroupId>
        <CreateOperator></CreateOperator>
        <ServiceType>10000</ServiceType>
        <Mobiles>
        <Number>$mobileCount</Number>
        $receive_mobile_num
        </Mobiles>
        </Req>"
    smsResultCode=`echo $pa| curl -s -X  POST -H 'Content-Type: text/xml;charset=gbk' -d @- http://sms.api.localdomain:8139/send`
    if [ `echo $smsResultCode |grep -c '<ResultCode>000</ResultCode>'` -eq 0 ]; then
        echo $smsResultCode
        echo |bsmtp -h smtp.api.localdomain -f sys.alert@139.com -s "$Msg" $mailAddr
    fi
}

#-------------------------------------------------------------------------------
#  actioins
#-------------------------------------------------------------------------------

countNewSize
if [ -f ${OUTPUT_FILE}.gz ]  ; then
    compareSizeWithOldfiles
fi
if [ "$ERRORMAIL_TRIGGER" ] ; then
    if [ "$WARN_TRIGGER" ]  ; then
        errorMail
    fi
fi
