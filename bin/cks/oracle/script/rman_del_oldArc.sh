#!/bin/sh
####################################################################
# AUTHOR: 
# DATE: 06/10/2014
# PURPOSE: This shell script is to Delete applied Archivelogs
####################################################################
HOSTS=`hostname`
REPORT="/tmp/delarch_$HOSTS.log"
logtokeep=100

#source related profile
. /home/oracle/.bash_profile

echo "*******delete applied archivelog*********\n" > $REPORT
### Get Max sequence# applied from Primary database ###
applied_seq1=`sqlplus -silent /nolog <<EOSQL
connect / as sysdba
whenever sqlerror exit sql.sqlcode
set pagesize 0 feedback off verify off heading off echo off
select max(sequence#) from v\\$archived_log where applied = 'YES' and thread#=1;
exit;
EOSQL`

applied_seq2=`sqlplus -silent /nolog  <<EOSQL
connect / as sysdba
whenever sqlerror exit sql.sqlcode
set pagesize 0 feedback off verify off heading off echo off
select max(sequence#) from v\\$archived_log where applied = 'YES' and thread#=2;
exit;
EOSQL`

### Calculate the archive log to delete ###
arch_to_del1=$(($applied_seq1-$logtokeep))
arch_to_del2=$(($applied_seq2-$logtokeep))

if [ -z "$arch_to_del1" ]; then
echo "No rows returned from database" >> $REPORT
exit 0
fi

#begin
echo "delete noprompt archivelog until sequence $arch_to_del2 thread 2;"|rman target / >> $REPORT
echo "delete noprompt archivelog until sequence $arch_to_del1 thread 1;"|rman target / >> $REPORT

unset applied_seq1 applied_seq2
unset arch_to_del1 arch_to_del2
