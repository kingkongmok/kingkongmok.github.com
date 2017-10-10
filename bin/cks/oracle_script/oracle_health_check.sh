#!/bin/sh
####################################################################
#     Script: linux_info_check.sh                                  #
#     OS PLATFORM:  linux6*                                        #
####################################################################
#
# AUTHOR: 
# DATE: 03/05/2015
# PURPOSE: This shell script is to get linux system and db information
#
# This program will check:
#        System Error report
#        Database status and tablespace usage
#        DG performance information
#        other resource
####################################################################
syserrdate=`date +"%m%d"`
STATUS=
HOSTS=`hostname`
SCRIPT=`basename $0`
REPORT="/tmp/report_$HOSTS.log"

#Check Database Resource
#source related profile
. /home/oracle/.bash_profile 

LSNR_CHECK() {
echo "*************************Listener status************************"
lsnrctl status|grep -i "no listener"
if [ $? = 1 ]
then
echo "The listener status is ${STATUS:-NORMAL}."
else
echo "The listener may not run successfully, check please!!!"
fi
}

DB_CHECK() {
echo "*************************DATABASE status************************"
sqlplus -s /nolog<<EOF|sed '/^$/d' 2>/dev/null|grep -i "OPEN"
connect / as sysdba
select status from v\$instance;
quit
EOF
if [ $? = 0 ]
then
 echo "The instance is open."
else
 echo "Attention, the instance is not open!"
fi
}

#database,asm,crs error report
DBERROR_CHECK() { 
echo "**************************DB ERROR report***********************"
tail -200 /home/oracle/alert.log | grep -i ora-| grep -v grep

#ASM error report
echo "**************************ASM ERROR report**********************"
tail -50 /oracle/11.2.0/grid/gridbase/diag/asm/+asm/+ASM1/trace/alert_+ASM1.log | grep offline
}

# Check ASM free space
ASM_USAGE_CHECK() {
echo "*************************ASM free space*************************"
sqlplus -s /nolog<<EOF|sed '/^$/d' 2>/dev/null
conn /as sysdba
select name, free_mb from v\$asm_diskgroup;
quit
EOF
}

# Check database tablespace usage.
TBS_USAGE_CHECK() {
echo "*************************Tablespace Usage***********************"
sqlplus -s /nolog<<EOF
conn /as sysdba
spool /tmp/tbsusage;
@/tmp/tbscheck.sql;
spool off;
quit
EOF

TBSUSAGE=`cat /tmp/tbsusage.lst |sed '1d'|awk '{if ($2 > 90) print $1}'|xargs`
for tbsname in $TBSUSAGE
do
echo "The $tbsname tablespace percent more than %90, Check it please. "
done
}

# Check RMAN BACKUP JOBS
RMAN_BACKUP_CHECK() {
echo "*************************RMAN backup job status******************"
sqlplus -s /nolog<<EOF|sed '/^$/d' 2>/dev/null|grep -i "COMPLETED"
conn /as sysdba
set feedback off;
spool /tmp/rmanbakjob;
select status,to_char(start_time, 'yyyy/mm/dd HH24:MI:SS') start_time from v\$rman_backup_job_details where start_time>sysdate-1;
quit
EOF
if [ $? = 0 ]
then
echo "There is no error with rman backup jobs."
else
cat /tmp/rmanbakjob.lst
echo "RMAN backup job error exists as above, check on please!"
fi
}

# apply for primary db only.
DG_CHECK() {
echo "************************DataGuard status***********************"
norows="no rows selected"

sqlplus -s /nolog<<EOF|sed '/^$/d' 2>/dev/null|grep -i "$norows"
conn /as sysdba
spool /tmp/arcdestlog;
select error from v\$archive_dest where error is not null;
quit
EOF
if [ $? = 0 ]
then
echo "There is no archivelog dest error."
else
cat /tmp/arcdestlog.lst
echo "Archive dest error exists as above, check on primary db! "
fi
echo
sqlplus -s /nolog<<EOF|sed '/^$/d' 2>/dev/null|grep -i "$norows"
connect / as sysdba
spool /tmp/gaplog;
select * from v\$archive_gap;
quit
EOF
if [ $? = 0 ]
then
echo "There is no gap error on DG."
else
cat /tmp/gaplog.lst
echo "Archive gap exists as above, check on primary db!"
fi
}

echo "************************DB & DG status***********************" >$REPORT 2>&1
LSNR_CHECK >>$REPORT 2>&1
DB_CHECK >>$REPORT 2>&1
DBERROR_CHECK >>$REPORT 2>&1
RMAN_BACKUP_CHECK >>$REPORT 2>&1
DG_CHECK >>$REPORT 2>&1
ASM_USAGE_CHECK >>$REPORT 2>&1
TBS_USAGE_CHECK >>$REPORT 2>&1

#AUTO sendmail report.log to itdept
scp /tmp/report_ckstmis-db1.log cktl-drdb:/tmp/
scp /tmp/OGG_status.log cktl-drdb:/tmp/
echo "***********CKTL OGG daily status************" >/tmp/OGG_status.log

