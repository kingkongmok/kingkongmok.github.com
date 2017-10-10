#! /bin/bash
. ~/.bash_profile
WORK_DIRECTORY=/backup/ogg/scripts/monitor_ogg
SOURCE_COMMAND="sh $WORK_DIRECTORY/get_ogg_source_stat"
TARGET_COMMAND="ssh -tt cktl-drdb sh $WORK_DIRECTORY/get_ogg_target_stat"
SOURCE_STAT=$WORK_DIRECTORY/source_stat.txt
TARGET_STAT=$WORK_DIRECTORY/target_stat.txt

cd $WORK_DIRECTORY
$SOURCE_COMMAND>$SOURCE_STAT
$TARGET_COMMAND>$TARGET_STAT

echo "Timestamp:"`date +"%Y%m%d %H:%M"`
echo "1. Check Process Stat, if OGG work well, the process status show RUNNING, else show ABENDED or STOPPING"
echo "   Source process stats:"
echo "          MANAGER          : "`awk '$1=="MANAGER" {print $2}' $SOURCE_STAT`
echo "          EXTRACT  EXCKS01 : "`awk '$3=="EXCKS01" {print $2}' $SOURCE_STAT`
echo "          DATAPUMP DPCKS01 : "`awk '$3=="DPCKS01" {print $2}' $SOURCE_STAT`
echo "   Target process stats:"
echo "          MANAGER          : "`awk '$1=="MANAGER" {print $2}' $TARGET_STAT`
echo "          REPLICAT RPCKS01 : "`awk '$3=="RPCKS01" {print $2}' $TARGET_STAT`

echo "2. Check process lag, if OGG work well, the lag second < 10 seconds"
echo "   Source process lag:"
echo "          EXTRACT  EXCKS01 "`awk '$6=="EXCKS01" {for(t=1;t<=1;t++){getline}{print}}' $SOURCE_STAT`
echo "          DATAPUMP DPCKS01 "`awk '$6=="DPCKS01" {for(t=1;t<=1;t++){getline}{print}}' $SOURCE_STAT`
echo "   Target process lag:"
echo "          REPLICAT RPCKS01 "`awk '$6=="RPCKS01" {for(t=1;t<=1;t++){getline}{print}}' $TARGET_STAT`
echo

