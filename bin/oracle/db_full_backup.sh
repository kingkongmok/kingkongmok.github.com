#! /bin/sh

# CONFIGURE ARCHIVELOG DELETION POLICY TO APPLIED ON ALL STANDBY;
# CONFIGURE SNAPSHOT CONTROLFILE NAME TO <SHARESTORAGE>

source /home/oracle/.bash_profile
export DATE=$(date +%m%d%y_%H%M%S)
$ORACLE_HOME/bin/rman target / cmdfile=/home/oracle/bin/db_full_backup.rcv log=/home/oracle/backuplog/${DATE}_full.log
