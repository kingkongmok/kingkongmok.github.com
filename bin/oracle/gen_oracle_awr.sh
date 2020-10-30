#!/bin/sh
export ORACLE_BASE=/u01/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/dbhome_1
export ORACLE_SID=wlcsp
AWRHOME=/home/mon/awr

#interval=8
#echo $ORACLE_SID
maxmin=`$ORACLE_HOME/bin/sqlplus -s /nolog << EOF # >> /home/mon/log/gen_oracle_awr.log #if general output to log,the maxmin will not get the value.
conn / as sysdba;
set heading off pagesize 0 feedback off verify off echo off;
select max(snap_id),min(snap_id) from dba_hist_snapshot where begin_interval_time>=sysdate-1 and begin_interval_time<=sysdate-1+8/24;
exit;
EOF`

#if [ -z "$maxmin" ]; then
#   echo "no rows returned from database"
#   exit 0
#else
#   echo $maxmin
#fi

max=`echo $maxmin | awk '{print $1}'`
min=`echo $maxmin | awk '{print $2}'`
#echo $max
#echo $min

rm -rf $AWRHOME/*

$ORACLE_HOME/bin/sqlplus -s /nolog << EOF >> /dev/null
conn / as sysdba;
@?/rdbms/admin/awrrpt.sql;
html
2
$min
$max
$AWRHOME/awrrpt_1_${min}_${max}.html
EOF
